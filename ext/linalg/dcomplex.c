/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#include "dcomplex.h"

/*******************************************************
 *
 * globals
 *
 *******************************************************/

VALUE rb_cDComplex ;

/*******************************************************
 *
 * utils
 *
 *******************************************************/

#define get_doublecomplex(ptr, obj) Data_Get_Struct(obj, doublecomplex, ptr)
#define wrap_doublecomplex(obj) Data_Wrap_Struct(rb_cDComplex, 0, rb_dcomplex_free, obj)

/*******************************************************
 *
 * alloc/free
 *
 *******************************************************/

void rb_dcomplex_free(doublecomplex* c)
{
    free(c) ;
}

VALUE rb_dcomplex_allocate(VALUE klass)
{
    doublecomplex* c ;
    VALUE rc = Data_Make_Struct(klass,
                                doublecomplex,
                                0,
                                rb_dcomplex_free,
                                c) ;
    return rc ;
}

/*******************************************************
 *
 * conversions
 *
 *******************************************************/

VALUE rb_dcomplex_new(doublecomplex a)
{
    doublecomplex* c = ALLOC(doublecomplex) ;
    *c = a ;
    return wrap_doublecomplex(c) ;
}

doublecomplex rb_num2doublecomplex(VALUE ra)
{
    if( rb_obj_is_kind_of(ra, rb_cDComplex) )
    {
        doublecomplex* a ;
        get_doublecomplex(a, ra) ;
        return *a ;
    }
    else
    {
        doublecomplex c ;
        c.r = (doublereal)NUM2DBL(ra) ;
        c.i = (doublereal)0.0 ;
        return c ;
    }
}

/*******************************************************
 *
 * instance methods
 *
 *******************************************************/

/*
 *
 */
VALUE rb_dcomplex_initialize(int argc, VALUE* argv, VALUE self)
{
    VALUE rre ;
    VALUE rim ;
    doublecomplex* a ;
    int n = rb_scan_args(argc, argv, "02", &rre, &rim) ;
    get_doublecomplex(a, self) ;

    if( n == 2 )
    {
        a->r = (doublereal)NUM2DBL(rre) ;
        a->i = (doublereal)NUM2DBL(rim) ;
    }
    else if( n == 1 )
    {
        a->r = (doublereal)NUM2DBL(rre) ;
        a->i = (doublereal)0.0 ;
    }
    else
    {
        a->r = (doublereal)0.0 ;
        a->i = (doublereal)0.0 ;
    }
    
    return self ;
}

VALUE rb_dcomplex_real(VALUE self)
{
    doublecomplex* a ;
    get_doublecomplex(a, self) ;
    return rb_float_new((double)a->r) ;
}

VALUE rb_dcomplex_imag(VALUE self)
{
    doublecomplex* a ;
    get_doublecomplex(a, self) ;
    return rb_float_new((double)a->i) ;
}

VALUE rb_dcomplex_add(VALUE self, VALUE rb)
{
    doublecomplex* a ;
    doublecomplex* c ;
    VALUE rc ;
    
    get_doublecomplex(a, self) ;
    c = ALLOC(doublecomplex) ;
    rc = wrap_doublecomplex(c) ;

    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        get_doublecomplex(b, rb) ;
        c->r = a->r + b->r ;
        c->i = a->i + b->i ;
    }
    else
    {
        doublereal b = (doublereal)NUM2DBL(rb) ;
        c->r = a->r + b ;
        c->i = a->i ;
    }
    
    return rc ;
}

VALUE rb_dcomplex_sub(VALUE self, VALUE rb)
{
    doublecomplex* a ;
    doublecomplex* c ;
    VALUE rc ;
    
    get_doublecomplex(a, self) ;
    c = ALLOC(doublecomplex) ;
    rc = wrap_doublecomplex(c) ;

    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        get_doublecomplex(b, rb) ;
        c->r = a->r - b->r ;
        c->i = a->i - b->i ;
    }
    else
    {
        doublereal b = (doublereal)NUM2DBL(rb) ;
        c->r = a->r - b ;
        c->i = a->i ;
    }
    
    return rc ;
}

VALUE rb_dcomplex_mul(VALUE self, VALUE rb)
{
    doublecomplex* a ;
    doublecomplex* c ;
    VALUE rc ;
    
    get_doublecomplex(a, self) ;
    c = ALLOC(doublecomplex) ;
    rc = wrap_doublecomplex(c) ;

    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        get_doublecomplex(b, rb) ;
        c->r = a->r*b->r - a->i*b->i ;
        c->i = a->r*b->i + a->i*b->r ;
    }
    else
    {
        doublereal b = (doublereal)NUM2DBL(rb) ;
        c->r = a->r*b ;
        c->i = a->i*b ;
    }
    
    return rc ;
}

