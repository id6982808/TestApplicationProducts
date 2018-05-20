#ifndef _INC_TD_SUPPORT
#define _INC_TD_SUPPORT

#include <sys/time.h>
#include <qd/qd_real.h>

#define _QD_SPLITTER 134217729.0	// = 2^27 + 1
#define _QD_SPLIT_THRESH 6.69692879491417e+299	// = 2^996

double quick_two_sum(double a, double b, double *err);
double quick_two_diff(double a, double b, double *err);
double two_sum(double a, double b, double *err);
double two_diff(double a, double b, double *err);
void split(double a, double *hi, double *lo);
double two_prod(double a, double b, double *err);
void three_sum(double *a, double *b, double *c);
void three_sum2(double *a, double *b, double *c);
void renorm4(double *c0, double *c1, double *c2, double *c3);
void renorm5(double *c0, double *c1, double *c2, double *c3, double *c4);
void QD_sloppy_ADD(double *a, double *b, double *c);
void QD_sloppy_MUL(double *a, double *b, double *c);
void QD_sloppy_SUB(double *a, double *b, double *c);
void QD_sloppy_DIV(double *a, double *b, double *c);
void TD_ADD(double *a, double *b, double *c);
void TD_SUB(double *a, double *b, double *c);
void TD_MUL(double *a, double *b, double *c);
void TD_DIV(double *a, double *b, double *c);

inline double quick_two_sum(double a, double b, double *err)
{
    double s = a + b;
    *err = b - (s - a);
    return s;
}

inline double quick_two_diff(double a, double b, double *err)
{
    double s = a - b;
    *err = (a - s) - b;
    return s;
}

inline double two_sum(double a, double b, double *err)
{
    double s = a + b;
    double bb = s - a;
    *err = (a - (s - bb)) + (b - bb);
    return s;
}

inline double two_diff(double a, double b, double *err)
{
    double s = a - b;
    double bb = s - a;
    *err = (a - (s - bb)) - (b + bb);
    return s;
}

inline void split(double a, double *hi, double *lo)
{
    double temp;
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
    /*
       s1 = quick_two_sum(s1, *c2, &s2);
       s2 = quick_two_sum(s2, *c3, &s3);
     */


    if (s1 != 0.0) {
	s1 = quick_two_sum(s1, *c2, &s2);
	if (s2 != 0.0) {
	    s2 = quick_two_sum(s2, *c3, &s3);
	} else {
	    s1 = quick_two_sum(s1, *c3, &s2);
	}
    } else {
	s0 = quick_two_sum(s0, *c2, &s1);
	if (s1 != 0.0) {
	    s1 = quick_two_sum(s1, *c3, &s2);
	} else {
	    s0 = quick_two_sum(s0, *c3, &s1);
	}
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

    //s1 = quick_two_sum(s1, *c2, &s2);
    //s2 = quick_two_sum(s2, *c3, &s3);
    //s3 += *c4;



    if (s1 != 0.0) {
	s1 = quick_two_sum(s1, *c2, &s2);
	if (s2 != 0.0) {
	    s2 = quick_two_sum(s2, *c3, &s3);
	    if (s3 != 0.0) {
		s3 += *c4;
	    } else {
		s2 += *c4;
	    }
	} else {
	    s1 = quick_two_sum(s1, *c3, &s2);
	    if (s2 != 0.0) {
		s2 = quick_two_sum(s2, *c4, &s3);
	    } else {
		s1 = quick_two_sum(s1, *c4, &s2);
	    }
	}
    } else {
	s0 = quick_two_sum(s0, *c2, &s1);
	if (s1 != 0.0) {
	    s1 = quick_two_sum(s1, *c3, &s2);
	    if (s2 != 0.0) {
		s2 = quick_two_sum(s2, *c4, &s3);
	    } else {
		s1 = quick_two_sum(s1, *c4, &s2);
	    }
	} else {
	    s0 = quick_two_sum(s0, *c3, &s1);
	    if (s1 != 0.0) {
		s1 = quick_two_sum(s1, *c4, &s2);
	    } else {
		s0 = quick_two_sum(s0, *c4, &s1);
	    }
	}
    }

    *c0 = s0;
    *c1 = s1;
    *c2 = s2;
    *c3 = s3;
}

void QD_sloppy_ADD(double *a, double *b, double *c)
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

    c[0] = s0;
    c[1] = s1;
    c[2] = s2;
    c[3] = s3;
}

