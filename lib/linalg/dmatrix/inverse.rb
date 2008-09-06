#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix

      #
      # call-seq: inverse
      #
      # Matrix inverse.  Raises +SingularMatrix+ if the matrix is
      # singular.
      #
      def inverse
         inverse_private(false)
      end

      #
      # call-seq: inverse!
      #
      # In-place matrix inverse.  Raises +SingularMatrix+ if the matrix is
      # singular.
      #
      #   a.object_id == a.inverse!.object_id
      #
      def inverse!
         inverse_private(true)
      end
         
      private
      
      def inverse_private(inplace)
         raise DimensionError unless square?

         m = XInteger.new(vsize)
         n = m
         a = inplace ? self : self.clone
         lda = XInteger.new(n.value)
         ipiv = IData.new(n.value)
         info = XInteger.new
         
         Lapack.dgetrf(m,
                       n,
                       a,
                       lda,
                       ipiv,
                       info)

         raise SingularMatrix unless info.value == 0 
         work = DReal.new # query
         lwork = XInteger.new(-1) # query

         Lapack.dgetri(n,
                       a,
                       lda,
                       ipiv,
                       work,
                       lwork,
                       info)
         
         raise SingularMatrix unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)

         Lapack.dgetri(n,
                       a,
                       lda,
                       ipiv,
                       work,
                       lwork,
                       info)
         a
      end
   end
end
