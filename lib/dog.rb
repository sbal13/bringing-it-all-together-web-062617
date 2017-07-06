require 'pry'
class Dog

	attr_accessor :name, :breed, :id

	def initialize(info_hash)
		info_hash.each do|key, value| 
			self.send("#{key}=", value)
		end
	end


	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT);
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL 
			DROP TABLE dogs
		SQL
		DB[:conn].execute(sql)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed)
				VALUES (?,?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)

			find_id_sql = <<-SQL
				SELECT id FROM dogs ORDER BY id DESC LIMIT 1
			SQL
			self.id = DB[:conn].execute(find_id_sql)[0][0]

			self
		end
	end

	def self.create(info_hash)
		new_dog = self.new(info_hash)
		new_dog.save
	end

	def self.find_by_id(search_id)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE id = ?
		SQL

		row = DB[:conn].execute(sql, search_id)[0]
		return nil if row.nil?

		self.new_from_db(row)
	end

	def self.find_by_name(search_name)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE name = ?
		SQL

		row = DB[:conn].execute(sql, search_name)[0]

		return nil if row.nil?

		self.new_from_db(row)
		
	end

	def self.new_from_db(row)
		info_hash = {}
		info_hash[:id] = row[0]
		info_hash[:name] = row[1]
		info_hash[:breed] = row[2]

		new_dog = Dog.new(info_hash)
	end

	def self.find_or_create_by(params)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE name = ? AND breed = ?
		SQL

		found_dog = DB[:conn].execute(sql, params[:name], params[:breed])

		

		if !found_dog.empty?
			dog = Dog.new(id: found_dog[0][0], name: found_dog[0][1], breed: found_dog[0][2])
		else
			# i = 1
			# while self.find_by_id(i)
			# 	i+=1
			# end
			# params[:id] = i
			dog = self.create(params)
		end

	end

	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ?
			WHERE id = ?;
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)

		self
	end
end