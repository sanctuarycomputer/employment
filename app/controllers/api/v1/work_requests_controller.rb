class Api::V1::WorkRequestsController < ApplicationController
  before_action :authenticate_api_key!

  def index
    render json: { data: @api_key.work_requests.map(&:simple_format) }
  end

  def create
    safe_params = if params[:command].is_a?(Array)
                    params.permit(:image, env: {}, command: [])
                  else
                    params.permit(:image, :command, env: {})
                  end

    raise Employment::Exception::NoImage.new("job.no_image") unless safe_params[:image].present?

    work_request = WorkRequest::Make.perform(
      @api_key,
      safe_params[:image],
      safe_params[:command],
      safe_params[:env].to_h
    ).work_request

    render json: WorkRequest::QueryStatus.perform(work_request).work_request.detailed_format, status: :created
  end

  def show
    load_and_authorize_work_request 
    render json: WorkRequest::QueryStatus.perform(@work_request).work_request.detailed_format
  end

  def destroy
    load_and_authorize_work_request 
    WorkRequest::Cleanup.perform(@work_request)

    @work_request.update({
      status_queries: @work_request.status_queries.merge({
        "#{DateTime.now.utc.iso8601}": {
          "state" => "terminated",
          "message" => "via API",
          "previous_status" => @work_request.latest_status_query
        }
      })
    })

    render json: @work_request.detailed_format
  end

  private

  def load_and_authorize_work_request
    @work_request = WorkRequest.find_by(id: params[:id])
    unless @work_request.present?
      raise Employment::Exception::NotFound.new("api.not_found")
    end
    if (@work_request.api_key_id != @api_key.id)
      raise Employment::Exception::InvalidApiKey.new("api.invalid_api_key")
    end
  end
end
