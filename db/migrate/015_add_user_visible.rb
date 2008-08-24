class AddUserVisible < ActiveRecord::Migration
  def self.up
    add_column "users", "visible", :boolean, :default => true, :null => false
    User.update_all("visible = 1")
  end

  def self.down
    remove_column "users", "visible"
  end
end
