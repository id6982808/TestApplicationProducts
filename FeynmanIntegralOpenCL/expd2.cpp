#include <iostream>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <math.h>
#include <qd/dd_real.h>
#include <qd/qd_real.h>
#include "td_real.cpp"


/* 432, 864, 1000 */
#define N 100

/*
   fixed point compared to expd.cpp  :  array size,  loop index
 */

double get_time();
qd_real analytical(int print_info);	// analytical answer
void default_feynman(int m, double h, double ramda);	// default feynman
void dd_feynman(int m, dd_real h, dd_real ramda);	// dd_real for all compute
void qd_feynman(int m, qd_real h, qd_real ramda);	// qd_real for all compute
void td_feynman(int m, td_real h, td_real ramda);	// td_real for all compute
void test_prec(int m, double h, double ramda);	// test only for computing D

int main()
{
    int n = N;
    double ramda = 1.0e-30;
    double h;

    h = 13.0 / (double) n;	// 6.75 ~ 13.61

    std::cout << "n = " << n << std::endl;
    std::cout << "ramda = " << ramda << std::endl;
    analytical(1);
    std::cout << std::endl;

    default_feynman(n, h, ramda);
    dd_feynman(n, h, ramda);
    qd_feynman(n, h, ramda);
    td_feynman(n, h, ramda);
    //test_prec(n, h, ramda);

    return 0;
}

double get_time()
{
    static struct timeval now;
    gettimeofday(&now, NULL);
    return (double) (now.tv_sec + now.tv_usec / 1000000.0);
}

qd_real analytical(int print_info)
{
    qd_real s, t, mf, me, lmd, I;

    s = -500.0 * 500.0;
    t = -150.0 * 150.0;
    mf = 150.0;
    me = 0.0005;
    lmd = 1.0e-30;

    I = (1.0 / (-s * (-t + mf * mf))) * log(-s / (lmd * lmd)) * log(((-t + mf * mf) * (-t + mf * mf)) / (me * me * mf * mf));

    if (print_info == 1) {
	std::cout.precision(35);
	std::cout << "analytical answer: " << I << std::endl;
    }

    return I;
}

