#include "dd_arithmetic.h"

__kernel void feynman_dd_d2(int n, int id1, int id2, __global dd_real *s, 
																			__global dd_real *tt, __global dd_real *ramda, __global dd_real *fme, __global dd_real *fmf,
																			__global dd_real *cnt0, __global dd_real *cnt2, __global dd_real *cnt4, __global dd_real *cnt5, 
																			__global dd_real *xx, __global dd_real *yy,
																			__global dd_real *w3, __global dd_real *gw30, __global dd_real *x30)
{
		// loop index (thread id)
		int id3 = get_global_id(0);

		// computed variables
		dd_real zz, d, one, mone, zero;
		dd_real _s, _tt, _ramda, _fme, _fmf, _cnt0, _cnt2, _cnt4, _cnt5, _xx, _yy;
		dd_real _x30, _gw30_i1, _gw30_i2, _gw30_i3, _w3;
		dd_real tmp, tmp2, t1, t2, t3, t4, t5;

		one = (dd_real)(1.0, 0.0);
		mone = (dd_real)(-1.0, 0.0);
		zero = (dd_real)(0.0, 0.0);

		tmp = zero; tmp2=zero;

		_s = 	s[0];
		_tt = tt[0];
		_ramda = ramda[0];
		_fme = fme[0];
		_fmf = fmf[0];
		_cnt0 = cnt0[0];
		_cnt2 = cnt2[0];
		_cnt4 = cnt4[0];
		_cnt5 = cnt5[0];
		_xx = xx[0];
		_yy = yy[0];
		_x30 = x30[id3];
		_gw30_i1 = gw30[id1];
		_gw30_i2 = gw30[id2];
		_gw30_i3 = gw30[id3];



		// start computing
		// zz = x30[id3] * cnt4 + cnt5;
		DD_TwoProd(&_x30, &_cnt4, &tmp);
		DD_TwoSum(&tmp, &_cnt5, &zz);

		// d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
		// -xx * yy * s 
		//tmp = zero; tmp2=zero;
		DD_TwoProd(&_xx, &_yy, &tmp);
		DD_TwoProd(&tmp, &_s, &tmp);
		DD_TwoProd(&mone, &tmp, &t1);
		// tt * zz * (1.0 - xx - yy - zz) 
		//tmp = zero; tmp2=zero;
		DD_TwoProd(&_tt, &zz, &tmp);
		DD_TwoSub(&one, &_xx, &tmp2);
		DD_TwoSub(&tmp2, &_yy, &tmp2);
		DD_TwoSub(&tmp2, &zz, &tmp2);
		DD_TwoProd(&tmp, &tmp2, &t2);
		// (xx + yy) * ramda * ramda
		//tmp = zero; tmp2=zero;
		DD_TwoSum(&_xx, &_yy, &tmp);
		DD_TwoProd(&tmp, &_ramda, &tmp);
		DD_TwoProd(&tmp, &_ramda, &t3);
		// (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
		//tmp = zero; tmp2=zero;
		DD_TwoSub(&one, &_xx, &tmp);
	  DD_TwoSub(&tmp, &_yy, &tmp);
		DD_TwoSub(&tmp, &zz, &tmp);
		DD_TwoSub(&one, &_xx, &tmp2);
		DD_TwoSub(&tmp2, &_yy, &tmp2);
		DD_TwoProd(&tmp, &tmp2, &tmp);
		DD_TwoProd(&tmp, &_fme, &tmp);
		DD_TwoProd(&tmp, &_fme, &t4);
		// zz * (1.0 - xx - yy) * fmf * fmf
		//tmp = zero; tmp2=zero;
		DD_TwoSub(&one, &_xx, &tmp);
		DD_TwoSub(&tmp, &_yy, &tmp);
		DD_TwoProd(&tmp, &zz, &tmp);
		DD_TwoProd(&tmp, &_fmf, &tmp);
		DD_TwoProd(&tmp, &_fmf, &t5);
		// t1 - t2 + t3 + t4 + t5
		//tmp = zero; tmp2=zero;
		DD_TwoSub(&t1, &t2, &tmp);
		DD_TwoSum(&tmp, &t3, &tmp);
		DD_TwoSum(&tmp, &t4, &tmp);
		DD_TwoSum(&tmp, &t5, &d);

		// w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
		//tmp = zero; tmp2=zero;
		DD_TwoProd(&d, &d, &tmp);
	  DD_TwoProd(&_cnt0, &_cnt2, &tmp2);
		DD_TwoProd(&tmp2, &_cnt4, &tmp2);
		DD_TwoProd(&tmp2, &_gw30_i1, &tmp2);
		DD_TwoProd(&tmp2, &_gw30_i2, &tmp2);
		DD_TwoProd(&tmp2, &_gw30_i3, &tmp2);
		DD_TwoDiv(&tmp2, &tmp, &_w3);

		w3[id3] = _w3;
}


