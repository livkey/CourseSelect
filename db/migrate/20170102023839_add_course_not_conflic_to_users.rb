class AddCourseNotConflicToUsers < ActiveRecord::Migration
  def change
    add_column :users, :course_not_conflict, :boolean, :default => true
  end
end
