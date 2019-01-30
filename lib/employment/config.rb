class Employment::Config
  class << self
    def get
      base_host = ENV['EMPLOYMENT_BASE_HOST'] || "localhost:3000"
      Rails.application.credentials[base_host.to_sym].merge({ base_host: base_host })
    end
  end
end
