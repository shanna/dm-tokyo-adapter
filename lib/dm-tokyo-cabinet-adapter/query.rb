module DataMapper
  module Adapters
    module TokyoCabinet

      #--
      # TODO: Perhaps switch to rufus?
      class Query < ::TokyoCabinet::TDBQRY
        include Extlib::Assertions

        def initialize(connection, query)
          assert_kind_of 'connection', connection, ::TokyoCabinet::TDB
          assert_kind_of 'query', query, DataMapper::Query
          @connection = connection
          super connection

          # TODO: Composite keys.
          if query.conditions.size == 1 && key = query.conditions.find{|op, prop, val| prop.serial?}
            @get = key[2]
            return
          end

          query.conditions.each do |operator, property, value|
            field = property.field(query.repository.name) unless operator == :raw
            addcond(
              field,
              tc_operator(operator, property, value),
              tc_value(operator, property, value)
            )
          end

          setlimit query.limit.to_i if query.limit
          setorder(*tc_order(query))
        end

        def search
          @get ? [@connection.get(@get)] : super.map{|e| @connection.get(e)}.compact
        end

        protected
          def tc_operator(operator, property, value)
            # TODO: Not all operators are supported for all primitives, warn/error.
            # TODO: Range, Array support.
            # TODO: Negation?
            primitive = property.primitive
            case operator
              when :eql  then primitive == Integer ? QCNUMEQ : QCSTREQ
              when :like then QCSTRINC
              when :in   then QCSTRINC
              when :gt   then QCNUMGT
              when :lt   then QCNUMLT
              when :gte  then QCNUMGTE
              when :lte  then QCNUMLTE
              when :raw  then QCSTRRX
              else raise NotImplementedError.new("TokyoCabinet: Query does not suppor the #{operator} operator")
            end
          end

          def tc_value(operator, property, value)
            value
          end

          def tc_order(query)
            warn "TokyoCabinet: Query only supports single order condition" if query.order.size > 1
            order     = query.order.first
            field     = order.property.field(query.repository.name)

            # TODO: Number constants if the types primitive is a number type.
            direction = case order.direction
              when :asc  then ::TokyoCabinet::TDBQRY::QOSTRASC
              when :desc then ::TokyoCabinet::TDBQRY::QOSTRDESC
            end
            [field, direction]
          end
      end # Query
    end # TokyoCabinet
  end # Adapters
end # DataMapper
