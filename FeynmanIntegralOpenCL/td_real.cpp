#ifndef _INC_TD_FUNCTION
#define _INC_TD_FUNCTION

#include "td_support.cpp"
#include "td_real.h"

td_real::td_real()
{
    x[0] = 0.0;
    x[1] = 0.0;
    x[2] = 0.0;
}

td_real::td_real(double in)
{
    x[0] = in;
    x[1] = 0.0;
    x[2] = 0.0;
}

td_real::td_real(qd_real in)
{
    x[0] = in.x[0];
    x[1] = in.x[1];
    x[2] = in.x[2];
}

td_real td_real::operator+(td_real obj)
{
    td_real tmp;

    TD_ADD(x, obj.x, tmp.x);

    return tmp;
}

td_real td_real::operator-(td_real obj)
{
    td_real tmp;

    TD_SUB(x, obj.x, tmp.x);

    return tmp;
}

td_real td_real::operator*(td_real obj)
{
    td_real tmp;

    TD_MUL(x, obj.x, tmp.x);

    return tmp;
}

td_real td_real::operator/(td_real obj)
{
    td_real tmp;

    TD_DIV(x, obj.x, tmp.x);

    return tmp;
}

bool td_real::operator=(double obj)
{
    x[0] = obj;
    x[1] = 0.0;
    x[2] = 0.0;

    return true;
}

bool td_real::operator=(qd_real obj)
{
    x[0] = obj[0];
    x[1] = obj[1];
    x[2] = obj[2];

    return true;
}

bool td_real::operator=(td_real obj)
{
    x[0] = obj.x[0];
    x[1] = obj.x[1];
    x[2] = obj.x[2];

    return true;
}

qd_real td_real::toQDreal()
{
    qd_real ret;

    ret[0] = x[0];
    ret[1] = x[1];
    ret[2] = x[2];
    ret[3] = 0.0;

    return ret;
}

std::ostream & operator<<(std::ostream & os, const td_real & out)
{
    qd_real tmp;

    tmp.x[0] = out.x[0];
    tmp.x[1] = out.x[1];
    tmp.x[2] = out.x[2];

    os << tmp;
    return os;
}

#endif
