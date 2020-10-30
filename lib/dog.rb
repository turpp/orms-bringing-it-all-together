class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil,name:,breed:)
        @id=id
        @name=name
        @breed=breed
    end

    def self.create_table
        sql=<<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table

        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        dog=Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_name(dog_name)
        sql=<<-SQL
        SELECT *
        FROM dogs
        WHERE name=?
        SQL

        array=DB[:conn].execute(sql,dog_name)[0]
        Dog.new(id: array[0],name: array[1], breed: array[2])
    end

    def self.find_by_id(dog_id)
        sql=<<-SQL
        SELECT *
        FROM dogs
        WHERE id=?
        SQL
        array=DB[:conn].execute(sql,dog_id)[0]
        Dog.new(id: array[0],name: array[1], breed: array[2])
    end
    def update
        sql="UPDATE dogs SET name=?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql,self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
            self
        else
            sql="INSERT INTO dogs (name, breed) VALUES (?,?)"
            results=DB[:conn].execute(sql, self.name, self.breed)
            @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(hash)
        array=hash.fetch_values(:name, :breed)
        
        dog = Dog.new(name: array[0], breed: array[1])
        dog.save
    end

    def self.find_or_create_by(hsh)
        
        sql="SELECT * FROM dogs WHERE name=? AND breed = ?"
        dog=DB[:conn].execute(sql, hsh[:name], hsh[:breed])
        if !dog.empty?
            binding.pry
            dog_data=dog[0]
            new_dog=Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
            new_dog
        else
            dog = self.create(hsh)
            dog.save
            dog
        end
        
    end
end

        