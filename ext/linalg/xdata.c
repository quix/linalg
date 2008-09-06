
#include "xdata.h"

VALUE rb_cXData ;

void Init_xdata()
{
    rb_cXData = rb_define_module_under(rb_cLinalg, "XData") ;

    Init_sdata() ;
    Init_ddata() ;

    Init_cdata() ;
    Init_zdata() ;

    Init_ldata() ;
    Init_idata() ;

    Init_chardata() ;
}

