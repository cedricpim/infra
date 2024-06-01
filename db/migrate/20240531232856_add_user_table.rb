class AddUserTable < ActiveRecord::Migration[7.1]
  def change
    create_table :events, id: :uuid do |t|
      t.timestamps

      t.index :created_at
    end
  end
end
