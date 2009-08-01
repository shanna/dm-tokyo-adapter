require 'dm-core'
require 'rufus/tokyo'

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
          @connection, @query, @native = connection, query, []
        end

        #--
        # TODO: connection[] if I have everything I need to fetch by the primary key.
        def read
          records = @connection.query do |statements|
            if @query.conditions.kind_of?(OrOperation)
              fail_native("Operation '#{@query.conditions.slug}'.")
            else
              @query.conditions.each do |condition|
                condition_statement(statements, condition)
              end
            end

            if native? && !@query.order.empty?
              sort_statement(statements, @query.order)
            end

            statements.limit(@query.limit) if native? && @query.limit
            statements.no_pk
          end

          records.each do |record|
            @query.fields.each do |property|
              field = property.field
              record[field] = property.typecast(record[field])
            end
          end

          return records if native?
          # TODO: Move log entry out to adapter sublcass and use #name?
          DataMapper.logger.warn(
            "TokyoAdapter: No native TableQuery support for conditions: #{@native.join(' ')}"
          )
          @query.filter_records(records)
        end

        def native?
          @native.empty?
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
              when NotOperation then condition_statement(statements, operation.first, !affirmative)
              when AndOperation then operation.each{|op| condition_statement(statements, op, affirmative)}
              else fail_native("Operation '#{operation.slug}'.")
            end
          end

          def comparison_statement(statements, comparison, affirmative = true)
            value     = comparison.value
            primitive = comparison.subject.primitive

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
              else fail_native("Comparison #{comparison.slug}'.") && return
            end

            statements.add(comparison.subject.field, operator, quote_value(value), affirmative)
          end

          def quote_value(value)
            "#{value}"
          end

          def sort_statement(statements, conditions)
            fail_native("Multiple (#{conditions.size}) order conditions.") if conditions.size > 1

            sort_order = conditions.first
            primitive  = sort_order.target.primitive
            direction  = case sort_order.operator
              when :asc  then primitive == Integer ? :numasc : :asc
              when :desc then primitive == Integer ? :numdesc : :desc
            end

            statements.order_by(sort_order.target.field, direction)
          end

          def fail_native(why)
            @native << why
          end
      end # Query
    end # Tokyo
  end # Adapters
end # DataMapper
