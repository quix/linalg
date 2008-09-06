/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#ifndef DCOMPLEX_H
#define DCOMPLEX_H

#include <stdlib.h>
#include <math.h>

#include <g2c.h>

#include "ruby.h"

#include "linalg.h"

VALUE rb_dcomplex_new(doublecomplex c) ;
doublecomplex rb_num2doublecomplex(VALUE num) ;

VALUE rb_dcomplex_new(doublecomplex a) ;
doublecomplex rb_num2doublecomplex(VALUE ra) ;
VALUE rb_dcomplex_initialize(int argc, VALUE* argv, VALUE self) ;
VALUE rb_dcomplex_real(VALUE self) ;
VALUE rb_dcomplex_imag(VALUE self) ;
VALUE rb_dcomplex_add(VALUE self, VALUE rb) ;
VALUE rb_dcomplex_sub(VALUE self, VALUE rb) ;
VALUE rb_dcomplex_mul(VALUE self, VALUE rb) ;
VALUE rb_dcomplex_div(VALUE self, VALUE rb) ;
VALUE rb_dcomplex_within(VALUE self, VALUE repsilon, VALUE rb) ;
VALUE rb_dcomplex_conj(VALUE self) ;
VALUE rb_dcomplex_abs(VALUE self) ;
VALUE rb_dcomplex_abs2(VALUE self) ;
VALUE rb_dcomplex_coerce(VALUE self, VALUE other) ;
VALUE rb_dcomplex_to_doublecomplex_ptr(VALUE self) ;
VALUE rb_dcomplex_doubleequals(VALUE self, VALUE rb) ;
    
#endif
