#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # The condition number.  Ratio of the largest singular value to
      # the smallest.
      #
      def cond
         s = singular_values
         begin
            c = s[0]/s[s.vsize-1]
            c.nan? ? 1.0/0.0 : c
         rescue SingularMatrix
            1.0/0.0
         end
      end

      #
      # Estimate the condition number using the
      # 1-norm.  Seems to be within an order of magnitude.
      #
      def cond_est_1
         begin
            1.0/rcond_private(:col)
         rescue SingularMatrix
            1.0/0.0
         end
      end

      #
      # Estimate the condition number using the
      # infinity-norm.  Seems to be within an order of magnitude.
      #
      def cond_est_inf
         begin
            1.0/rcond_private(:row)
         rescue SingularMatrix
            1.0/0.0
         end
      end
      
      private

      def rcond_private(which)
         raise DimensionError unless square?

         norm = (which == :col) ? Char.new("1") : Char.new("I")
         n = XInteger.new vsize
         a = self.clone
         a.lu!
         lda = n
         anorm = DData.new(1) {
            (which == :col) ? a.column_norm : a.row_norm
         }
         rcond = DReal.new
         work = DData.new(4*n.value)
         iwork = IData.new(n.value)
         info = XInteger.new
         
         Lapack.dgecon(norm,
                       n,
                       a,
                       lda,
                       anorm,
                       rcond,
                       work,
                       iwork,
                       info)
         rcond[0]
      end
   end
end


