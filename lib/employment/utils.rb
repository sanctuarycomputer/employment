class Employment::Utils
  class << self
    def droplet_kit_client
      require 'droplet_kit'
      @droplet_kit_client ||= DropletKit::Client.new(access_token: Employment::Config.get[:digital_ocean_token])
    end

    def config 
      # TODO: Cache this
      loaded_config = droplet_kit_client.kubernetes_clusters.kubeconfig(
        id: droplet_kit_client.kubernetes_clusters.all.find{|cluster| cluster.name == Employment::Config.get[:cluster_name]}.id
      )
      Kubeclient::Config.new(YAML.safe_load(loaded_config), nil)
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
