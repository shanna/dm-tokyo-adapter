require 'dm-tokyo-adapter/cabinet'

module DataMapper
  module Adapters
    module Tokyo

      #--
      # TODO: Documentation.
      class TyrantAdapter < Tokyo::CabinetAdapter
        protected
          def create_connection(model)
            credentials = [@options[:socket] || @options.values_at(:host, :port)]
            Rufus::Tokyo::TyrantTable.new(*credentials.flatten)
          end
      end # TyrantAdapter
    end # Tokyo

    TokyoTyrantAdapter = Tokyo::TyrantAdapter
    const_added(:TokyoTyrantAdapter)
  end # Adapters
end

