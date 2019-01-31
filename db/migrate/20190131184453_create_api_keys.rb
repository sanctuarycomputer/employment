class CreateApiKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.string :email, limit: 48
      t.string :key, limit: 48
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
