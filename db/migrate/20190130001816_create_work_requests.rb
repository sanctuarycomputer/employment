class CreateWorkRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :work_requests, id: :uuid do |t|
      t.string :log, default: ""
      t.jsonb :job_definition, default: {}
      t.jsonb :status_queries, default: {}
      t.datetime :received_at
      t.datetime :cleaned_up_at
      t.timestamps
    end
  end
end
