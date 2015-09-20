class AddStopFetchToPage < ActiveRecord::Migration
  def change
    add_column :pages, :stop_fetch, :boolean, default: false
  end
end
