#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#



module Linalg
   class DMatrix

      #
      # call-seq:
      #    eigensystem  => [eigvs, real, imag]
      #    eigensystem { |eigvs, real, imag| ... } => block result
      #
      # Find the eigenvectors and eigenvalues of the matrix.
      #
      # The columns of +eigvs+ hold the eigenvectors; the column vectors
      # +real+ and +imag+ hold the eigenvalues.
      #
      # Stepping through the eigenvalues in succession starting from the
      # beginning, one will encounter either a real eigenvalue or a complex
      # conjugate pair.  That is, either the imaginary part will be exactly
      # equal to zero
      #
      #   imag[n] == 0.0
      #
      # or there will be a conjugate pair with the following exactly equal,
      #
      #   real[n] == real[n+1]
      #   imag[n] == -imag[n+1]
      #
      # In the former case, the real eigenvector
      #
      #   eigvs.column(n)
      #
      # corresponds to the real eigenvalue
      #
      #   real[n]
      #
      # In the latter case, the complex eigenvector
      #
      #   eigvs.column(n) + i*eigvs.column(n+1)
      #
      # corresponds to the complex eigenvalue
      #
      #   real[n] + i*imag[n]
      #
      # and the conjugate eigenvector
      #
      #   eigvs.column(n) - i*eigvs.column(n+1)
      #
      # corresponds to the conjugate eigenvalue
      #
      #   real[n] - i*imag[n]
      #
      # for <tt>i = sqrt(-1)</tt>.
      #
      # The eigenvectors are each given unit length with largest component
      # real.
      #
      # Raises +DimensionError+ if the given matrix is not square.  May
      # raise +Diverged+.
      #
      def eigensystem(&b)
         eigen_private(true, &b)
      end

      #
      # call-seq:
      #   eigenvalues  => [real, imag]
      #   eigenvalues { |real, imag| ... } => block result 
      #
      # Returns the eigenvalues.  See DMatrix#eigensystem for the format in
      # which eigenvalues are returned.
      #
      def eigenvalues(&b)
         eigen_private(false, &b)
      end
      
      private

      def eigen_private(vecs)
         raise DimensionError unless square?

         jobvl = Char.new("N")
         jobvr = Char.new(vecs ? "V" : "N")
         n = XInteger.new(vsize)
         a = self.clone
         lda = XInteger.new(n.value)
         wr = DMatrix.reserve(n.value, 1)
         wi = DMatrix.reserve(n.value, 1)
         vl = XData::NULL
         ldvl = XInteger.new(1)
         vr = DMatrix.reserve(n.value, n.value)
         ldvr = XInteger.new(n.value)
         work = DReal.new # query
         lwork = XInteger.new(-1) # query
         info = XInteger.new
         
         # query
         Lapack.dgeev(jobvl,
                      jobvr,
                      n,
                      a,
                      lda,
                      wr,
                      wi,
                      vl,
                      ldvl,
                      vr,
                      ldvr,
                      work,
                      lwork,
                      info)

         raise Diverged unless info.value == 0
         lwork = XInteger.new(work.value.to_i)
         work = DData.new(lwork.value)

         Lapack.dgeev(jobvl,
                      jobvr,
                      n,
                      a,
                      lda,
                      wr,
                      wi,
                      vl,
                      ldvl,
                      vr,
                      ldvr,
                      work,
                      lwork,
                      info)
         
         raise Diverged unless info.value == 0
         
         if vecs
            res = [vr, wr, wi]
         else
            res =  [wr, wi]
         end

         if block_given?
            yield res
         else
            res
         end
      end
   end
end

