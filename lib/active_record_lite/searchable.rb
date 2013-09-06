require_relative './db_connection'

module Searchable
  def where(params)

    params_line = params.keys.map { |param| "#{param} = ?" }.join(' AND ')

    rows = DBConnection.execute(<<-SQL, params.values)
      SELECT *

      FROM #{self.table_name}

      WHERE #{params_line}

    SQL
    self.parse_all(rows)
  end
end