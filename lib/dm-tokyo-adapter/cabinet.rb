require 'dm-core'
require 'fileutils'
require 'rufus-tokyo'

module DataMapper
  module Adapters
    module Tokyo

      # A DataMapper Tokyo Cabinet table store adapter.
      #
      # http://tokyocabinet.sourceforge.net/spex-en.html#features_tctdb
      #
      # The Tokyo Cabinet table storage engine doesn't require a predefined schema and as such properties in your
      # resource are only used by the adapter for typecasting. There is no need to migrate your resource when you
      # create, update or delete properties.
      #
      # == See
      #
      # DataMapper::Adapters::Tokyo::Query:: Table Query.
      class CabinetAdapter < AbstractAdapter
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
            Tokyo::Query.new(connection, query).read
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
      end # CabinetAdapter
    end # Tokyo

    TokyoCabinetAdapter = Tokyo::CabinetAdapter
    const_added(:TokyoCabinetAdapter)
  end # Adapters
end # DataMapper
