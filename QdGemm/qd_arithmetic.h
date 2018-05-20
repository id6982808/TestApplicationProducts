#ifndef _INC_QD_ARITHMETIC_HEADER
#define _INC_QD_ARITHMETIC_HEADER

#include "serial_arithmetic.h"

inline void QD_sloppy_ADD(double *a, double *b, double *c)
{
  double s0, s1, s2, s3;
  double t0, t1, t2, t3;

  double v0, v1, v2, v3;
  double u0, u1, u2, u3;
  double w0, w1, w2, w3;

  s0 = a[0] + b[0];
  s1 = a[1] + b[1];
  s2 = a[2] + b[2];
  s3 = a[3] + b[3];

  v0 = s0 - a[0];
  v1 = s1 - a[1];
  v2 = s2 - a[2];
  v3 = s3 - a[3];

  u0 = s0 - v0;
  u1 = s1 - v1;
  u2 = s2 - v2;
  u3 = s3 - v3;

  w0 = a[0] - u0;
  w1 = a[1] - u1;
  w2 = a[2] - u2;
  w3 = a[3] - u3;

  u0 = b[0] - v0;
  u1 = b[1] - v1;
  u2 = b[2] - v2;
  u3 = b[3] - v3;

  t0 = w0 + u0;
  t1 = w1 + u1;
  t2 = w2 + u2;
  t3 = w3 + u3;

  s1 = two_sum(s1, t0, &t0);
  three_sum(&s2, &t0, &t1);
  three_sum2(&s3, &t0, &t2);
  t0 = t0 + t1 + t3;

  /* renormalize */
  renorm5(&s0, &s1, &s2, &s3, &t0);

  c[0]=s0;
  c[1]=s1;
  c[2]=s2;
  c[3]=s3;
}

inline void QD_sloppy_MUL(double *a, double *b, double *c)
{
  double p0, p1, p2, p3, p4, p5;
  double q0, q1, q2, q3, q4, q5;
  double t0, t1;
  double s0, s1, s2;
/*
  p0 = two_prod(a[0], b[0], &q0);
  p1 = two_prod(a[0], b[1], &q1);
  p2 = two_prod(a[1], b[0], &q2);
  p3 = two_prod(a[0], b[2], &q3);
  p4 = two_prod(a[1], b[1], &q4);
  p5 = two_prod(a[2], b[0], &q5);
*/

  p0 = two_prod_fma(a[0], b[0], &q0);
  p1 = two_prod_fma(a[0], b[1], &q1);
  p2 = two_prod_fma(a[1], b[0], &q2);
  p3 = two_prod_fma(a[0], b[2], &q3);
  p4 = two_prod_fma(a[1], b[1], &q4);
  p5 = two_prod_fma(a[2], b[0], &q5);


  /* Start Accumulation */
  three_sum(&p1, &p2, &q0);

  /* Six-Three Sum  of p2, q1, q2, p3, p4, p5. */
  three_sum(&p2, &q1, &q2);
  three_sum(&p3, &p4, &p5);
  /* compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5). */
  s0 = two_sum(p2, p3, &t0);
  s1 = two_sum(q1, p4, &t1);
  s2 = q2 + p5;
  s1 = two_sum(s1, t0, &t0);
  s2 += (t0 + t1);

  /* O(eps^3) order terms */
  s1 += a[0]*b[3] + a[1]*b[2] + a[2]*b[1] + a[3]*b[0] + q0 + q3 + q4 + q5;
  renorm5(&p0, &p1, &s0, &s1, &s2);
  
  c[0]=p0;
  c[1]=p1;
  c[2]=s0;
  c[3]=s1;
}

inline void QD_sloppy_SUB(double *a, double *b, double *c)
{
  double tmp[4];
  
  tmp[0]=-b[0];
  tmp[1]=-b[1];
  tmp[2]=-b[2];
  tmp[3]=-b[3];
  
  QD_sloppy_ADD(a, tmp, c);
}

inline void QD_sloppy_DIV(double *a, double *b, double *c)
{
  double q0, q1, q2, q3;

  double r[4], tmp[4]={0.0, 0.0, 0.0, 0.0};

  q0 = a[0] / b[0];
  //r = a - (b * q0);
  tmp[0]=q0;
  QD_sloppy_MUL(b, tmp, tmp);
  QD_sloppy_SUB(a, tmp, r);

  q1 = r[0] / b[0];
  //r -= (b * q1);
  tmp[0]=q1; tmp[1]=0.0; tmp[2]=0.0; tmp[3]=0.0;
  QD_sloppy_MUL(b, tmp, tmp);
  QD_sloppy_SUB(r, tmp, r);
  
  q2 = r[0] / b[0];
  //r -= (b * q2);
  tmp[0]=q2; tmp[1]=0.0; tmp[2]=0.0; tmp[3]=0.0;
  QD_sloppy_MUL(b, tmp, tmp);
  QD_sloppy_SUB(r, tmp, r);
  
  q3 = r[0] / b[0];

  renorm4(&q0, &q1, &q2, &q3);
  
  c[0]=q0;
  c[1]=q1;
  c[2]=q2;
  c[3]=q3;
}

#endif