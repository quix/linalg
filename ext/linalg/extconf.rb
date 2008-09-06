#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'mkmf'
require 'fileutils'

####################################################
#
# find LAPACK
#
####################################################

unless have_header("g2c.h") and
      have_library("g2c") and
      have_library("blas") and
      have_library("lapack")
   puts "A full LAPACK installation was not found."
   exit(-1)
end

####################################################
#
# FLAGS
#
####################################################

$CFLAGS += " -Wall" if CONFIG["CC"] == "gcc"

# why doesn't $INCFLAGS work
$CFLAGS += " -I../lapack/include"

$CFLAGS += ' -I.. -include g2c_typedefs.h'

####################################################
#
# Instantiator
#
####################################################

module Instantiator
   def self.instantiate(template)
      if template[:src] == template[:dst]
         raise "src is the same as dst" 
      end

      FileUtils.rm_f template[:dst]

      File.open(template[:src]) { |f|
         s = f.read
         template[:change].each_pair { |before, after|
            s.gsub!(%r!#{before}!m, after)
         }
         File.open(template[:dst], "w") { |out|
            out.puts s
         }
      }

      FileUtils.chmod 0444, template[:dst]
      $distcleanfiles = [] unless $distcleanfiles
      $distcleanfiles << template[:dst]
   end
end

####################################################
#
# instantiate xcomplex
#
####################################################

module InstantiateComplex
   change = {
      "doublecomplex" => "complex", 
      "dcomplex" => "scomplex",
      "doublereal" => "real",
      "DCOMPLEX" => "SCOMPLEX",
      "DComplex" => "SComplex",
   }
   
   templates = [
      {
         :src => "dcomplex.c",
         :dst => "scomplex.c",
         :change => change,
      },
      
      {
         :src => "dcomplex.h",
         :dst => "scomplex.h",
         :change => change,
      },
   ]
   
   templates.each { |t|
      Instantiator.instantiate(t)
   }
end

####################################################
#
# instantiate xdata
#
####################################################

module InstantiateXData
   templates = [
      {
         :dst => "sdata.c",
         :change => {
            "doublereal" => "real", 
            "DData" => "SData",
            "ddata" => "sdata",
            "DDATA" => "SDATA",
         }
      },
      
      {
         :dst => "idata.c",
         :change => {
            "doublereal" => "integer", 
            "rb_float_new" => "INT2NUM",
            "DData" => "IData",
            "ddata" => "idata",
            "double" => "int",
            "NUM2DBL" => "NUM2INT",
            "DDATA" => "IDATA"
         }
      },
      
      {
         :dst => "ldata.c",
         :change => {
            "doublereal" => "logical", 
            "rb_float_new" => "INT2NUM",
            "DData" => "LData",
            "ddata" => "ldata",
            "double" => "int",
            "NUM2DBL" => "NUM2INT",
            "DDATA" => "LDATA"
         }
      },
      
      {
         :dst => "chardata.c",
         :change => {
            "doublereal" => "char", 
            "rb_float_new" => "INT2NUM",
            "DData" => "CharData",
            "ddata" => "chardata",
            "double" => "int",
            "NUM2DBL" => "*StringValuePtr",
            "DDATA" => "CHARDATA"
         }
      },
      
      {
         :dst => "zdata.c",
         :change => {
            "doublereal" => "doublecomplex", 
            "rb_float_new" => "rb_dcomplex_new",
            "DData" => "ZData",
            "ddata" => "zdata",
            "\\(double\\)" => "",
            "NUM2DBL" => "rb_num2doublecomplex",
            "DDATA" => "ZDATA"
         }
      },
      
      {
         :dst => "cdata.c",
         :change => {
            "doublereal" => "complex", 
            "rb_float_new" => "rb_scomplex_new",
            "DData" => "CData",
            "ddata" => "cdata",
            "\\(double\\)" => "",
            "NUM2DBL" => "rb_num2complex",
            "DDATA" => "CDATA"
         }
      },
   ]

   templates.each { |t|
      t[:src] = "ddata.c"
      Instantiator.instantiate(t)
   }
end

####################################################
#
# instantiate xmatrix
#
####################################################

module InstantiateMatrices

   real = {
      "FORTRANTYPE" => "real", 
      "CLASSUPPER" => "SMatrix", 
      "CLASSLOWER" => "smatrix",
      "RUBY2FORTRAN" => "NUM2DBL",
      "FORTRAN2RUBY" => "rb_float_new",
      "xcopy_" => "scopy_",
      "xgemm_" => "sgemm_",
      "xscal_" => "sscal_",
      "xaxpy_" => "saxpy_",
      "xdot_" => "sdot_",
   }
   
   doublereal = {
      "FORTRANTYPE" => "doublereal", 
      "CLASSUPPER" => "DMatrix", 
      "CLASSLOWER" => "dmatrix",
      "RUBY2FORTRAN" => "NUM2DBL",
      "FORTRAN2RUBY" => "rb_float_new",
      "xcopy_" => "dcopy_",
      "xgemm_" => "dgemm_",
      "xscal_" => "dscal_",
      "xaxpy_" => "daxpy_",
      "xdot_" => "ddot_",
   }
   
   complex = {
      "FORTRANTYPE" => "complex", 
      "CLASSUPPER" => "CMatrix", 
      "CLASSLOWER" => "cmatrix",
      "RUBY2FORTRAN" => "rb_num2complex",
      "FORTRAN2RUBY" => "rb_scomplex_new",
      "xcopy_" => "ccopy_",
      "xgemm_" => "cgemm_",
      "xscal_" => "cscal_",
      "xaxpy_" => "caxpy_",
      "xdotc_" => "cdotc_",
   }
   
   doublecomplex = {
      "FORTRANTYPE" => "doublecomplex", 
      "CLASSUPPER" => "ZMatrix", 
      "CLASSLOWER" => "zmatrix",
      "RUBY2FORTRAN" => "rb_num2doublecomplex",
      "FORTRAN2RUBY" => "rb_dcomplex_new",
      "xcopy_" => "zcopy_",
      "xgemm_" => "zgemm_",
      "xscal_" => "zscal_",
      "xaxpy_" => "zaxpy_",
      "xdotc_" => "zdotc_",
   }
   
   templates = [
      {
         :src => "xmatrix.c.tmpl",
         :dst => "dmatrix.c",
         :change => doublereal
      },
      {
         :src => "xmatrix.h.tmpl",
         :dst => "dmatrix.h",
         :change => doublereal
      },
      {
         :src => "xmatrix.c.tmpl",
         :dst => "smatrix.c",
         :change => real
      },
      {
         :src => "xmatrix.h.tmpl",
         :dst => "smatrix.h",
         :change => real
      },
      {
         :src => "xmatrix.c.tmpl",
         :dst => "zmatrix.c",
         :change => doublecomplex
      },
      {
         :src => "xmatrix.h.tmpl",
         :dst => "zmatrix.h",
         :change => doublecomplex
      },
      {
         :src => "xmatrix.c.tmpl",
         :dst => "cmatrix.c",
         :change => complex
      },
      {
         :src => "xmatrix.h.tmpl",
         :dst => "cmatrix.h",
         :change => complex
      },
      {
         :src => "xmatrixr.c.tmpl",
         :dst => "dmatrixr.c",
         :change => doublereal
      },
      {
         :src => "xmatrixr.c.tmpl",
         :dst => "smatrixr.c",
         :change => real
      },
      {
         :src => "xmatrixc.c.tmpl",
         :dst => "zmatrixc.c",
         :change => doublecomplex
      },
      {
         :src => "xmatrixc.c.tmpl",
         :dst => "cmatrixc.c",
         :change => complex
      },
   ]
   
   templates.each { |t|
      Instantiator.instantiate(t)
   }
end

####################################################
#
# create Makefile
#
####################################################

create_makefile('linalg')


