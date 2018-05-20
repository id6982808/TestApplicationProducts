#ifndef _INC_TD_ARITHMETIC_HEADER
#define _INC_TD_ARITHMETIC_HEADER

#include "serial_arithmetic.h"

inline void TD_ADD(double *a, double *b, double *retAns)
{
    // sloppy-add
  double s0, s1, s2;
  double t0, t1, t2;
  
  s0 = two_sum(a[0], b[0], &t0);
  s1 = two_sum(a[1], b[1], &t1);
  s2 = two_sum(a[2], b[2], &t2);

  s1 = two_sum(s1, t0, &t0);
  three_sum(&s2, &t0, &t1);
  t0 = t0 + t1 + t2;

  //renorm4(&s0, &s1, &s2, &t0);
  td_renorm4(&s0, &s1, &s2, &t0);

    retAns[0] = s0;
    retAns[1] = s1;
    retAns[2] = s2;
}

inline void TD_SUB(double *a, double *b, double *retAns)
{
  double minus_b[3];
  
  minus_b[0] = -b[0];
  minus_b[1] = -b[1];
  minus_b[2] = -b[2];
  
  TD_ADD(a, minus_b, retAns);
}

inline void TD_MUL(double *a, double *b, double *retAns)
{
    double p0, p1, p2, p3, p4, p5;
    double q0, q1, q2, q3, q4, q5;
    double t0, t1;
    double s0, s1 = 0.0, s2 = 0.0;


    p0 = two_prod(a[0], b[0], &q0);
    p1 = two_prod(a[0], b[1], &q1);
    p2 = two_prod(a[1], b[0], &q2);
    p3 = two_prod(a[0], b[2], &q3);
    p4 = two_prod(a[1], b[1], &q4);
    p5 = two_prod(a[2], b[0], &q5);

/*
    p0 = two_prod_fma(a[0], b[0], &q0);
    p1 = two_prod_fma(a[0], b[1], &q1);
    p2 = two_prod_fma(a[1], b[0], &q2);
    p3 = two_prod_fma(a[0], b[2], &q3);
    p4 = two_prod_fma(a[1], b[1], &q4);
    p5 = two_prod_fma(a[2], b[0], &q5);
*/
    three_sum(&p1, &p2, &q0);

    three_sum(&p2, &q1, &q2);
    three_sum(&p3, &p4, &p5);
    
    s0 = two_sum(p2, p3, &t0);
    //s1 = two_sum(q1, p4, &t1);
    ////s2 = q2 + p5;
    //s1 = two_sum(s1, t0, &t0);
    ////s2 += (t0 + t1);

    //s1 += a[1] * b[2] + a[2] * b[1] + q0 + q3 + q4 + q5;

    //renorm4(&p0, &p1, &s0, &s1);
    //td_renorm4(&p0, &p1, &s0, &s1);

    retAns[0] = p0;
    retAns[1] = p1;
    retAns[2] = s0;
}

inline void TD_DIV(double *a, double *b, double *retAns)
{
  double q0, q1, q2, q3;

  double r[3], tmp[3]={0.0, 0.0, 0.0};

  q0 = a[0] / b[0];
  tmp[0]=q0;
  TD_MUL(b, tmp, tmp);
  TD_SUB(a, tmp, r);

  q1 = r[0] / b[0];
  tmp[0]=q1; tmp[1]=0.0; tmp[2]=0.0;
  TD_MUL(b, tmp, tmp);
  TD_SUB(r, tmp, r);
  
  q2 = r[0] / b[0];
  tmp[0]=q2; tmp[1]=0.0; tmp[2]=0.0;
  TD_MUL(b, tmp, tmp);
  TD_SUB(r, tmp, r);
  
  q3 = r[0] / b[0];

  //renorm4(&q0, &q1, &q2, &q3);
  //td_renorm4(&q0, &q1, &q2, &q3);
  
  retAns[0]=q0;
  retAns[1]=q1;
  retAns[2]=q2;
}

#endif
