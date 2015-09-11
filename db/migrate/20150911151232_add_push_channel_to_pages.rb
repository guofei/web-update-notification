class AddPushChannelToPages < ActiveRecord::Migration
  def change
    add_column :pages, :push_channel, :string
  end
end
