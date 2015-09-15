class RenameUriToUrlInPage < ActiveRecord::Migration
  def change
    rename_column :pages, :uri, :url
  end
end
