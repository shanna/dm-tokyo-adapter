require 'dm-core'
require 'rufus-tokyo'

module DataMapper
  module Adapters
    module Tokyo

      #--
      # TODO: Documentation.
      class Query
        include Extlib::Assertions

        def initialize(connection, query)
          assert_kind_of 'connection', connection, Rufus::Tokyo::Table
          assert_kind_of 'query', query, DataMapper::Query
          @connection, @query, @native = connection, query, true
        end

        #--
        # TODO: Check for nested conditions and unsupported operators. Use dm's matching, sorting and limiting in this
        # case after the native match.
        # TODO: Use native sorting if there is only a single order condition.
        # TODO: connection[] if I have everything I need to fetch by the primary key.
        def read
          records = @connection.query do |statements|
            @query.conditions.each do |condition|
              condition_statement(statements, condition)
              if @query.conditions.kind_of?(Conditions::OrOperation)
                @native = false
                break
              end
            end

            statements.no_pk
            if @native
              statements.limit(@query.limit) if @query.limit
              # TODO: Native order when only one order field.
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
              when Conditions::AbstractOperation  then operation_statement(statements, conditions, affrimative)
              when Conditions::AbstractComparison then comparison_statement(statements, conditions, affirmative)
            end
          end

          def operation_statement(statements, operation, affirmative = true)
            case operation
              when Conditions::OrOperation  then @native = false
              when Conditions::NotOperation then condition_statement(statements, operation.first, !affirmative)
              when Conditions::AndOperation then operation.each{|op| condition_statement(statements, op, affirmative)}
            end
          end

          def comparison_statement(statements, comparison, affirmative = true)
            value     = comparison.value
            primitive = comparison.property.primitive

            if value.kind_of?(Range) && value.exclude_end?
              operation = Conditions::BooleanOperation.new(:and,
                Conditions::Comparison.new(:gte, comparison.property, value.first),
                Conditions::Comparison.new(:lt, comparison.property, value.last)
              )
              return operation_statement(statements, operation, affirmative)
            end

            operator = case comparison
              when Conditions::EqualToComparison              then primitive == Integer ? :numeq : :eq
              when Conditions::InclusionComparison            then primitive == Integer ? :numoreq : nil
              when Conditions::RegexpComparison               then :regex
              when Conditions::LikeComparison                 then :regex
              when Conditions::GreaterThanComparison          then :gt
              when Conditions::LessThanComparison             then :lt
              when Conditions::GreaterThanOrEqualToComparison then :gte
              when Conditions::LessThanOrEqualToComparison    then :lte
              else @native = false
            end

            return unless operator
            statements.add(comparison.property.field, operator, quote_value(value), affirmative)
          end

          def quote_value(value)
            "#{value}"
          end
      end # Query
    end # Tokyo
  end # Adapters
end # DataMapper
