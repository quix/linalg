#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # Pseudo-inverse.
      #
      # For matrix +m+, find +x+ which minimizes
      #   (m*x - DMatrix.identity(m.vsize)).norm
      #
      def pseudo_inverse(epsilon = nil)
         DMatrix.fit(self, DMatrix.identity(vsize), epsilon)[0]
      end

      # call-seq:
      #   fit(a, b, epsilon = nil)  => x
      #   fit(a, b, epsilon = nil) { |x| ... }  => block value
      #
      # Least squares minimization using QR factorization.
      #
      # Find +x+ for which
      #   (a*x - b).norm_2
      # is a minimum.
      #
      # Assumes a matrix of full rank.
      #
      def self.fit(a, b)
         raise DimensionError unless a.vsize == b.vsize
         b_in = b

         trans = Char.new("N")
         m = XInteger.new(a.vsize)
         n = XInteger.new(a.hsize)
         nrhs = XInteger.new(b.hsize)
         a = a.clone
         lda = XInteger.new(a.vsize)
         b = DMatrix.new(Math.max(m.value, n.value),
                         nrhs.value).replace_minor(0, 0, b_in)
         ldb = XInteger.new(b.vsize)
         work = DReal.new # query
         lwork = XInteger.new(-1) # query
         info = XInteger.new
         
         # query
         Lapack.dgels(trans,
                      m,
                      n,
                      nrhs,
                      a,
                      lda,
                      b,
                      ldb,
                      work,
                      lwork,
                      info)
         
         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)
         
         Lapack.dgels(trans,
                      m,
                      n,
                      nrhs,
                      a,
                      lda,
                      b,
                      ldb,
                      work,
                      lwork,
                      info)
         
         raise Diverged unless info.value == 0

         x = b.minor(0, 0, n.value, nrhs.value)
         if block_given?
            yield x
         else
            x
         end
      end

      private

      #
      # call-seq:
      #   fit(a, b)  => [x, sv, rank]
      #   fit(a, b) { |x, sv, rank| ... }  => block value
      #
      # Least squares minimization using singular value decomposition
      # in conjunction with householder transformations.
      # Rank deficiency is allowed.
      #
      # Find +x+ for which
      #   (a*x - b).norm 
      # is a minimum.  (+norm+ is the 2-norm.)
      #
      # Also returns the singular values +sv+ and the +rank+.
      #
      # For matrix +m+, a singular value less than or equal to
      # <tt>m.norm*epsilon</tt> is considered a rank deficiency.  An
      # +epsilon+ of +nil+ (default) specifies machine precision.
      #
      # Disabled.  Crash from a tester.
      #
      def self.fit_svdhh(a, b, epsilon = nil) # :yields: x, sv, rank
         raise DimensionError unless a.vsize == b.vsize
         b_in = b

         m = XInteger.new(a.vsize)
         n = XInteger.new(a.hsize)
         nrhs = XInteger.new(b.hsize)
         a = a.clone
         lda = XInteger.new(a.vsize)
         b = nil
         ldb = XInteger.new(Math.max(m.value, n.value))
         b = DMatrix.new(ldb.value, nrhs.value)
         b.replace_minor(0, 0, b_in)
         s = DMatrix.new(Math.min(m.value, n.value), 1)
         rcond = DReal.new(epsilon ? epsilon : -1.0)
         rank = XInteger.new
         work = DReal.new # query
         lwork = XInteger.new(-1) # query
         # iwork defined below
         info = XInteger.new

         ###################################
         # ilaenv 
         ###################################
         ary_name = "dgelsd".split("")

         ispec = XInteger.new(9)
         name = CharData.new(ary_name.size) { |i| ary_name[i] }
         opts = Char.new("N")
         nX = XInteger.new(0)
         smlsiz = Lapack.ilaenv(ispec,
                                name,
                                opts,
                                nX,
                                nX,
                                nX,
                                nX)
         raise "ilaenv: bad parameter #{-smlsiz}" if smlsiz < 0
         
         ###################################
         # iwork
         ###################################
         minmn = Math.min(m.value, n.value)
         nlvl = Math.max(0, (Math.log2(minmn.to_f/(smlsiz + 1))).to_i + 1)
         iwork = IData.new(3*minmn*nlvl + 11*minmn)
                                
         ###################################
         # dgesld
         ###################################

         # query
         Lapack.dgelsd(m,
                       n,
                       nrhs,
                       a,
                       lda,
                       b,
                       ldb,
                       s,
                       rcond,
                       rank,
                       work,
                       lwork,
                       iwork,
                       info)
         
         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)
         
         Lapack.dgelsd(m,
                       n,
                       nrhs,
                       a,
                       lda,
                       b,
                       ldb,
                       s,
                       rcond,
                       rank,
                       work,
                       lwork,
                       iwork,
                       info)
         
         raise Diverged unless info.value == 0

         res = [b.minor(0, 0, n.value, nrhs.value), s, rank.value]
         if block_given?
            yield res
         else
            res
         end
      end
      
      #
      # call-seq:
      #   fit_svd(a, b)  => [x, sv, rank]
      #   fit_svd(a, b) { |x, sv, rank| ... }  => block value
      #
      # Least squares minimization with posible rank deficiency.
      # Uses singular value decomposition.
      #
      # Disabled.  Crash for unknown reason.
      #
      def self.fit_svd2(a, b)
         raise DimensionError unless a.vsize == b.vsize
         b_in = b

         m = XInteger.new a.vsize
         n = XInteger.new a.hsize
         nrhs = XInteger.new b.hsize
         a = a.clone
         lda = XInteger.new a.vsize
         # b
         ldb = XInteger.new Math.max(m.value, n.value)
         b = DMatrix.new(ldb.value, nrhs.value)
         b.replace_minor(0, 0, b_in)
         s = DMatrix.new(Math.min(m.value, n.value), 1)
         rcond = DReal.new(-1.0)  # use machine precision
         rank = XInteger.new
         work = DReal.new # query
         lwork = XInteger.new(-1) # query
         info = XInteger.new
         
         # query
         Lapack.dgelss(m,
                       n,
                       nrhs,
                       a,
                       lda,
                       b,
                       ldb,
                       s,
                       rcond,
                       rank,
                       work,
                       lwork,
                       info)
         
         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)
         
         Lapack.dgelss(m,
                       n,
                       nrhs,
                       a,
                       lda,
                       b,
                       ldb,
                       s,
                       rcond,
                       rank,
                       work,
                       lwork,
                       info)
         
         raise Diverged unless info.value == 0

         res = [b.minor(0, 0, a.hsize, b.hsize), s, rank.value]
         if block_given?
            yield res
         else
            res
         end
      end
   end
end

      
