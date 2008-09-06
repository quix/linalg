#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'linalg-test'

require 'linalg/xdata'
require 'linalg/dcomplex'
require 'linalg/scomplex'

class TestXData < Test::Unit::TestCase
   include XData
   def test_xdata
      [DData, SData, ZData, CData, IData].each { |klass|
         ($count/3).times {
            size = 1 + rand($dim*10)
            xdata = klass.new(size)
            if klass == DData || klass == SData
               array = Array.new(size) { rand }
            elsif klass == ZData
               array = Array.new(size) { DComplex.new(rand, rand) }
            elsif klass == CData
               array = Array.new(size) { SComplex.new(rand, rand) }
            else
               array = Array.new(size) { rand(100) }
            end
            
            array.each_index { |i|
               xdata[i] = array[i]
            }
            
            if klass == DData || klass == IData || klass == ZData
               xdata.each_with_index { |e, i|
                  assert_equal(e, array[i])
               }
            elsif
               # SData or CData
               xdata.each_with_index { |e, i|
                  assert_block { e.within(10e-6, array[i]) }
               }
            end

            assert_raises(IndexError) { xdata[-1] }
            assert_raises(IndexError) { xdata[size] }
            assert_raises(IndexError) { xdata[size + 1000] }

            val = if klass == DData || klass == SData
                     rand
                  elsif klass == ZData
                     DComplex.new(rand, rand)
                  elsif klass == CData
                     SComplex.new(rand, rand)
                  else
                     rand(10000)
                  end

            xdata.fill(val) 

            if klass == DData || klass == IData || klass == ZData
               xdata.each_with_index { |e, i|
                  assert_equal(e, val)
               }
            else
               # SData or CData
               xdata.each_with_index { |e, i|
                  assert_block { e.within(10e-6, val) }
               }
            end
         }
      }
   end
end

