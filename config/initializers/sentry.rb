Raven.configure do |config|
  config.dsn = 'https://6dfa1a8d394e45fca65eb7fe93bfdc5b:6f19531ae32c4d6e975f307c1bb73ec5@sentry.io/1427790'
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
