require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    query = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = "DROP TABLE students;"
    DB[:conn].execute(query)
  end

  def save
    if self.id
      update
    else
      query = <<-SQL
    INSERT INTO students(name, grade)
    VALUES(?, ?)
    SQL
      DB[:conn].execute(query, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    self.new(id = row[0], name = row[1], grade = row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    SQL
    row = DB[:conn].execute(query, name)[0]
    student = Student.new_from_db(row)
    student
  end

  def update
    DB[:conn].execute(
      "UPDATE students SET name=?, grade=? WHERE id = ? ;",
      self.name,
      self.grade,
      self.id
    )
  end
end