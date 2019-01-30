class Employment::Utils
  class << self
    def config 
      Kubeclient::Config.new(YAML.safe_load(Employment::Config.get[:kube_config]), nil)
    end

    def job_kubeclient 
      @job_kubeclient ||= Kubeclient::Client.new(
        "#{self.config.context.api_endpoint}/apis/batch",
        self.config.context.api_version,
        ssl_options: self.config.context.ssl_options,
        auth_options: self.config.context.auth_options
      )
    end

    def kubeclient
      @kubeclient ||= Kubeclient::Client.new(
        self.config.context.api_endpoint,
        self.config.context.api_version,
        ssl_options: self.config.context.ssl_options,
        auth_options: self.config.context.auth_options
      )
    end
  end
end
