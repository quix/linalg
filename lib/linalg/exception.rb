#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   module Exception

      #
      # The algorithm failed to converge.
      #
      class Diverged < RuntimeError
      end

      #
      # One or more parameters failed to meet the
      # prerequisite dimensions.
      #
      class DimensionError < RuntimeError
      end

      #
      # A singular matrix was encountered where a nonsingular one
      # was expected.
      #
      class SingularMatrix < RuntimeError
      end

   end
end

