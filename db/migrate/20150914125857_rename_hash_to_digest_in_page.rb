class RenameHashToDigestInPage < ActiveRecord::Migration
  def change
    rename_column :pages, :hash, :digest
  end
end
