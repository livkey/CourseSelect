class ChangeDegreeTypeOfGrades < ActiveRecord::Migration
  def change
    remove_column :grades, :degree
    add_column :grades, :degree, :integer, :default => 0
  end
end