void default_feynman(int m, double h, double ramda)
{
    int n = m;
    double gw30[n], x30[n];
    double w1[n], w2[n], w3[n];
    double y, pi, t;
    //dd_real y, pi, t;
    double knl_s, knl_e;

    /* implicit double (a,b,c,d,e,f,g,h,   o,p,q,r,s,t,u,v,w,x,y,z)  -  ...  */
    double x, s, tt, fme, fmf;
    double ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;


    /* prepare integration */
    pi = (4.0 * atan(1.0));

    for (int i = 1; i <= n; i++) {
	x = -(n / 2) - 1 + (i);
	t = x * h;
	y = (pi * 0.5 * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (0.5 * cosh(t) * pi * (1.0 - tanh(y) * tanh(y)));
    }

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;

    /* timer start calculation */
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * 0.5;
    cnt1 = (bx + ax) * 0.5;
    knl_s = get_time();
    for (int i1 = 0; i1 < n; i1++) {
	xx = x30[i1] * cnt0 + cnt1;
	by = 1.0 - xx;
	cnt2 = (by - ay) * 0.5;
	cnt3 = (by + ay) * 0.5;
	for (int i2 = 0; i2 < n; i2++) {
	    yy = x30[i2] * cnt2 + cnt3;
	    bz = 1.0 - xx - yy;
	    cnt4 = (bz - az) * 0.5;
	    cnt5 = (bz + az) * 0.5;
	    for (int i3 = 0; i3 < n; i3++) {
		zz = x30[i3] * cnt4 + cnt5;
		d = -xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
		w3[i3] = (cnt0 * cnt2 * cnt4 * gw30[i1] * gw30[i2] * gw30[i3]) / (d * d);
	    }
	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = sum + w3[i];
	    w2[i2] = sum * h;
	}
	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }
    knl_e = get_time();


    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;


    std::cout.precision(35);
    std::cout << "double precision: " << result << std::endl;
    std::cout << "error to analytical: " << analytical(0) - result << std::endl;
    std::cout << "kernel time: " << knl_e - knl_s << " sec." << std::endl << std::endl;
}



void dd_feynman(int m, dd_real h, dd_real ramda)
{
    int n = m;
    dd_real gw30[n], x30[n];
    dd_real w1[n], w2[n], w3[n];
    dd_real y, pi, t;
    double knl_s, knl_e;

    /* implicit double (a,b,c,d,e,f,g,h,   o,p,q,r,s,t,u,v,w,x,y,z)  -  ...  */
    dd_real x, s, tt, fme, fmf;
    dd_real ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;

    /* prepare integration */
    pi = (dd_real("4.0") * atan(dd_real("1.0")));

    for (int i = 1; i <= n; i++) {
	x = -n / 2 - 1 + (i);
	t = x * h;
	y = (pi * dd_real("0.5") * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (dd_real("0.5") * cosh(t) * pi * (dd_real("1.0") - tanh(y) * tanh(y)));
    }

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;

    /* timer start calculation */
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * dd_real(0.5);
    cnt1 = (bx + ax) * dd_real(0.5);
    knl_s = get_time();
    for (int i1 = 0; i1 < n; i1++) {
	xx = x30[i1] * cnt0 + cnt1;
	by = dd_real(1.0) - xx;
	cnt2 = (by - ay) * dd_real(0.5);
	cnt3 = (by + ay) * dd_real(0.5);
	for (int i2 = 0; i2 < n; i2++) {
	    yy = x30[i2] * cnt2 + cnt3;
	    bz = dd_real(1.0) - xx - yy;
	    cnt4 = (bz - az) * dd_real(0.5);
	    cnt5 = (bz + az) * dd_real(0.5);
	    for (int i3 = 0; i3 < n; i3++) {
		zz = x30[i3] * cnt4 + cnt5;
		d = -xx * yy * s - tt * zz * (dd_real(1.0) - xx - yy - zz) + (xx + yy) * ramda * ramda + (dd_real(1.0) -
													  xx - yy -
													  zz) *
		    (dd_real(1.0) - xx - yy) * fme * fme + zz * (dd_real(1.0) - xx - yy) * fmf * fmf;
		w3[i3] = (cnt0 * cnt2 * cnt4 * gw30[i1] * gw30[i2] * gw30[i3]) / (d * d);
	    }
	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = sum + w3[i];
	    w2[i2] = sum * h;
	}
	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }
    knl_e = get_time();

    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;

    std::cout.precision(35);
    std::cout << "double-double precision: " << result << std::endl;
    std::cout << "error to analytical: " << analytical(0) - result << std::endl;
    std::cout << "kernel time: " << knl_e - knl_s << " sec." << std::endl << std::endl;
}

void qd_feynman(int m, qd_real h, qd_real ramda)
{
    int n = m;
    qd_real gw30[n], x30[n];
    qd_real w1[n], w2[n], w3[n];
    qd_real y, pi, t;
    double knl_s, knl_e;

    /* implicit double (a,b,c,d,e,f,g,h,   o,p,q,r,s,t,u,v,w,x,y,z)  -  ...  */
    qd_real x, s, tt, fme, fmf;
    qd_real ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;

    /* prepare integration */
    pi = (qd_real(4.0) * atan(qd_real(1.0)));

    for (int i = 1; i <= n; i++) {
	x = -n / 2 - 1 + (i);
	t = x * h;
	y = (pi * qd_real(0.5) * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (qd_real(0.5) * cosh(t) * pi * (qd_real(1.0) - tanh(y) * tanh(y)));
    }

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;

    /* timer start calculation */
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * qd_real(0.5);
    cnt1 = (bx + ax) * qd_real(0.5);
    knl_s = get_time();
    for (int i1 = 0; i1 < n; i1++) {
	xx = x30[i1] * cnt0 + cnt1;
	by = qd_real(1.0) - xx;
	cnt2 = (by - ay) * qd_real(0.5);
	cnt3 = (by + ay) * qd_real(0.5);
	for (int i2 = 0; i2 < n; i2++) {
	    yy = x30[i2] * cnt2 + cnt3;
	    bz = qd_real(1.0) - xx - yy;
	    cnt4 = (bz - az) * qd_real(0.5);
	    cnt5 = (bz + az) * qd_real(0.5);
	    for (int i3 = 0; i3 < n; i3++) {
		zz = x30[i3] * cnt4 + cnt5;
		d = -xx * yy * s - tt * zz * (qd_real(1.0) - xx - yy - zz) + (xx + yy) * ramda * ramda + (qd_real(1.0) -
													  xx - yy -
													  zz) *
		    (qd_real(1.0) - xx - yy) * fme * fme + zz * (qd_real(1.0) - xx - yy) * fmf * fmf;
		w3[i3] = (cnt0 * cnt2 * cnt4 * gw30[i1] * gw30[i2] * gw30[i3]) / (d * d);
	    }
	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = sum + w3[i];
	    w2[i2] = sum * h;
	}
	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }
    knl_e = get_time();

    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;

    std::cout.precision(35);
    std::cout << "quad-double precision: " << result << std::endl;
    std::cout << "error to analytical: " << analytical(0) - result << std::endl;
    std::cout << "kernel time: " << knl_e - knl_s << " sec." << std::endl << std::endl;
}

void td_feynman(int m, td_real h, td_real ramda)
{
    int n = m;
    td_real gw30[n], x30[n];
    td_real w1[n], w2[n], w3[n];
    qd_real y, pi, t;
    double knl_s, knl_e;

    /* implicit double (a,b,c,d,e,f,g,h,   o,p,q,r,s,t,u,v,w,x,y,z)  -  ...  */
    td_real x, s, tt, fme, fmf;
    td_real ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;

    /* prepare integration */
    pi = (qd_real(4.0) * atan(qd_real(1.0)));

    for (int i = 1; i <= n; i++) {
	x = -n / 2 - 1 + (i);
	t = (x * h).toQDreal();
	y = (pi * qd_real(0.5) * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (qd_real(0.5) * cosh(t) * pi * (qd_real(1.0) - tanh(y) * tanh(y)));
    }

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;

    /* timer start calculation */
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * td_real(0.5);
    cnt1 = (bx + ax) * td_real(0.5);
    knl_s = get_time();
    for (int i1 = 0; i1 < n; i1++) {
	xx = x30[i1] * cnt0 + cnt1;
	by = td_real(1.0) - xx;
	cnt2 = (by - ay) * td_real(0.5);
	cnt3 = (by + ay) * td_real(0.5);
	for (int i2 = 0; i2 < n; i2++) {
	    yy = x30[i2] * cnt2 + cnt3;
	    bz = td_real(1.0) - xx - yy;
	    cnt4 = (bz - az) * td_real(0.5);
	    cnt5 = (bz + az) * td_real(0.5);
	    for (int i3 = 0; i3 < n; i3++) {
		zz = x30[i3] * cnt4 + cnt5;
		d = td_real(-1.0) * xx * yy * s - tt * zz * (td_real(1.0) - xx - yy - zz) + (xx + yy) * ramda * ramda +
		    (td_real(1.0) - xx - yy - zz) * (td_real(1.0) - xx - yy) * fme * fme + zz * (td_real(1.0) - xx - yy) * fmf * fmf;
		w3[i3] = (cnt0 * cnt2 * cnt4 * gw30[i1] * gw30[i2] * gw30[i3]) / (d * d);
	    }
	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = sum + w3[i];
	    w2[i2] = sum * h;
	}
	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }
    knl_e = get_time();

    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;

    std::cout.precision(35);
    std::cout << "triple-double precision: " << result << std::endl;
    std::cout << "error to analytical: " << analytical(0) - result.toQDreal() << std::endl;
    std::cout << "kernel time: " << knl_e - knl_s << " sec." << std::endl << std::endl;
}

void test_prec(int m, double h, double ramda)
{
    int n = m;
    //double gw30[n], x30[n];
    double w1[n], w2[n];
    //double y, pi, t;
    qd_real y, pi, t, gw30[n], x30[n], w3[n];
    double knl_s, knl_e;

    /* implicit double (a,b,c,d,e,f,g,h,   o,p,q,r,s,t,u,v,w,x,y,z)  -  ...  */
    double x, s, tt, fme, fmf;
    double ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;


    /* prepare integration */
    pi = (dd_real(4.0) * atan(dd_real(1.0)));

    for (int i = 1; i <= n; i++) {
	x = -(n / 2) - 1 + (i);
	t = x * h;
	y = (pi * dd_real(0.5) * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (dd_real(0.5) * cosh(t) * pi * (dd_real(1.0) - tanh(y) * tanh(y)));
    }

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;

    /* timer start calculation */
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * 0.5;
    cnt1 = (bx + ax) * 0.5;
    knl_s = get_time();
    for (int i1 = 0; i1 < n; i1++) {
	xx = (x30[i1] * cnt0 + cnt1).x[0];
	by = 1.0 - xx;
	cnt2 = (by - ay) * 0.5;
	cnt3 = (by + ay) * 0.5;
	for (int i2 = 0; i2 < n; i2++) {
	    yy = (x30[i2] * cnt2 + cnt3).x[0];
	    bz = 1.0 - xx - yy;
	    cnt4 = (bz - az) * 0.5;
	    cnt5 = (bz + az) * 0.5;
	    for (int i3 = 0; i3 < n; i3++) {
		qd_real _x30 = x30[i3], _cnt4 = cnt4, _cnt5 = cnt5, _zz, _xx = xx, _yy = yy;
		qd_real _s = s, _tt = tt, _ramda = ramda, _fme = fme, _fmf = fmf, _cnt0 = cnt0, _cnt2 = cnt2, _gw30i1 = gw30[i1], _gw30i2 = gw30[i2], _gw30i3 = gw30[i3], _d;
		qd_real _w3;

		_zz = _x30 * _cnt4 + _cnt5;
		_d = -_xx * _yy * _s - _tt * _zz * (1.0 - _xx - _yy - _zz) + (_xx + _yy) * _ramda * _ramda + (1.0 -
													      _xx -
													      _yy -
													      _zz) * (1.0 - _xx - _yy) * _fme * _fme + _zz * (1.0 - _xx - _yy) * _fmf * _fmf;
		_w3 = (_cnt0 * _cnt2 * _cnt4 * _gw30i1 * _gw30i2 * _gw30i3) / (_d * _d);
		w3[i3] = _w3;
	    }
	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = (sum + w3[i]).x[0];
	    w2[i2] = sum * h;
	}
	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }
    knl_e = get_time();


    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;


    std::cout.precision(35);
    std::cout << "double precision: " << result << std::endl;
    std::cout << "error to analytical: " << analytical(0) - result << std::endl;
    std::cout << "kernel time: " << knl_e - knl_s << " sec." << std::endl << std::endl;
}
