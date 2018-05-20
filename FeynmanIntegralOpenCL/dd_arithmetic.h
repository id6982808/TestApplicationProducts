#ifndef _INC_DD_ARITHMETIC_HEADER
#define _INC_DD_ARITHMETIC_HEADER

#include "serial_arithmetic.h"

inline void DD_TwoSum(double *a, double *b, double *out)
{
    double t, r;

    t = two_sum(a[0], b[0], &r);
    r += (a[1] + b[1]);
    t = quick_two_sum(t, r, &r);
    out[0] = t;
    out[1] = r;
}

inline void DD_TwoProd(double *a, double *b, double *out)
{
    double p1, p2;

    p1 = two_prod(a[0], b[0], &p2);
    //p1 = two_prod_fma(a[0], b[0], &p2);
    p2 += (a[0] * b[1] + a[1] * b[0]);
    p1 = quick_two_sum(p1, p2, &p2);
    out[0] = p1;
    out[1] = p2;
}

inline void DD_TwoProdFMA(double *a, double *b, double *out)
{
    double p1, p2;

    p1 = two_prod_fma(a[0], b[0], &p2);
    p2 += (a[0] * b[1] + a[1] * b[0]);
    p1 = quick_two_sum(p1, p2, &p2);
    out[0] = p1;
    out[1] = p2;
}

inline void DD_TwoSub(double *a, double *b, double *c)
{
  double s1, s2, t1, t2;
  s1 = two_diff(a[0], b[0], &s2);
  t1 = two_diff(a[1], b[1], &t2);
  s2 += t1;
  s1 = quick_two_sum(s1, s2, &s2);
  s2 += t2;
  s1 = quick_two_sum(s1, s2, &s2);
  c[0]=s1;
	c[1]=s2;
}

inline void DD_TwoDiv(double *a, double *b, double *c)
{
  double s1, s2;
  double q1, q2;
  double r[2];
	double q1_dd[2];

	
  q1 = a[0] / b[0];  /* approximate quotient */
	q1_dd[0]=q1; q1_dd[1]=0.0;

  /* compute  this - q1 * dd */
  DD_TwoProd(b, q1_dd, r); //r = b * q1;
  s1 = two_diff(a[0], r[0], &s2);
  s2 -= r[1];
  s2 += a[1];

  /* get next approximation */
  q2 = (s1 + s2) / b[0];

  /* renormalize */
  r[0] = quick_two_sum(q1, q2, &r[1]);
  
	c[0]=r[0];
	c[1]=r[1];
}

#endif
