class WorkRequest::Cleanup
  include Employment::UseCase
  attr_reader :work_request

  def initialize(work_request)
    @work_request = work_request
  end

  def perform
    begin
      Employment::Utils.job_kubeclient.delete_job(@work_request.id, @work_request.namespace)
    rescue Kubeclient::ResourceNotFoundError
    end

    begin
      Employment::Utils.kubeclient.delete_pod(@work_request.id, @work_request.namespace)
    rescue Kubeclient::ResourceNotFoundError
    end

    unless @work_request.is_cleaned_up?
      @work_request.update({
        cleaned_up_at: DateTime.now.utc
      })
    end
  end
end
