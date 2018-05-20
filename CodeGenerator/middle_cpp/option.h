#ifndef _INC_SET_OPTION_H
#define _INC_SET_OPTION_H

//#define D
//#define DD
//#define TD
//#define QD

#ifdef D
#define _add "add"
#define _sub "sub"
#define _mul "mul"
#define _div "div"
#define _prec "d"
#endif

#ifdef DD
#define _add "DD_TwoSum"
#define _sub "DD_TwoSub"
#define _mul "DD_TwoProd"
#define _div "DD_TwoDiv"
#define _prec "dd"
#endif

#ifdef TD
#define _add "TD_ADD"
#define _sub "TD_SUB"
#define _mul "TD_MUL"
#define _div "TD_DIV"
#define _prec "td"
#endif

#ifdef QD
#define _add "QD_sloppy_ADD"
#define _sub "QD_sloppy_SUB"
#define _mul "QD_sloppy_MUL"
#define _div "QD_sloppy_DIV"
#define _prec "qd"
#endif

#endif
