require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams

  attr_accessor :other_class_name, :other_class_name, :primary_key, :foreign_key, :other_class, :other_table_name

  def initialize(association_name, settings)
    @other_class_name = settings[:class_name] || ActiveSupport::Inflector.camelize(association_name)
    @primary_key = settings[:primary_key] || 'id'
    @foreign_key = settings[:foreign_key] || association_name.to_s + '_id'
  end

  def type
  end
end

class HasManyAssocParams < AssocParams

  attr_accessor :other_class_name, :other_class_name, :primary_key, :foreign_key, :other_class, :other_table_name

  def initialize(association_name, settings, self_class)

    if settings[:class_name]
      @other_class_name = settings[:class_name]
    else
      singular = ActiveSupport::Inflector.singularize(association_name)
      @other_class_name = ActiveSupport::Inflector.camelize(singular)
    end

    @primary_key = settings[:primary_key] || 'id'
    @foreign_key = settings[:foreign_key] || ActiveSupport::Inflector.underscore(self_class) + '_id'
    @other_class = ActiveSupport::Inflector.constantize(@other_class_name)
    @other_table_name = @other_class.table_name
  end

  def type
  end
end


module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    puts "belongs to macro"
    define_method(name) do

      other_class = ActiveSupport::Inflector.constantize(aps.other_class_name)
      other_table_name = other_class.table_name

      puts "belongs to method"
      result = DBConnection.execute(<<-SQL, id)
      SELECT #{other_table_name}.*
      FROM #{other_table_name} JOIN #{self.class.table_name}
      ON #{other_table_name}.#{aps.primary_key} = #{self.class.table_name}.#{aps.foreign_key}
      WHERE #{self.class.table_name}.#{aps.primary_key} = ?
      SQL
      other_class.parse_all(result).first
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
    puts "has many macro"
    define_method(name) do

      query = "SELECT #{aps.other_table_name}.*
      FROM #{aps.other_table_name} JOIN #{self.class.table_name}
      ON #{aps.other_table_name}.#{aps.foreign_key} = #{self.class.table_name}.#{aps.primary_key}
      WHERE #{self.class.table_name}.#{aps.primary_key} = ?"


      rows = DBConnection.execute(<<-SQL, id)
      SELECT #{aps.other_table_name}.*
      FROM #{aps.other_table_name} JOIN #{self.class.table_name}
      ON #{aps.other_table_name}.#{aps.foreign_key} = #{self.class.table_name}.#{aps.primary_key}
      WHERE #{self.class.table_name}.#{aps.primary_key} = ?
       SQL
      aps.other_class.parse_all(rows)
    end


  end

  def has_one_through(name, assoc1, assoc2)
  end
end
