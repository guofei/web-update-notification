class AddDeviceTokenDeviceTypeLocaleIdentifierTimeZoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :device_token, :string
    add_column :users, :device_type, :string
    add_column :users, :locale_identifier, :string
    add_column :users, :time_zone, :string
  end
end
