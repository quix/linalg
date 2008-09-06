#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#


module Linalg
   class DMatrix
      #
      # call-seq:
      #   schur  => [z, t, real, imag]
      #   schur { |z, t, real, imag| ... }  => block result
      #
      # Decompose into
      #   z * t * z.t
      # where +z+ is orthogonal and +t+ is quasi upper-diagonal.
      # +real+ and +imag+ contain the respective eigenvalues in the format
      # described in DMatrix#eigensystem.
      # 
      def schur # :yields: z, t, real, imag
         raise DimensionError unless square?
         jobvs = Char.new("V")
         sort = Char.new("N")
         select = XData::NULL
         n = XInteger.new(vsize)
         a = self.clone
         lda = n
         sdim = XInteger.new
         wr = DMatrix.reserve(n.value, 1)
         wi = DMatrix.reserve(n.value, 1)
         vs = DMatrix.reserve(n.value, n.value)
         ldvs = n
         work = DReal.new  # query
         lwork = XInteger.new(-1) # query
         bwork = XData::NULL
         info = XInteger.new
         
         # query
         Lapack.dgees(jobvs,
                      sort,
                      select,
                      n,
                      a,
                      lda,
                      sdim,
                      wr,
                      wi,
                      vs,
                      ldvs,
                      work,
                      lwork,
                      bwork,
                      info)
         
         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)
         
         Lapack.dgees(jobvs,
                      sort,
                      select,
                      n,
                      a,
                      lda,
                      sdim,
                      wr,
                      wi,
                      vs,
                      ldvs,
                      work,
                      lwork,
                      bwork,
                      info)
         
         raise Diverged unless info.value == 0

         res = [vs, a, wr, wi]
         if block_given?
            yield res
         else
            res
         end
      end
   end
end


