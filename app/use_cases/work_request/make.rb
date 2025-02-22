class WorkRequest::Make
  include Employment::UseCase
  attr_reader :work_request

  def initialize(api_key, image, command, env)
    # TODO: handle resources
    
    @image = image
    @command = sanitize(command) 
    @env = env
    @work_request = WorkRequest.create({ api_key: api_key })
  end

  def perform
    @work_request.update(job_definition: job_definition)
    Employment::Utils.job_kubeclient.create_job(
      Kubeclient::Resource.new(@work_request.job_definition)
    )
  end

  private

  def job_definition
    {
      apiVersion: 'batch/v1',
      metadata: {
        name: @work_request.id,
        namespace: @work_request.namespace
      },
      spec: {
        template: {
          metadata: {
            name: @work_request.id,
          },
          spec: {
            containers: [{
              name: @work_request.id,
              image: @image,
              command: @command,
              env: (@env.map do |k, v|
                { name: k, value: v }
              end),
              resources: {
                limits: {
                  cpu: '250m',
                  memory: '512Mi'
                },
                requests: {
                  cpu: '125m',
                  memory: '256Mi'
                }
              }
            }],
            restartPolicy: 'Never'
          }
        }
      }
    }
  end

  def sanitize(command)
    return [] unless command.present?
    
    if command.is_a?(Array) 
      return command
    end

    if command.is_a?(String)
      shebang_match = command.match(/#!(.+)$/)
      if (shebang_match)
        command.sub!("#{shebang_match[0]}\n", "")
        return [shebang_match[1], "-c"] + [command]
      else
        raise Employment::Exception::NoShebang.new("command.no_shebang") 
      end
    end

    raise "no"
  end
end
