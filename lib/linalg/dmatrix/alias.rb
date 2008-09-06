#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   class DMatrix
      alias_method :mul!, :postmul!
      alias_method :t, :transpose
      alias_method :inv, :inverse
      alias_method :det, :determinant
      alias_method :col, :column
      alias_method :svd, :singular_value_decomposition
      alias_method :sv, :singular_values
      alias_method :chol, :cholesky
      alias_method :nrow, :vsize
      alias_method :num_rows, :vsize
      alias_method :ncol, :hsize
      alias_method :num_columns, :hsize
      alias_method :pinv, :pseudo_inverse
      alias_method :orth, :rankspace
      alias_method :norm, :norm_2
      alias_method :column_norm, :norm_1
      alias_method :row_norm, :norm_inf
      alias_method :frobenius_norm, :norm_f

      private :symmetric_private
   end
end


