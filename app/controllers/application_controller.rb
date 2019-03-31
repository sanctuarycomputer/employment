class ApplicationController < ActionController::API
  before_action :set_raven_context

  rescue_from Employment::Exception do |exception|
    render json: exception.as_json, status: exception.status.to_sym
  end

  def authenticate_api_key!
    @api_key ||= ApiKey.find_by(key: request.headers['X-Employment-Api-Key'])
    raise Employment::Exception::InvalidApiKey.new("api.invalid_api_key") unless @api_key.present?
  end

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
