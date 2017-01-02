class AddCourseNotConflicToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :course_not_conflict, :string, :default => true
  end
end
