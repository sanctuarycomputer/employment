class WorkRequest < ApplicationRecord
  belongs_to :api_key

  def namespace
    'default'
  end

  def simple_format
    {
      id: id,
      received_at: created_at.iso8601,
      cleaned_up_at: cleaned_up_at.try(:iso8601),
      is_cleaned_up: is_cleaned_up? 
    }
  end

  def detailed_format
    simple_format.merge({
      log: log,
      status: latest_status_query
    })
  end

  def latest_status_query
    latest_timestamp = status_queries.keys.map{|ts| DateTime.parse(ts)}.max
    return nil unless latest_timestamp.present?
    status_queries[latest_timestamp.utc.iso8601]
  end

  def is_cleaned_up?
    cleaned_up_at.present?
  end
end
