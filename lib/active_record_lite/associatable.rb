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

    if settings[:class_name]
      @other_class_name = settings[:class_name]
    else
      @other_class_name = ActiveSupport::Inflector.camelize(association_name)
    end

    if settings[:primary_key]
      @primary_key = settings[:primary_key]
    else
      @primary_key = 'id'
    end

    if settings[:foreign_key]
      @foreign_key = settings[:primary_key]
    else
      @foreign_key = association_name.to_s + '_id'
    end

    @other_class = ActiveSupport::Inflector.constantize(@other_class_name)
    @other_table_name = @other_class.table_name

  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end


module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    define_method(name) do

      result = DBConnection.execute(<<-SQL, id)
      SELECT #{aps.other_table_name}.*
      FROM #{aps.other_table_name} JOIN #{self.class.table_name}
      ON #{aps.other_table_name}.#{aps.primary_key} = #{self.class.table_name}.#{aps.foreign_key}
      WHERE #{self.class.table_name}.#{aps.primary_key} = ?
      SQL
      aps.other_class.parse_all(result).first
    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
