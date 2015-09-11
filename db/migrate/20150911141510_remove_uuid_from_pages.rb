class RemoveUuidFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :uuid, :string
  end
end
