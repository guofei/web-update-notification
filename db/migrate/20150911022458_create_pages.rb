class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.text :content
      t.string :hash
      t.string :uri
      t.string :uuid
      t.integer :sec

      t.timestamps null: false
    end
    add_index :pages, :uuid, unique: true
  end
end
