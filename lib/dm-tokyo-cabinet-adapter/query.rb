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

          # All this mess to figure out if the query conditions hold a primary key search with no other conditions.
          keys = query.model.key(query.repository.name).map do |key|
            query.conditions.find{|c| c[0] == :eql && c[1] == key}
          end.compact

          if keys.size > 0 && keys.size == query.conditions.size
            values = keys.map{|c| tc_value(query, *c)}
            @get = keys.size > 1 ? Digest::SHA1.hexdigest(values.join(':')) : values.first
          else
            query.conditions.each do |c|
              addcond(tc_field(query, *c), tc_operator(query, *c), tc_value(query, *c))
            end
            setlimit(query.limit.to_i) if query.limit
            setorder(*tc_order(query)) if query.order.size > 0
          end
        end

        def search
          @get ? [@connection.get(@get)] : super.map{|e| @connection.get(e)}.compact
        end

        protected
          def tc_field(query, operator, property, value)
            property.field(query.repository.name)
          end

          def tc_operator(query, operator, property, value)
            # TODO: Not all operators are supported for all primitives, warn/error.
            # TODO: Range, Array support.
            # TODO: Negation?
            primitive = property.primitive
            case operator
              when :eql  then primitive == Integer ? QCNUMEQ : QCSTREQ
              when :like then QCSTRRX
              when :in   then QCSTRINC
              when :gt   then QCNUMGT
              when :lt   then QCNUMLT
              when :gte  then QCNUMGTE
              when :lte  then QCNUMLTE
              else raise NotImplementedError.new("TokyoCabinet: Query does not suppor the #{operator} operator")
            end
          end

          def tc_value(query, operator, property, value)
            value
          end

          def tc_order(query)
            warn "TokyoCabinet: Query only supports single order condition" if query.order.size > 1
            order = query.order.first
            field = order.property.field(query.repository.name)

            primitive = order.property.primitive
            direction = case order.direction
              when :asc  then primitive == Integer ? QONUMASC  : QOSTRASC
              when :desc then primitive == Integer ? QONUMDESC : QOSTRDESC
            end
            [field, direction]
          end
      end # Query
    end # TokyoCabinet
  end # Adapters
end # DataMapper
