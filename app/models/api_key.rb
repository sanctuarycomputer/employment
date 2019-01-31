class ApiKey < ApplicationRecord
  before_create :generate_key
  has_many :work_requests

  enum state: {
    active: 0
  }

  def generate_key
    self.key ||= loop do
      key = SecureRandom.hex(24)
      break key unless self.class.exists?(key: key)
    end
  end
end
