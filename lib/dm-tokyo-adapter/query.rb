require 'dm-core'
require 'rufus-tokyo'

module DataMapper
  module Adapters
    module Tokyo

      # Query a Tokyo Cabinet table store with a DataMapper query.
      #
      # == Notes
      #
      # Query conditions not supported natively by TC's table query will fall back to DM's in-memory query
      # filtering. This may impact performance.
      class Query
        include Extlib::Assertions
        include DataMapper::Query::Conditions

        def initialize(connection, query)
          assert_kind_of 'connection', connection, Rufus::Tokyo::Table
          assert_kind_of 'query', query, DataMapper::Query
          @connection, @query, @native = connection, query, true
        end

        #--
        # TODO: Log when a query cannot be performed natively by TC.
        # TODO: Use native sorting if there is only a single order condition.
        # TODO: connection[] if I have everything I need to fetch by the primary key.
        def read
          records = @connection.query do |statements|
            if @query.conditions.kind_of?(OrOperation)
              @native = false
            else
              @query.conditions.each do |condition|
                condition_statement(statements, condition)
              end
            end

            statements.no_pk
            if @native
              statements.limit(@query.limit) if @query.limit
              # TODO: Native sorting when only one order field.
            end
          end

          # Typecast return values.
          records.each do |record|
            @query.fields.each do |property|
              field = property.field
              record[field] = property.typecast(record[field])
            end
          end

          @query.filter_records(records)
        end

        private
          def condition_statement(statements, conditions, affirmative = true)
            case conditions
              when AbstractOperation  then operation_statement(statements, conditions, affrimative)
              when AbstractComparison then comparison_statement(statements, conditions, affirmative)
            end
          end

          def operation_statement(statements, operation, affirmative = true)
            case operation
              when OrOperation  then @native = false
              when NotOperation then condition_statement(statements, operation.first, !affirmative)
              when AndOperation then operation.each{|op| condition_statement(statements, op, affirmative)}
            end
          end

          def comparison_statement(statements, comparison, affirmative = true)
            value     = comparison.value
            primitive = comparison.property.primitive

            if value.kind_of?(Range) && value.exclude_end?
              operation = BooleanOperation.new(:and,
                Comparison.new(:gte, comparison.property, value.first),
                Comparison.new(:lt, comparison.property, value.last)
              )
              operation_statement(statements, operation, affirmative)
              return
            end

            operator = case comparison
              when EqualToComparison              then primitive == Integer ? :numeq : :eq
              when InclusionComparison            then primitive == Integer ? :numoreq : nil
              when RegexpComparison               then :regex
              when LikeComparison                 then :regex
              when GreaterThanComparison          then :gt
              when LessThanComparison             then :lt
              when GreaterThanOrEqualToComparison then :gte
              when LessThanOrEqualToComparison    then :lte
            end

            unless operator
              @native = false
              return
            end
            statements.add(comparison.property.field, operator, quote_value(value), affirmative)
          end

          def quote_value(value)
            "#{value}"
          end
      end # Query
    end # Tokyo
  end # Adapters
end # DataMapper
