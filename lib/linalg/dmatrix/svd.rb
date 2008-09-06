#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # call-seq:
      #   singular_value_decomposition  => [u, s, vt]
      #   singular_value_decomposition { |u, s, vt| ... }  => block result
      #
      # Decompose the +m+ x +n+ matrix into
      #
      #   u * s * vt
      #
      # where +u+ and +vt+ are orthogonal matrices and +s+ is an +m+ x +n+
      # matrix whose non-diagonal elements are all zero.  The diagonal
      # elements of +s+ are called the <em>singular values</em> of the
      # matrix.  If called with
      #   m.singular_value_decomposition(:diagonalize => false)
      # then +s+ is a vector of singular values rather than a diagonal
      # matrix.
      #
      # May raise +Diverged+.
      #
      def singular_value_decomposition(opts = nil, &b)
         if opts
            svd_private(true, opts[:diagonalize], &b)
         else
            svd_private(true, true, &b)
         end
      end

      #
      # call-seq:
      #   singular_values  => s
      #   singular_values { |s| .. }  => block result
      #
      # Returns a vector containing the singular values of the matrix.  See
      # DMatrix#singular_value_decomposition.
      #
      def singular_values(&b)
         svd_private(false, false, &b)
      end

      private

      def svd_private(decomp, diagonalize)
         jobu = Char.new(decomp ? "A" : "N")
         jobvt = Char.new(decomp ? "A" : "N")
         m = XInteger.new(vsize)
         n = XInteger.new(hsize)
         a = self.clone
         lda = XInteger.new(a.vsize)
         s = DMatrix.new(Math.min(vsize, hsize), 1)
         u =  decomp ? DMatrix.reserve(vsize, vsize) : DMatrix.reserve(1, 1)
         ldu = XInteger.new(u.vsize)
         vt = decomp ? DMatrix.reserve(hsize, hsize) : DMatrix.reserve(1, 1)
         ldvt = XInteger.new(vt.vsize)
         work = DReal.new
         lwork = XInteger.new(-1) # query
         info = XInteger.new

         # query
         Lapack.dgesvd(jobu,
                       jobvt,
                       m,
                       n,
                       a,
                       lda,
                       s,
                       u,
                       ldu,
                       vt,
                       ldvt,
                       work,
                       lwork,
                       info)
         
         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)
         
         Lapack.dgesvd(jobu,
                       jobvt,
                       m,
                       n,
                       a,
                       lda,
                       s,
                       u,
                       ldu,
                       vt,
                       ldvt,
                       work,
                       lwork,
                       info)
         
         if decomp
            if diagonalize
               sm = DMatrix.new(vsize, hsize)
               Math.min(vsize, hsize).times { |i|
                  sm[i, i] = s[i]
               }
               res = [u, sm, vt]
            else
               res = [u, s, vt]
            end
         else
            res = s
         end

         if block_given?
            yield res
         else
            res
         end
      end
   end
end


