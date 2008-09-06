#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # call-seq:
      #   lu  => [p, l, u]
      #   lu { |p, l, u| ... }  => block result
      #
      # Generalized LU decomposition for rectangular matrices.
      # The matrix is decomposed into
      #
      #   p * l * u
      #
      # where +p+ is a permutation matrix, +l+ lower-triangular
      # (or lower-trapezoidal), and +u+ is upper-triangular (or
      # upper-trapezoidal).
      #
      def lu # :yields: p, l, u
         res = lu_private(false)
         if block_given?
            yield res
         else
            res
         end
      end

      # 
      # call-seq:
      #   lu! => p
      #
      # In-place LU decomposition.  The matrix is overwritten with
      # both L and U factors (the diagonal 1's of L are discarded).
      # Returns the vector +p+ of pivots.
      #
      def lu!
         lu_private(true)
      end

      def zero_lower # :nodoc:
         if vsize > hsize
            hsize
         else
            vsize - 1
         end.times { |j|
            replace_minor(j + 1, j, DMatrix.new(vsize - j - 1, 1))
         }
         self
      end

      def zero_upper # :nodoc:
         # triangular portion
         (1...Math.min(vsize, hsize)).each { |j|
            replace_minor(0, j, DMatrix.new(j, 1))
         }
         
         if hsize > vsize
            # remaining
            replace_minor(0, hsize, hsize - vsize, vsize)
         end
         
         self
      end

      private

      def lu_private(inplace)
         minsize = Math.min(vsize, hsize)

         m = XInteger.new vsize
         n = XInteger.new hsize
         a = inplace ? self : self.clone
         lda = m
         ipiv = IData.new minsize
         info = XInteger.new

         Lapack.dgetrf(m,
                       n,
                       a,
                       lda,
                       ipiv,
                       info)

         raise SingularMatrix unless info.value == 0
         
         if inplace
            ipiv
         else
            p = DMatrix.identity(vsize)
            if vsize > hsize
               uvsize, uhsize = [minsize, minsize]
               lvsize, lhsize = [vsize, hsize]
            else
               uvsize, uhsize = [vsize, hsize]
               lvsize, lhsize = [minsize, minsize]
            end

            ipiv.each_with_index { |e, i|
               # 1-based fortran
               if i != e - 1
                  p.exchange_columns(i, e - 1)
               end
            }

            l = a.minor(0, 0, lvsize, lhsize).zero_upper
            minsize.times { |i| l[i, i] = 1.0 }
            u = a.minor(0, 0, uvsize, uhsize).zero_lower

            [p, l, u]
         end
      end
   end
end


