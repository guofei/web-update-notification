class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :channel

      t.timestamps null: false
    end
    add_index :users, :channel, unique: true
  end
end
