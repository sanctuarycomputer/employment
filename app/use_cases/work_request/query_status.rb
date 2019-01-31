class WorkRequest::QueryStatus
  include Employment::UseCase
  attr_reader :log, :container_state, :work_request

  def initialize(work_request, force_reading = false)
    @work_request = work_request
    @container_state = { "state" => "unknown" }
    @log = ""
    @force_reading = force_reading
  end

  def perform
    # If it's already terminated, attempt a cleanup, then return
    if (
      @work_request.latest_status_query.present? &&
      @work_request.latest_status_query["state"] == "terminated"
    )
      WorkRequest::Cleanup.perform(@work_request) unless @work_request.is_cleaned_up?
      @log = @work_request.log
      @container_state = @work_request.latest_status_query
      return
    end

    ## TODO: Handle { state: "waiting", reason: "ErrImagePull" }

    # If there's a recent reading, return that 
    unless @force_reading 
      recent_reading = (@work_request.status_queries || {}).keys.find do |ts| 
        DateTime.parse(ts) > (DateTime.now - 5.seconds)
      end
      if (recent_reading.present?)
        @log = @work_request.log
        @container_state = @work_request.status_queries[recent_reading]
        return
      end
    end

    # OK, make the request
    job_pod = Employment::Utils.kubeclient.get_pods(
      label_selector: "job-name=#{@work_request.id}"
    ).first
    raise Employment::Exception::NoJobExists.new("job.does_not_exist") unless job_pod.present?

    state = job_pod.dig(:status, :containerStatuses, 0, :state)
    return unless state.present?
    @container_state = serialize_container_state(state)

    # Let's get the Log if we can
    if (["running", "terminated"].include?(@container_state["state"]))
      @log = Employment::Utils.kubeclient.get_pod_log(
        job_pod.metadata.name, 
        job_pod.metadata.namespace
      ).body
    end

    # Cache the query & Log
    @work_request.update({
      status_queries: @work_request.status_queries.merge({
        "#{DateTime.now.utc.iso8601}": @container_state
      }),
      log: @log
    })

    # Cleanup if it became terminated
    WorkRequest::Cleanup.perform(@work_request) if self.terminated?
  end

  def unknown?
    return false unless @container_state.present?
    (@container_state || {})["state"] == "unknown"
  end

  def waiting?
    return false unless @container_state.present?
    (@container_state || {})["state"] == "waiting"
  end

  def running?
    return false unless @container_state.present?
    (@container_state || {})["state"] == "running"
  end

  def terminated?
    return false unless @container_state.present?
    (@container_state || {})["state"] == "terminated"
  end

  private

  def serialize_container_state(raw_state)
    h = raw_state.to_h
    h[h.keys.first][:state] = h.keys.first
    h = h[h.keys.first]

    case h[:state]
    when :running
      {
        "state" => "running",
        "started_at" => h[:startedAt]
      }
    when :terminated
      {
        "state" => "terminated",
        "started_at" => h[:startedAt],
        "finished_at" => h[:finishedAt],
        "exit_code" => h[:exitCode],
        "message" => h[:message]
      }
    when :waiting
      {
        "state" => "waiting",
        "reason" => h[:reason]
      }
    else
      {
        "state" => "unknown"
      }
    end
  end
end
