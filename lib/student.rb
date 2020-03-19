require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  #Class Methods
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name, grade) # hash contains name, grade
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = Student.new(row[1], row[2])
    student.save
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name)[0]
    Student.new(result[1], result[2], result[0])
  end

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.id)
  end
end
