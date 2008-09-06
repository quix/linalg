#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      
      #
      # call-seq: solve(a, b)
      # 
      # Solve the linear equation
      #
      #   a * x == b
      #
      # Returns the solution +x+, or raises +SingularMatrix+ if +a+ was
      # singular.
      #
      #
      def self.solve(a, b)
         solve_private(a, b, false)
      end

      #
      # call-seq: solve!(a, b)
      # 
      # Solve the linear equation
      #
      #   a * x == b
      #
      # +a+ and +b+ are *both* *overwritten*.
      #
      # If a unique solution is found, +a+ contains both L and U factors
      # while +b+ holds the solution +x+ above.
      #
      # Returns the solution +x+, or raises +SingularMatrix+ if +a+ was
      # singular.
      #
      #   x = DMatrix.solve!(a, b)
      #   x.object_id == b.object_id
      #
      #
      def self.solve!(a, b)
         solve_private(a, b, true)
      end

      private

      def self.solve_private(a, b, inplace)
         unless a.square? and a.vsize == b.vsize
            raise DimensionError
         end
    
         n = XInteger.new(a.vsize)
         nrhs = XInteger.new(b.hsize)
         a = inplace ? a : a.clone
         lda = XInteger.new(a.vsize)
         ipiv = IData.new(n.value)
         b = inplace ? b : b.clone
         ldb = XInteger.new(b.vsize)
         info = XInteger.new

         Lapack.dgesv(n,
                      nrhs,
                      a,
                      lda,
                      ipiv,
                      b,
                      ldb,
                      info)
         
         raise SingularMatrix unless info.value == 0
         b
      end
   end
end
