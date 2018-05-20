#ifndef _INC_SERIAL_ARITHMETIC_HEADER
#define _INC_SERIAL_ARITHMETIC_HEADER

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#define _QD_SPLITTER 134217729.0	// = 2^27 + 1 (for split func.)
#define _QD_SPLIT_THRESH 6.69692879491417e+299	// = 2^996 (for split func.)

typedef double2 dd_real;
typedef double4 qd_real;

inline double quick_two_sum(double a, double b, double *err) {
  double s = a + b;
  *err = b - (s - a);
  return s;
}

inline double quick_two_diff(double a, double b, double *err) {
  double s = a - b;
  *err = (a - s) - b;
  return s;
}

inline double two_sum(double a, double b, double *err) {
  double s = a + b;
  double bb = s - a;
  *err = (a - (s - bb)) + (b - bb);
  return s;
}

inline double two_diff(double a, double b, double *err) {
  double s = a - b;
  double bb = s - a;
  *err = (a - (s - bb)) - (b + bb);
  return s;
}

inline void split(double a, double *hi, double *lo)
{
    double temp;
/*
    if (a > _QD_SPLIT_THRESH || a < -_QD_SPLIT_THRESH) {
	a *= 3.7252902984619140625e-09;	// 2^-28
	temp = _QD_SPLITTER * a;
	*hi = temp - (temp - a);
	*lo = a - *hi;
	*hi *= 268435456.0;	// 2^28
	*lo *= 268435456.0;	// 2^28
    } else {
	temp = _QD_SPLITTER * a;
	*hi = temp - (temp - a);
	*lo = a - *hi;
    }
*/

  temp = _QD_SPLITTER * a;
	*hi = temp - (temp - a);
	*lo = a - *hi;
  
}

inline double two_prod(double a, double b, double *err)
{

    double a_hi, a_lo, b_hi, b_lo;
    double p = a * b;
    split(a, &a_hi, &a_lo);
    split(b, &b_hi, &b_lo);
    *err = ((a_hi * b_hi - p) + a_hi * b_lo + a_lo * b_hi) + a_lo * b_lo;
    return p;

}

inline double two_prod_fma(double a, double b, double *err)
{
    double p = a * b;
    *err = fma(a, b, -p);
    return p;
}

inline void three_sum(double *a, double *b, double *c)
{
    double t1, t2, t3;
    t1 = two_sum(*a, *b, &t2);
    *a = two_sum(*c, t1, &t3);
    *b = two_sum(t2, t3, c);
}

inline void three_sum2(double *a, double *b, double *c)
{
    double t1, t2, t3;
    t1 = two_sum(*a, *b, &t2);
    *a = two_sum(*c, t1, &t3);
    *b = t2 + t3;
}

inline void renorm4(double *c0, double *c1, double *c2, double *c3)
{
    double s0, s1, s2 = 0.0, s3 = 0.0;

    s0 = quick_two_sum(*c2, *c3, c3);
    s0 = quick_two_sum(*c1, s0, c2);
    *c0 = quick_two_sum(*c0, s0, c1);

    s0 = *c0;
    s1 = *c1;
    
    //s1 = quick_two_sum(s1, *c2, &s2);
	  //s2 = quick_two_sum(s2, *c3, &s3);
    
    

    if (s1 != 0.0) {
	s1 = quick_two_sum(s1, *c2, &s2);
	if (s2 != 0.0)
	    { s2 = quick_two_sum(s2, *c3, &s3);}
	else
	    {s1 = quick_two_sum(s1, *c3, &s2);}
    } else {
	s0 = quick_two_sum(s0, *c2, &s1);
	if (s1 != 0.0)
	    {s1 = quick_two_sum(s1, *c3, &s2);}
	else
	    {s0 = quick_two_sum(s0, *c3, &s1);}
    }

    
    *c0 = s0;
    *c1 = s1;
    *c2 = s2;
    *c3 = s3;
}

inline void renorm5(double *c0, double *c1, double *c2, double *c3, double *c4)
{
    double s0, s1, s2 = 0.0, s3 = 0.0;


    s0 = quick_two_sum(*c3, *c4, c4);
    s0 = quick_two_sum(*c2, s0, c3);
    s0 = quick_two_sum(*c1, s0, c2);
    *c0 = quick_two_sum(*c0, s0, c1);

    s0 = *c0;
    s1 = *c1;

    s0 = quick_two_sum(*c0, *c1, &s1);

    s1 = quick_two_sum(s1, *c2, &s2);
    s2 = quick_two_sum(s2, *c3, &s3);
    s3 += *c4;


/*
    if (s1 != 0.0) {
	s1 = quick_two_sum(s1, *c2, &s2);
	if (s2 != 0.0) {
	    s2 = quick_two_sum(s2, *c3, &s3);
	    if (s3 != 0.0)
		{s3 += *c4;}
	    else
		{s2 += *c4;}
	} else {
	    s1 = quick_two_sum(s1, *c3, &s2);
	    if (s2 != 0.0)
		{s2 = quick_two_sum(s2, *c4, &s3);}
	    else
		{s1 = quick_two_sum(s1, *c4, &s2);}
	}
    } else {
	s0 = quick_two_sum(s0, *c2, &s1);
	if (s1 != 0.0) {
	    s1 = quick_two_sum(s1, *c3, &s2);
	    if (s2 != 0.0)
		{s2 = quick_two_sum(s2, *c4, &s3);}
	    else
		{s1 = quick_two_sum(s1, *c4, &s2);}
	} else {
	    s0 = quick_two_sum(s0, *c3, &s1);
	    if (s1 != 0.0)
		{s1 = quick_two_sum(s1, *c4, &s2);}
	    else
		{s0 = quick_two_sum(s0, *c4, &s1);}
	}
    }
*/
    *c0 = s0;
    *c1 = s1;
    *c2 = s2;
    *c3 = s3;
}

#endif