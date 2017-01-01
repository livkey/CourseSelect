class AddCourseDetail < ActiveRecord::Migration
  def change
    add_column :courses, :course_aim, :text, :default => '暂无课程要求'
    add_column :courses, :course_content, :text, :default => '暂无课程章节信息'
    add_column :courses, :course_teacher, :text, :default => '暂无课程教师信息'
  end
end