void QD_sloppy_MUL(double *a, double *b, double *c)
{
    double p0, p1, p2, p3, p4, p5;
    double q0, q1, q2, q3, q4, q5;
    double t0, t1;
    double s0, s1, s2;

    p0 = two_prod(a[0], b[0], &q0);

    p1 = two_prod(a[0], b[1], &q1);
    p2 = two_prod(a[1], b[0], &q2);

    p3 = two_prod(a[0], b[2], &q3);
    p4 = two_prod(a[1], b[1], &q4);
    p5 = two_prod(a[2], b[0], &q5);

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
    s1 += a[0] * b[3] + a[1] * b[2] + a[2] * b[1] + a[3] * b[0] + q0 + q3 + q4 + q5;
    renorm5(&p0, &p1, &s0, &s1, &s2);

    c[0] = p0;
    c[1] = p1;
    c[2] = s0;
    c[3] = s1;
}

void QD_sloppy_SUB(double *a, double *b, double *c)
{
    double tmp[4];

    tmp[0] = -b[0];
    tmp[1] = -b[1];
    tmp[2] = -b[2];
    tmp[3] = -b[3];

    QD_sloppy_ADD(a, tmp, c);
}

void QD_sloppy_DIV(double *a, double *b, double *c)
{
    double q0, q1, q2, q3;

    double r[4], tmp[4] = { 0.0, 0.0, 0.0, 0.0 };

    q0 = a[0] / b[0];
    //r = a - (b * q0);
    tmp[0] = q0;
    QD_sloppy_MUL(b, tmp, tmp);
    QD_sloppy_SUB(a, tmp, r);

    q1 = r[0] / b[0];
    //r -= (b * q1);
    tmp[0] = q1;
    tmp[1] = 0.0;
    tmp[2] = 0.0;
    tmp[3] = 0.0;
    QD_sloppy_MUL(b, tmp, tmp);
    QD_sloppy_SUB(r, tmp, r);

    q2 = r[0] / b[0];
    //r -= (b * q2);
    tmp[0] = q2;
    tmp[1] = 0.0;
    tmp[2] = 0.0;
    tmp[3] = 0.0;
    QD_sloppy_MUL(b, tmp, tmp);
    QD_sloppy_SUB(r, tmp, r);

    q3 = r[0] / b[0];

    renorm4(&q0, &q1, &q2, &q3);

    c[0] = q0;
    c[1] = q1;
    c[2] = q2;
    c[3] = q3;
}

inline void TD_ADD(double *a, double *b, double *c)
{
    double s0, s1, s2;
    double t0, t1, t2;

    s0 = two_sum(a[0], b[0], &t0);
    s1 = two_sum(a[1], b[1], &t1);
    s2 = two_sum(a[2], b[2], &t2);

    s1 = two_sum(s1, t0, &t0);
    three_sum(&s2, &t0, &t1);
    t0 = t0 + t1 + t2;

    renorm4(&s0, &s1, &s2, &t0);

    c[0] = s0;
    c[1] = s1;
    c[2] = s2;
}

inline void TD_SUB(double *a, double *b, double *c)
{
    double minus_b[3];

    minus_b[0] = -b[0];
    minus_b[1] = -b[1];
    minus_b[2] = -b[2];

    TD_ADD(a, minus_b, c);
}

inline void TD_MUL(double *a, double *b, double *c)
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

    three_sum(&p1, &p2, &q0);

    three_sum(&p2, &q1, &q2);
    three_sum(&p3, &p4, &p5);

    s0 = two_sum(p2, p3, &t0);
    s1 = two_sum(q1, p4, &t1);
    ////s2 = q2 + p5;
    s1 = two_sum(s1, t0, &t0);
    ////s2 += (t0 + t1);

    s1 += a[1] * b[2] + a[2] * b[1] + q0 + q3 + q4 + q5;

    renorm4(&p0, &p1, &s0, &s1);

    c[0] = p0;
    c[1] = p1;
    c[2] = s0;
}

inline void TD_DIV(double *a, double *b, double *c)
{
    double q0, q1, q2, q3;

    double r[3], tmp[3] = { 0.0, 0.0, 0.0 };

    q0 = a[0] / b[0];
    //r = a - (b * q0);
    tmp[0] = q0;
    TD_MUL(b, tmp, tmp);
    TD_SUB(a, tmp, r);

    q1 = r[0] / b[0];
    //r -= (b * q1);
    tmp[0] = q1;
    tmp[1] = 0.0;
    tmp[2] = 0.0;
    TD_MUL(b, tmp, tmp);
    TD_SUB(r, tmp, r);

    q2 = r[0] / b[0];
    //r -= (b * q2);
    tmp[0] = q2;
    tmp[1] = 0.0;
    tmp[2] = 0.0;
    TD_MUL(b, tmp, tmp);
    TD_SUB(r, tmp, r);

    q3 = r[0] / b[0];

    renorm4(&q0, &q1, &q2, &q3);

    c[0] = q0;
    c[1] = q1;
    c[2] = q2;
}

#endif
