class AddContentDiffToPage < ActiveRecord::Migration
  def change
    add_column :pages, :content_diff, :text
  end
end
