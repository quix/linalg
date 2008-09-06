#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   class Math
      extend ::Math

      def self.min(a, b)
         a < b ? a : b
      end

      def self.max(a, b)
         a > b ? a : b
      end

      def self.log2(x)
         ::Math.log(x)/::Math.log(2.0)
      end
   end
end
