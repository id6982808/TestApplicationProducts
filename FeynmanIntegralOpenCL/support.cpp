#ifndef _INC_SUPPORT_CPP
#define _INC_SUPPORT_CPP

#include <iostream>
#include <qd/dd_real.h>
#include <qd/qd_real.h>
#include <sys/time.h>

double ext_ramda;

double get_time();
qd_real analytical(int print_info);

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
    lmd = ext_ramda;

    I = (1.0 / (-s * (-t + mf * mf))) * log(-s / (lmd * lmd)) * log(((-t + mf * mf) * (-t + mf * mf)) / (me * me * mf * mf));

    if (print_info == 1) {
	std::cout.precision(35);
	std::cout << "analytical answer:       " << I << std::endl;
    }

    return I;
}

#endif
