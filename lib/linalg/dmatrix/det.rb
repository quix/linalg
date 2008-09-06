#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix

      #
      # Returns the determinant of the matrix.  Raises
      # +DimensionError+ if the matrix is not square.
      #
      def determinant
         raise DimensionError unless square?
         begin
            a = self.clone
            ipiv = a.lu!
            res = 1.0
            sign = 1
            vsize.times { |i|
               res *= a[i,i]
               
               # 1-based fortran
               if ipiv[i] != i + 1
                  sign *= -1 
               end
            }
            res*sign
         rescue SingularMatrix
            0.0
         end
      end
   end
end
