#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

trap("INT") { exit(-1) }

Dir["tc_*.rb"].sort.each { |f| require f }

