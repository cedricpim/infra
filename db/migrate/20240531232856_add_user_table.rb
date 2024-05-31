class AddUserTable < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.timestamps

      t.index :name
    end
  end
end
