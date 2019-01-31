class ApplicationController < ActionController::API
  rescue_from Employment::Exception do |exception|
    render json: exception.as_json, status: exception.status.to_sym
  end

  def authenticate_api_key!
    @api_key ||= ApiKey.find_by(key: request.headers['X-Employment-Api-Key'])
    raise Employment::Exception::InvalidApiKey.new("api.invalid_api_key") unless @api_key.present?
  end
end
