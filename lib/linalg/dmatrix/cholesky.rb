#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # call-seq:
      #   cholesky  => u
      #   cholesky { |u| ... }  => block result
      #
      # Given a symmetric positive definite matrix +m+, gives
      # an upper-triangular matrix +u+ such that
      #   u.t * u
      # is equal to +m+.
      #
      # Only the upper-triangular portion of +m+ is considered
      # for the algorithm.
      #
      # Raises +Diverged+ if +m+ was not positive definite.
      #
      def cholesky   # :yields: u
         raise DimensionError unless square?
         uplo = Char.new "U"
         n = XInteger.new vsize
         a = self.clone
         lda = n
         info = XInteger.new
         
         Lapack.dpotrf(uplo,
                       n,
                       a,
                       lda,
                       info)

         raise Diverged unless info.value == 0
         
         a.zero_lower
         
         if block_given?
            yield a
         else
            a
         end
      end
   end
end


