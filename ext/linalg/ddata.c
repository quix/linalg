/*
 * Copyright (c) 2004-2008 by James M. Lawrence
 *
 * See LICENSE
 *
 */

#include "xdata.h"

struct DData_
{
    doublereal* data ;
    int size ;
} ;

typedef struct DData_ DData ;

VALUE rb_cDData ;

#define get_ddata(ptr, obj) Data_Get_Struct(obj, DData, ptr)
#define wrap_ddata(obj) Data_Wrap_Struct(rb_cDData, 0, DData_free, obj)

void DData_free( DData* a )
{
    free(a->data) ;
    free(a) ;
}

static VALUE rb_ddata_s_alloc(VALUE klass)
{
    DData* a ;
    VALUE obj = Data_Make_Struct(klass,
                                 DData,
                                 0,
                                 DData_free,
                                 a) ;
    a->data = 0 ;
    a->size = 0 ;
    return obj ;
}

/*
 * call-seq:
 *   new(size)
 *   new(size) { |i| ... } 
 *
 * Create a contiguous array of LAPACK type <tt>doublereal</tt> of the
 * given size, assigning elements to the block.  If no block is given,
 * the data is left uninitialized.
 *
 */
VALUE rb_ddata_initialize(VALUE self, VALUE size)
{
    DData* a ;
    get_ddata(a, self) ;
    a->size = NUM2INT(size) ;
    a->data = (doublereal*)ALLOC_N(doublereal, a->size) ;

    if( rb_block_given_p() )
    {
        int i ;
        for( i = 0 ; i != a->size ; ++i )
        {
            VALUE rval = rb_yield(INT2FIX(i)) ;
            a->data[i] = NUM2DBL(rval) ;
        }
    }
    
    return self ;
}

/*
 * Array element read
 *
 */
VALUE rb_ddata_aref(int argc, VALUE* argv, VALUE self)
{
    DData* a ;
    VALUE rpos ;
    int pos ;

    rb_scan_args(argc, argv, "1", &rpos) ;
    pos = NUM2INT(rpos) ;
    get_ddata(a, self) ;

    if( pos < 0 || pos >= a->size )
    {
        rb_raise(rb_eIndexError, "") ;
    }

    return rb_float_new((double)a->data[pos]) ;
}

/*
 * Array element write
 *
 */
VALUE rb_ddata_aset(int argc, VALUE* argv, VALUE self)
{
    DData* a ;
    VALUE rpos ;
    VALUE rval ;
    int pos ;

    rb_scan_args(argc, argv, "2", &rpos, &rval) ;
    pos = NUM2INT(rpos) ;
    get_ddata(a, self) ;

    if( pos < 0 || pos >= a->size )
    {
        rb_raise(rb_eIndexError, "") ;
    }

    a->data[pos] = NUM2DBL(rval) ;

    return rval ;
}

/*
 * The entry point into the Lapack module.  Returns actual pointer
 * value of the data.
 *
 */
VALUE rb_ddata_to_doublereal_ptr( VALUE self )
{
    DData* a ;
    get_ddata(a, self) ;
    return ULONG2NUM((unsigned long)a->data) ;
}

/*
 * Fill the array with this value.
 *
 */
VALUE rb_ddata_fill( VALUE self, VALUE rval )
{
    DData* a ;
    get_ddata(a, self) ;
    
    {
        doublereal val = NUM2DBL(rval) ;
        doublereal* p = a->data ;
        doublereal* end = p + a->size ;
        
        for( ; p != end ; ++p )
        {
            *p = val ;
        }
    }

    return self ;
}

/*
 * For +Enumerable+
 *
 */
VALUE rb_ddata_each( VALUE self )
{
    DData* a ;
    get_ddata(a, self) ;
    
    {
        doublereal* p = a->data ;
        doublereal* end = p + a->size ;

        for( ; p != end ; ++p )
        {
            rb_yield(rb_float_new((double)*p)) ;
        }
    }

    return self ;
}

void Init_ddata()
{
    rb_cLinalg = rb_define_module("Linalg") ;
    rb_cXData = rb_define_module_under(rb_cLinalg, "XData") ;
    rb_cDData = rb_define_class_under(rb_cXData, "DData", rb_cObject) ;
    rb_include_module(rb_cDData, rb_mEnumerable) ;

    rb_define_alloc_func(rb_cDData, rb_ddata_s_alloc) ;

    rb_define_method(rb_cDData, "initialize", rb_ddata_initialize, 1) ;
    rb_define_method(rb_cDData, "[]", rb_ddata_aref, -1) ;
    rb_define_method(rb_cDData, "[]=", rb_ddata_aset, -1) ;
    rb_define_method(rb_cDData, "to_doublereal_ptr",
                     rb_ddata_to_doublereal_ptr, 0) ;
    rb_define_method(rb_cDData, "each", rb_ddata_each, 0) ;
    rb_define_method(rb_cDData, "fill", rb_ddata_fill, 1) ;
}


