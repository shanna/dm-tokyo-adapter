require 'dm-tokyo-adapter/cabinet'

module DataMapper
  module Adapters
    module Tokyo

      # A DataMapper Tokyo Tyrant table store adapter.
      #
      # http://tokyocabinet.sourceforge.net/tyrantdoc/
      # http://tokyocabinet.sourceforge.net/spex-en.html#features_tctdb
      #
      # The Tokyo Cabinet table storage engine doesn't require a predefined schema and as such properties in your
      # resource are only used by the adapter for typecasting. There is no need to migrate your resource when you
      # create, update or delete properties.
      #
      # == See
      #
      # DataMapper::Adapters::Tokyo::Query:: Table Query.
      class TyrantAdapter < Tokyo::CabinetAdapter
        protected

          #--
          # TODO: Default port to 1978?
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

