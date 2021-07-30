require_relative "../config/environment.rb"

class Student
	attr_accessor :name, :grade, :id

	def initialize(name, grade, id=nil)
		self.name = name
		self.grade = grade
		self.id = id
	end

	def save
		self.find ? self.update : self.insert
	end

	def find
		self.class.find(self.id)
	end

	def update
		sql = <<-SQL
			UPDATE students
			SET name = ?, grade = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.grade, self.id)
		self
	end

	def insert
		sql = <<-SQL
			INSERT INTO students (name, grade) VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, self.name, self.grade)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
		self
	end
	
	def self.find(id)
		sql = <<-SQL
			SELECT * FROM students WHERE id = ?
		SQL
		DB[:conn].execute(sql, id)[0]
	end

	def self.create(*args)
		student = self.new(*args)
		student.save
	end

	def self.new_from_db(array)
		id, name, grade = array
		self.new(name, grade, id)
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM students WHERE name = ?
		SQL
		result = DB[:conn].execute(sql, name)[0]
		result && (id, name, grade = result) && self.new(name, grade, id)
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE students (
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
end
