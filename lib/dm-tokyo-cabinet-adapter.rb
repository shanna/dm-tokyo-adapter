# Silence the shitload of warnings from extlib and load dm-core.
verbose, $VERBOSE = $VERBOSE, nil
begin
  require 'dm-core'
rescue LoadError
  require 'rubygems'
  require 'dm-core'
end
$VERBOSE = verbose

# TODO: Use the ffi lib? Do people care?
require 'tokyocabinet'

require 'pathname'
dir = Pathname(__FILE__).dirname.expand_path / 'dm-tokyo-cabinet-adapter'
require dir / 'adapter'
require dir / 'query'
