/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#include "ruby.h"
#include "linalg.h"

VALUE rb_cLinalg ;
VALUE rb_cLinalgException ;
VALUE rb_eDimensionError ;

void Init_dcomplex(void) ;
void Init_scomplex(void) ;

void Init_xdata(void) ;

void Init_dmatrix(void) ;
void Init_smatrix(void) ;
void Init_zmatrix(void) ;
void Init_cmatrix(void) ;

void raise_bad_array()
{
    rb_raise(rb_eRuntimeError, "invalid array") ;
}

void raise_dim_error()
{
    rb_raise(rb_eDimensionError, "") ;
}

void raise_index_error()
{
    rb_raise(rb_eIndexError, "out of range") ;
}

void Init_linalg()
{
    rb_cLinalg = rb_define_module("Linalg") ;

    Init_dcomplex() ;
    Init_scomplex() ;

    Init_xdata() ;

    Init_dmatrix() ;
    Init_smatrix() ;
    Init_zmatrix() ;
    Init_cmatrix() ;
}


