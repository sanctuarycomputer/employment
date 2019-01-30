module Employment::UseCase
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  module ClassMethods
    attr_accessor :config

    def configure(config)
      self.config = config
    end

    def perform(*args)
      return new(*args).tap{ |use_case| use_case.perform } if (config.present? && config[:disable_transaction])

      ActiveRecord::Base.transaction do
        return new(*args).tap { |use_case| use_case.perform }
      end
    end
  end

  def perform
    raise NotImplementedError
  end

  def success?
    errors.none?
  end
end
