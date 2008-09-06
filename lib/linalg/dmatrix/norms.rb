#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

module Linalg
   class DMatrix
      #
      # The 2-norm.  The largest singular value.
      #
      def norm_2
         singular_values[0]
      end

      #
      # call-seq: norm_1
      #
      # The 1-norm.  Maximum column absolute sum.
      # For matrix +m+, equivalent to
      #
      #   m.columns.map { |col|
      #      col.elems.inject(0.0) { |acc, e| acc + e.abs }
      #   }.sort[-1]
      #
      def norm_1
         private_norm(Char.new("1"), NULL)
      end
      
      #
      # call-seq: norm_inf
      #
      # The infinity-norm.  Maximum row absolute sum.
      # For matrix +m+, equivalent to
      #
      #   m.rows.map { |row|
      #      row.elems.inject(0.0) { |acc, e| acc + e.abs }
      #   }.sort[-1]
      #
      def norm_inf
         private_norm(Char.new("I"), DData.new(vsize))
      end

      #
      # call-seq: norm_f
      #
      #
      # Frobenius norm.  Square root of the sum of the squares of the
      # elements.
      #
      # For matrix +m+, equivalent to
      #
      #   Math.sqrt(m.elems.inject(0.0) { |acc, e| acc + e*e })
      #
      #
      def norm_f
         private_norm(Char.new("F"), NULL)
      end

      #
      # call-seq: maxabs
      #
      # The maximum absolute value of the individual matrix elements.
      # For matrix +m+, equivalent to
      #
      #   m.elems.map { |e| e.abs }.to_a.flatten.sort[-1]
      #
      # Note +maxabs+ is not a matrix norm.
      #
      #
      def maxabs
         private_norm(Char.new("M"), NULL)
      end

      private

      def private_norm(kind, work)
         m = XInteger.new(vsize)
         n = XInteger.new(hsize)
         Lapack.dlange(kind,
                       m,
                       n,
                       self,
                       m,
                       work)
      end
   end
end
