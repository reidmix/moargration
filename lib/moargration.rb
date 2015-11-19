module Moargration
  module ColumnFilter
    def columns
      unless defined?(@cached_moargration_columns) && @cached_moargration_columns
        @cached_moargration_columns = super.reject do |column|
          column_name = column.respond_to?(:name) ? column.name : column.to_s
          (Moargration.columns_to_ignore[table_name.to_s] || []).include?(column_name)
        end
      end
      @cached_moargration_columns
    end

    def columns!
      @cached_moargration_columns = nil
      defined?(super) ? super : columns
    end
  end

  class Exception < StandardError; end

  extend self

  def init(orm=:active_record)
    @@columns_to_ignore = {}
    return unless ignore = ENV["MOARGRATION_IGNORE"]
    self.columns_to_ignore = parse(ignore||"")
    send(:"hack_#{orm}!")
  end

  def columns_to_ignore=(columns)
    @@columns_to_ignore = columns
  end

  def columns_to_ignore
    @@columns_to_ignore
  end

  def ignoring?(table, column)
    ignored_columns = columns_to_ignore[table.to_s] || []
    ignored_columns.include?(column.to_s)
  end

  def parse(text)
    text.strip.split(" ").inject({}) do |parsed, definition|
      table, fields = definition.split(":", 2)
      parsed[table] = fields.split(",") if fields
      parsed
    end
  end

  def hack_active_record!
    class << ActiveRecord::Base
      prepend ColumnFilter
    end
  end

  def hack_sequel!
    class << Sequel::Model
      prepend ColumnFilter
    end

    Sequel::Dataset.class_eval do
      prepend ColumnFilter
      alias_method :table_name, :first_source_table
    end
  end

end