VALUE rb_dcomplex_div(VALUE self, VALUE rb)
{
    doublecomplex* a ;
    doublecomplex* c ;
    VALUE rc ;
    
    get_doublecomplex(a, self) ;
    c = ALLOC(doublecomplex) ;
    rc = wrap_doublecomplex(c) ;

    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        doublereal bottom ;
        get_doublecomplex(b, rb) ;

        bottom = b->r*b->r + b->i*b->i ;
        
        c->r = a->r*b->r + a->i*b->i ;
        c->i = a->i*b->r - a->r*b->i ;

        c->r /= bottom ;
        c->i /= bottom ;
    }
    else
    {
        doublereal b = (doublereal)NUM2DBL(rb) ;
        c->r = a->r/b ;
        c->i = a->i/b ;
    }
    
    return rc ;
}

VALUE rb_dcomplex_within(VALUE self, VALUE repsilon, VALUE rb)
{
    doublecomplex* a ;
    doublereal epsilon ;

    get_doublecomplex(a, self) ;
    epsilon = (doublereal)NUM2DBL(repsilon) ;
    
    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        get_doublecomplex(b, rb) ;
        if( fabs(a->r - b->r) > epsilon ||
            fabs(a->i - b->i) > epsilon )
        {
            return Qfalse ;
        }
    }
    else
    {
        doublereal b = (doublereal)NUM2DBL(rb) ;
        if( fabs(a->r - b) > epsilon ||
            fabs(a->i - (doublereal)0.0) > epsilon )
        {
            return Qfalse ;
        }
    }

    return Qtrue ;
}

VALUE rb_dcomplex_conj(VALUE self)
{
    doublecomplex* a ;
    doublecomplex* c ;

    get_doublecomplex(a, self) ;
    c = ALLOC(doublecomplex) ;

    c->r = a->r ;
    c->i = -a->i ;
    
    return wrap_doublecomplex(c) ;
}

VALUE rb_dcomplex_abs(VALUE self)
{
    doublecomplex* c ;
    get_doublecomplex(c, self) ;
    return rb_float_new((double)(sqrt(c->r*c->r + c->i*c->i))) ;
}

VALUE rb_dcomplex_abs2(VALUE self)
{
    doublecomplex* c ;
    get_doublecomplex(c, self) ;
    return rb_float_new((double)(c->r*c->r + c->i*c->i)) ;
}

VALUE rb_dcomplex_coerce(VALUE self, VALUE other)
{
    return rb_assoc_new(self, other) ;
}

VALUE rb_dcomplex_to_doublecomplex_ptr(VALUE self)
{
    doublecomplex* c ;
    get_doublecomplex(c, self) ;
    return ULONG2NUM((unsigned long)c) ;
}

VALUE rb_dcomplex_doubleequals(VALUE self, VALUE rb)
{
    doublecomplex* a ;
    get_doublecomplex(a, self) ;

    if( rb_obj_is_kind_of(rb, rb_cDComplex) )
    {
        doublecomplex* b ;
        get_doublecomplex(b, rb) ;

        return (a->r == b->r && a->i == b->i) ? Qtrue : Qfalse ;
    }
    else
    {
        doublereal br = (doublereal)NUM2DBL(rb) ;
        return (a->r == br && a->i == ((doublereal)0.0)) ? Qtrue : Qfalse ;
    }
}

void Init_dcomplex()
{
    /* Linalg */
    rb_cLinalg = rb_define_module("Linalg") ;

    rb_cDComplex = rb_define_class_under(rb_cLinalg, "DComplex", rb_cObject) ;

    rb_define_alloc_func(rb_cDComplex, rb_dcomplex_allocate) ;
    rb_define_method(rb_cDComplex, "initialize", rb_dcomplex_initialize, -1) ;
    rb_define_method(rb_cDComplex, "real", rb_dcomplex_real, 0) ;
    rb_define_method(rb_cDComplex, "imag", rb_dcomplex_imag, 0) ;
    rb_define_method(rb_cDComplex, "+", rb_dcomplex_add, 1) ;
    rb_define_method(rb_cDComplex, "-", rb_dcomplex_sub, 1) ;
    rb_define_method(rb_cDComplex, "*", rb_dcomplex_mul, 1) ;
    rb_define_method(rb_cDComplex, "/", rb_dcomplex_div, 1) ;
    rb_define_method(rb_cDComplex, "conj", rb_dcomplex_conj, 0) ;
    rb_define_method(rb_cDComplex, "abs", rb_dcomplex_abs, 0) ;
    rb_define_method(rb_cDComplex, "abs2", rb_dcomplex_abs2, 0) ;
    rb_define_method(rb_cDComplex, "within", rb_dcomplex_within, 2) ;
    rb_define_method(rb_cDComplex, "coerce", rb_dcomplex_coerce, 1) ;
    rb_define_method(rb_cDComplex, "to_doublecomplex_ptr",
                     rb_dcomplex_to_doublecomplex_ptr, 0) ;
    rb_define_method(rb_cDComplex, "==", rb_dcomplex_doubleequals, 1) ;
}
    

