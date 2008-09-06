#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   class DMatrix
      #
      # call-seq:
      #   qr  => [q, r]
      #   qr { |q, r| ... }  => block result
      #
      # QR factorization.  Decompose the matrix into
      #   q * r
      # where +q+ is orthogonal and +r+ is upper-triangular.
      #
      def qr # :yields: q, r
         res = qr_private(false)
         if block_given?
            yield res
         else
            res
         end
      end

      #
      # In-place QR factorization.  The contents of the matrix are
      # left in the state returned by dgeqrf().
      #
      def qr!
         qr_private(true)
      end

      private

      def qr_private(inplace)
         mindim = Math.min(vsize, hsize)

         m = XInteger.new(vsize)
         n = XInteger.new(hsize)
         a = inplace ? self : self.clone
         lda = m
         tau = DData.new(mindim)
         work = DReal.new  # query
         lwork = XInteger.new(-1)  # query
         info = XInteger.new

         # query
         Lapack.dgeqrf(m,
                       n,
                       a,
                       lda,
                       tau,
                       work,
                       lwork,
                       info)

         raise Diverged unless info.value == 0
         lwork[0] = work[0].to_i
         work = DData.new(lwork[0])
         
         Lapack.dgeqrf(m,
                       n,
                       a,
                       lda,
                       tau,
                       work,
                       lwork,
                       info)
         
         raise Diverged unless info.value == 0

         return self if inplace
         
         r = a.clone.zero_lower
         
         iden = DMatrix.identity(vsize)
         q = iden.clone

         v = DMatrix.reserve(vsize, 1)

         transa = Char.new("N")
         transb = Char.new("T")
         alpha = DReal.new
         neg_one = DReal.new(-1.0)
         one = XInteger.new(1)
         d_one = DReal.new(1.0)
         
         mindim.times { |p|
            v.fill(0.0)
            v[p] = 1.0
            if p < vsize - 1
               v.replace_minor(p + 1, 0, a.minor(p + 1,
                                                 p,
                                                 vsize - p - 1,
                                                 1))
            end
            
            # using dgemm instead
            #h = iden - tau[p]*v*v.t

            # this is not worth it ...
            alpha[0] = -tau[p]
            h = iden.clone
            Lapack.dgemm(transa,
                         transb,
                         m, # m
                         m, # n
                         one, # k
                         alpha,
                         v, # a
                         m, # lda
                         v, # b
                         m, # ldb
                         d_one, # beta
                         h, # c
                         m) # ldc
            q.postmul!(h)
         }
         
         [q, r]
      end
   end
end




