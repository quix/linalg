#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

#
# isomorphism C <--> M2(R)
#
# a + ib  <-->  [a  -b]
#               [b   a]
#
def isomorphic_complex(a, b = nil)
   c = DMatrix.new(2*a.vsize, 2*a.hsize)
   a.each_index { |i, j|
      c[2*i,     2*j    ] = a[i,j]
      c[2*i + 1, 2*j + 1] = a[i,j]
      if b
         c[2*i,     2*j + 1] = -b[i,j]
         c[2*i + 1, 2*j    ] =  b[i,j]
      end
   }
   c
end

class TestEigensystem < Test::Unit::TestCase

   def test_raise
      ($count/6).times {
         a = DMatrix.new(n = $dim/2 + rand($dim/2), n + 1 + rand($dim/2 - 1))
         assert_raises(DimensionError) { a.eigensystem { } }
         a = DMatrix.new(n = $dim + rand($dim), n - 1 - rand($dim/2 - 1))
         assert_raises(DimensionError) { a.eigensystem { } }
      }
   end

   def test_eigensystem
      ($count/4).times {
         dim = 1 + rand($dim)
         a = DMatrix.rand(dim, dim)
         begin
            eigs, real, imag = a.eigensystem
            
            a_c = isomorphic_complex(a)

            lambda_re = DMatrix.diagonal(dim) { |i| real[i] }
            lambda_im = DMatrix.diagonal(dim) { |i| imag[i] }
            lambda_c = isomorphic_complex(lambda_re, lambda_im)

            eigs_list = []
            j = 0
            while j < dim
               if imag[j] == 0.0
                  eigs_list.push isomorphic_complex(eigs.column(j))
                  j += 1
               else
                  assert_equal(real[j], real[j+1])
                  assert_equal(imag[j], -imag[j+1])
                  eigs_list.push isomorphic_complex(eigs.column(j),
                                                    eigs.column(j+1))
                  eigs_list.push isomorphic_complex(eigs.column(j),
                                                    -eigs.column(j+1))
                  j += 2
               end
            end
            
            eigs_c = DMatrix.new(2*dim, 2*dim)
            eigs_list.each_with_index { |c, j|
               eigs_c.replace_minor(0, 2*j, c)
            }
            
            assert_close(a_c*eigs_c, eigs_c*lambda_c)

            real2, imag2 = a.eigenvalues
            assert_close(real, real2)
            assert_close(imag, imag2)

         rescue Diverged
            puts "\nnote: divergent eigensystem:\n#{a.inspect}"
         end
      }
   end
end
