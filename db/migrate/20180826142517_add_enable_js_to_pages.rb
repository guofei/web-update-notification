class AddEnableJsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :enable_js, :boolean, default: false
  end
end
