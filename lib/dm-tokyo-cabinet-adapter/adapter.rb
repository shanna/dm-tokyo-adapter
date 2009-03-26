module DataMapper
  module Adapters
    module TokyoCabinet
      class Adapter < AbstractAdapter
        require 'fileutils'

        def initialize(name, uri_or_options)
          super
          @path = FileUtils.mkdir_p(@uri[:path] / @uri[:database])
        end

        def create(resources)
          resources.map do |resource|
            with_connection(resource.model) do |connection|
              if identity_field = resource.model.key(name).detect{|p| p.serial?}
                identity_field.set!(resource, connection.genuid)
              end

              # TODO: I'm kinda making this up as I go, pretty sure get! isn't what I want here.
              store = resource.model.properties.inject({}) do |accumulator, property|
                accumulator[property.field(name)] = property.get!(resource).to_s
                accumulator
              end

              # TODO: Composite keys.
              connection.put(resource.id, store) || nil
            end
          end.compact.size
        end

        def delete(query)
          with_connection(query.model) do |connection|
            if query.conditions.size == 0
              records = connection.rnum
              connection.vanish
              return records
            end

            # TODO: Composite key support.
            tc_query       = TokyoCabinet::Query.new(connection, query)
            results        = tc_query.search
            identity_field = query.model.key(name).detect{|p| p.serial?}
            results.each do |result|
              connection.out(result[identity_field.field(name)]) || nil
            end.compact.size
          end
        end

        def read_one(query)
          read(query, query.model, false)
        end

        def read_many(query)
          Collection.new(query) do |set|
            read(query, set, true)
          end
        end

        protected
          def read(query, set, many = true)
            with_connection(query.model) do |connection|
              tc_query = TokyoCabinet::Query.new(connection, query)
              results  = tc_query.search

              results.each do |result|
                values = query.model.properties.map do |property|
                  property.typecast(result[property.field(name)])
                end
                many ? set.load(values) : (break set.load(values, query))
              end
            end
          end

          def with_connection(model)
            # TODO: Mode option.
            tdb  = ::TokyoCabinet::TDB.new
            mode = ::TokyoCabinet::TDB::OWRITER | ::TokyoCabinet::TDB::OCREAT
            if tdb.open(@path / model.storage_name(name) + '.tdb', mode)
              begin
                return yield(tdb)
              ensure
                tdb.close
              end
            else
              raise "TokyoCabinet Error: #{tdb.ecode}"
            end
          end
      end # Adapter
    end # TokyoCabinet

    # Keep our classes nice and organized while still meeting the DM load magic happy.
    TokyoCabinetAdapter = TokyoCabinet::Adapter
  end # Adapters
end # DataMapper
