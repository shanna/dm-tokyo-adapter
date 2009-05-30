require 'dm-core'
require 'fileutils'
require 'rufus-tokyo'

module DataMapper
  module Adapters
    class TokyoCabinetAdapter < AbstractAdapter
      def create(resources)
        resources.map do |resource|
          model          = resource.model
          identity_field = model.identity_field

          with_connection(resource.model) do |connection|
            initialize_identity_field(resource, connection.generate_unique_id) if identity_field
            connection[key(resource)] = attributes(resource, :field)
          end
        end.size
      end

      def read(query)
        with_connection(query.model) do |connection|
          # TODO: connection[] if I have everything I need to fetch by the primary key.
          records = connection.query do |q|
            q.no_pk
            q.limit(query.limit) if query.limit
            query.conditions.operands.each do |op|
              property = op.property
              slug     = op.class.slug
              slug     = :numeq if op.kind_of?(Conditions::EqualToComparison) && property.primitive == Integer
              q.add(op.property.field, slug, op.value.to_s)
            end
          end

          # Typecast return values.
          records.each do |record|
            query.fields.each do |property|
              field = property.field
              record[field] = property.typecast(record[field])
            end
          end

          # TC only supports a single order field.
          query.sort_records(records).dup
        end
      end

      def update(attributes, collection)
        with_connection(collection.query.model) do |connection|
          collection.each do |record|
            connection[key(record)] = attributes(record, :field)
          end.size
        end
      end

      def delete(collection)
        with_connection(collection.query.model) do |connection|
          collection.each do |record|
            connection.delete(key(record))
          end.size
        end
      end

      protected
        def create_connection(model)
          @tdb_path ||= FileUtils.mkdir_p(
            File.join(*[@options[:path], (@options[:host] || @options[:database])].compact)
          ).first
          tdb = File.join(@tdb_path, "#{model.base_model.storage_name(name)}.tdb")
          Rufus::Tokyo::Table.new(tdb)
        end

        def close_connection(connection)
          connection.close
        end

      private
        def key(resource)
          key = resource.key
          (key.size > 1 ? key.join(':') : key.first).to_s
        end

        def attributes(resource, key_on = :name)
          resource.attributes(key_on).map{|k, v| [k, v.to_s]}.to_hash
        end

        def with_connection(model)
          begin
            connection = create_connection(model)
            return yield(connection)
          rescue => error
            DataMapper.logger.error(error.to_s)
            raise error
          ensure
            close_connection(connection) if connection
          end
        end
    end # TokyoCabinetAdapter

    class TokyoTyrantAdapter < TokyoCabinetAdapter
      protected
        def create_connection(model)
          Rufus::Tokyo::TyrantTable.new(@options[:host], @options[:port])
        end
    end # TokyoTyrantAdapter
  end # Adapters
end # DataMapper