__kernel void feynman_dd(int n, int i1, int i2, __global double *s, 
																			__global double *tt, __global double *ramda, __global double *fme, __global double *fmf,
																			__global double *cnt0, __global double *cnt2, __global double *cnt4, __global double *cnt5, 
																			__global double *xx, __global double *yy,
																			__global double *w3, __global double *gw30, __global double *x30)
{
		// loop index (thread id)
		int id3 = get_global_id(0) * 2;
		int id1 = i1 * 2, id2 = i2 * 2;

		// computed variables
		double zz[2], d[2], one[2]={1.0, 0.0}, mone[2]={-1.0, 0.0};
		double _s[2], _tt[2], _ramda[2], _fme[2], _fmf[2], _cnt0[2], _cnt2[2], _cnt4[2], _cnt5[2], _xx[2], _yy[2];
		double _x30[2], _gw30_i1[2], _gw30_i2[2], _gw30_i3[2], _w3[2];
		double tmp[2], tmp2[2], t1[2], t2[2], t3[2], t4[2], t5[2];

	
		dd_zeros(tmp); dd_zeros(tmp2);

		_s[0] = 	s[0]; _s[1] = 	s[1];
		_tt[0] = tt[0]; _tt[1] = tt[1];
		_ramda[0] = ramda[0]; _ramda[1] = ramda[1];
		_fme[0] = fme[0]; _fme[1] = fme[1];
		_fmf[0] = fmf[0]; _fmf[1] = fmf[1];
		_cnt0[0] = cnt0[0]; _cnt0[1] = cnt0[1];
		_cnt2[0] = cnt2[0]; _cnt2[1] = cnt2[1];
		_cnt4[0] = cnt4[0]; _cnt4[1] = cnt4[1];
		_cnt5[0] = cnt5[0]; _cnt5[1] = cnt5[1];
		_xx[0] = xx[0]; _xx[1] = xx[1];
		_yy[0] = yy[0]; _yy[1] = yy[1];
		_x30[0] = x30[id3+0]; _x30[1] = x30[id3+1];
		_gw30_i1[0] = gw30[id1+0]; _gw30_i1[1] = gw30[id1+1];
		_gw30_i2[0] = gw30[id2+0]; _gw30_i2[1] = gw30[id2+1];
		_gw30_i3[0] = gw30[id3+0]; _gw30_i3[1] = gw30[id3+1];


		// start computing
		// zz = x30[id3] * cnt4 + cnt5;
		DD_TwoProd(_x30, _cnt4, tmp);
		DD_TwoSum(tmp, _cnt5, zz);

		// d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
		// -xx * yy * s 
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoProd(_xx, _yy, tmp);
		DD_TwoProd(tmp, _s, tmp);
		DD_TwoProd(mone, tmp, t1);
		// tt * zz * (1.0 - xx - yy - zz) 
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoProd(_tt, zz, tmp);
		DD_TwoSub(one, _xx, tmp2);
		DD_TwoSub(tmp2, _yy, tmp2);
		DD_TwoSub(tmp2, zz, tmp2);
		DD_TwoProd(tmp, tmp2, t2);
		// (xx + yy) * ramda * ramda
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoSum(_xx, _yy, tmp);
		DD_TwoProd(tmp, _ramda, tmp);
		DD_TwoProd(tmp, _ramda, t3);
		// (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoSub(one, _xx, tmp);
	  DD_TwoSub(tmp, _yy, tmp);
		DD_TwoSub(tmp, zz, tmp);
		DD_TwoSub(one, _xx, tmp2);
		DD_TwoSub(tmp2, _yy, tmp2);
		DD_TwoProd(tmp, tmp2, tmp);
		DD_TwoProd(tmp, _fme, tmp);
		DD_TwoProd(tmp, _fme, t4);
		// zz * (1.0 - xx - yy) * fmf * fmf
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoSub(one, _xx, tmp);
		DD_TwoSub(tmp, _yy, tmp);
		DD_TwoProd(tmp, zz, tmp);
		DD_TwoProd(tmp, _fmf, tmp);
		DD_TwoProd(tmp, _fmf, t5);
		// t1 - t2 + t3 + t4 + t5
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoSub(t1, t2, tmp);
		DD_TwoSum(tmp, t3, tmp);
		DD_TwoSum(tmp, t4, tmp);
		DD_TwoSum(tmp, t5, d);

		// w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
		dd_zeros(tmp); dd_zeros(tmp2);
		DD_TwoProd(d, d, tmp);
	  DD_TwoProd(_cnt0, _cnt2, tmp2);
		DD_TwoProd(tmp2, _cnt4, tmp2);
		DD_TwoProd(tmp2, _gw30_i1, tmp2);
		DD_TwoProd(tmp2, _gw30_i2, tmp2);
		DD_TwoProd(tmp2, _gw30_i3, tmp2);
		DD_TwoDiv(tmp2, tmp, _w3);


		w3[id3+0] = _w3[0];
		w3[id3+1] = _w3[1];
}

