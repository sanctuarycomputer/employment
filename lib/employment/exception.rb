class Employment::Exception < ::Exception
  attr_accessor :details
  attr_accessor :code
  attr_accessor :validations
  attr_accessor :status
  attr_accessor :title
  attr_accessor :detail

  class NoShebang < Employment::Exception; end
  class NoJobExists < Employment::Exception; end

  def initialize(code, details={}, validations={})
    @details     = details
    @code        = code
    @status      = I18n.t "exceptions.#{code}.status"
    @title       = I18n.t "exceptions.#{code}.title", details
    @detail      = I18n.t "exceptions.#{code}.detail", details
    @message     = @detail
    @validations = validations
  end

  def validation_array
    array = []
    @validations.to_hash.each_key do |key|
      array << {
        title: @validations[key].uniq.join(', '),
        source: { pointer: "data/attributes/#{key}" }
      }
    end
    array
  end

  def base_error
    {
      title: title,
      detail: detail,
      code: code,
      status: status
    }
  end

  def as_json
    { errors: validation_array.prepend(base_error) }
  end

  def message
    @message
  end
end
