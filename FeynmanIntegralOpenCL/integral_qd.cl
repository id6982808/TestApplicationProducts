#include "qd_arithmetic.h"

__kernel void feynman_qd_d4(int n, int id1, int id2, __global qd_real *s, 
																			__global qd_real *tt, __global qd_real *ramda, __global qd_real *fme, __global qd_real *fmf,
																			__global qd_real *cnt0, __global qd_real *cnt2, __global qd_real *cnt4, __global qd_real *cnt5, 
																			__global qd_real *xx, __global qd_real *yy,
																			__global qd_real *w3, __global qd_real *gw30, __global qd_real *x30)
{
		// loop index (thread id)
		int id3 = get_global_id(0);

		// computed variables
		qd_real zz, d, one, mone, zero;
		qd_real _s, _tt, _ramda, _fme, _fmf, _cnt0, _cnt2, _cnt4, _cnt5, _xx, _yy;
		qd_real _x30, _gw30_i1, _gw30_i2, _gw30_i3, _w3;
		qd_real tmp, tmp2, t1, t2, t3, t4, t5;

		one = (qd_real)(1.0, 0.0, 0.0, 0.0);
		mone = (qd_real)(-1.0, 0.0, 0.0, 0.0);
		zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

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
		QD_sloppy_MUL(&_x30, &_cnt4, &tmp);
		QD_sloppy_ADD(&tmp, &_cnt5, &zz);

		// d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
		// -xx * yy * s 
		tmp = zero; tmp2=zero;
		QD_sloppy_MUL(&_xx, &_yy, &tmp);
		QD_sloppy_MUL(&tmp, &_s, &tmp);
		QD_sloppy_MUL(&mone, &tmp, &t1);
		// tt * zz * (1.0 - xx - yy - zz) 
		tmp = zero; tmp2=zero;
		QD_sloppy_MUL(&_tt, &zz, &tmp);
		QD_sloppy_SUB(&one, &_xx, &tmp2);
		QD_sloppy_SUB(&tmp2, &_yy, &tmp2);
		QD_sloppy_SUB(&tmp2, &zz, &tmp2);
		QD_sloppy_MUL(&tmp, &tmp2, &t2);
		// (xx + yy) * ramda * ramda
		tmp = zero; tmp2=zero;
		QD_sloppy_ADD(&_xx, &_yy, &tmp);
		QD_sloppy_MUL(&tmp, &_ramda, &tmp);
		QD_sloppy_MUL(&tmp, &_ramda, &t3);
		// (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
		tmp = zero; tmp2=zero;
		QD_sloppy_SUB(&one, &_xx, &tmp);
		QD_sloppy_SUB(&tmp, &_yy, &tmp);
		QD_sloppy_SUB(&tmp, &zz, &tmp);
		QD_sloppy_SUB(&one, &_xx, &tmp2);
		QD_sloppy_SUB(&tmp2, &_yy, &tmp2);
		QD_sloppy_MUL(&tmp, &tmp2, &tmp);
		QD_sloppy_MUL(&tmp, &_fme, &tmp);
		QD_sloppy_MUL(&tmp, &_fme, &t4);
		// zz * (1.0 - xx - yy) * fmf * fmf
		tmp = zero; tmp2=zero;
		QD_sloppy_SUB(&one, &_xx, &tmp);
		QD_sloppy_SUB(&tmp, &_yy, &tmp);
		QD_sloppy_MUL(&tmp, &zz, &tmp);
		QD_sloppy_MUL(&tmp, &_fmf, &tmp);
		QD_sloppy_MUL(&tmp, &_fmf, &t5);
		// t1 - t2 + t3 + t4 + t5
		tmp = zero; tmp2=zero;
		QD_sloppy_SUB(&t1, &t2, &tmp);
		QD_sloppy_ADD(&tmp, &t3, &tmp);
		QD_sloppy_ADD(&tmp, &t4, &tmp);
		QD_sloppy_ADD(&tmp, &t5, &d);

		// w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
		tmp = zero; tmp2=zero;
		QD_sloppy_MUL(&d, &d, &tmp);
		QD_sloppy_MUL(&_cnt0, &_cnt2, &tmp2);
		QD_sloppy_MUL(&tmp2, &_cnt4, &tmp2);
		QD_sloppy_MUL(&tmp2, &_gw30_i1, &tmp2);
		QD_sloppy_MUL(&tmp2, &_gw30_i2, &tmp2);
		QD_sloppy_MUL(&tmp2, &_gw30_i3, &tmp2);
		QD_sloppy_DIV(&tmp2, &tmp, &_w3);

		w3[id3] = _w3;
}


__kernel void feynman_qd(int n, int i1, int i2, __global double *s, 
																			__global double *tt, __global double *ramda, __global double *fme, __global double *fmf,
																			__global double *cnt0, __global double *cnt2, __global double *cnt4, __global double *cnt5, 
																			__global double *xx, __global double *yy,
																			__global double *w3, __global double *gw30, __global double *x30)
{
		// loop index (thread id)
		int id3 = get_global_id(0) * 4;
		int id1 = i1 * 4, id2 = i2 * 4;

		// computed variables
		double zz[4], d[4], one[4]={1.0, 0.0, 0.0, 0.0}, mone[4]={-1.0, 0.0, 0.0, 0.0};
		double _s[4], _tt[4], _ramda[4], _fme[4], _fmf[4], _cnt0[4], _cnt2[4], _cnt4[4], _cnt5[4], _xx[4], _yy[4];
		double _x30[4], _gw30_i1[4], _gw30_i2[4], _gw30_i3[4], _w3[4];
		double tmp[4], tmp2[4], t1[4], t2[4], t3[4], t4[4], t5[4];

	
		qd_zeros(tmp); qd_zeros(tmp2);

		_s[0] = 	s[0]; _s[1] = 	s[1]; _s[2] = 	s[2]; _s[3] = 	s[3]; 
		_tt[0] = tt[0]; _tt[1] = tt[1]; _tt[2] = tt[2]; _tt[3] = tt[3]; 
		_ramda[0] = ramda[0]; _ramda[1] = ramda[1]; _ramda[2] = ramda[2]; _ramda[3] = ramda[3];
		_fme[0] = fme[0]; _fme[1] = fme[1]; _fme[2] = fme[2]; _fme[3] = fme[3];
		_fmf[0] = fmf[0]; _fmf[1] = fmf[1]; _fmf[2] = fmf[2]; _fmf[3] = fmf[3]; 
		_cnt0[0] = cnt0[0]; _cnt0[1] = cnt0[1]; _cnt0[2] = cnt0[2]; _cnt0[3] = cnt0[3]; 
		_cnt2[0] = cnt2[0]; _cnt2[1] = cnt2[1]; _cnt2[2] = cnt2[2]; _cnt2[3] = cnt2[3];
		_cnt4[0] = cnt4[0]; _cnt4[1] = cnt4[1]; _cnt4[2] = cnt4[2]; _cnt4[3] = cnt4[3];
		_cnt5[0] = cnt5[0]; _cnt5[1] = cnt5[1]; _cnt5[2] = cnt5[2]; _cnt5[3] = cnt5[3];
		_xx[0] = xx[0]; _xx[1] = xx[1]; _xx[2] = xx[2]; _xx[3] = xx[3];
		_yy[0] = yy[0]; _yy[1] = yy[1]; _yy[2] = yy[2]; _yy[3] = yy[3];
		_x30[0] = x30[id3+0]; _x30[1] = x30[id3+1]; _x30[2] = x30[id3+2]; _x30[3] = x30[id3+3];
		_gw30_i1[0] = gw30[id1+0]; _gw30_i1[1] = gw30[id1+1]; _gw30_i1[2] = gw30[id1+2]; _gw30_i1[3] = gw30[id1+3];
		_gw30_i2[0] = gw30[id2+0]; _gw30_i2[1] = gw30[id2+1]; _gw30_i2[2] = gw30[id2+2]; _gw30_i2[3] = gw30[id2+3];
		_gw30_i3[0] = gw30[id3+0]; _gw30_i3[1] = gw30[id3+1]; _gw30_i3[2] = gw30[id3+2]; _gw30_i3[3] = gw30[id3+3];



		// start computing
		// zz = x30[id3] * cnt4 + cnt5;
		QD_sloppy_MUL(_x30, _cnt4, tmp);
		QD_sloppy_ADD(tmp, _cnt5, zz);

		// d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
		// -xx * yy * s 
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_MUL(_xx, _yy, tmp);
		QD_sloppy_MUL(tmp, _s, tmp);
		QD_sloppy_MUL(mone, tmp, t1);
		// tt * zz * (1.0 - xx - yy - zz) 
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_MUL(_tt, zz, tmp);
		QD_sloppy_SUB(one, _xx, tmp2);
		QD_sloppy_SUB(tmp2, _yy, tmp2);
		QD_sloppy_SUB(tmp2, zz, tmp2);
		QD_sloppy_MUL(tmp, tmp2, t2);
		// (xx + yy) * ramda * ramda
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_ADD(_xx, _yy, tmp);
		QD_sloppy_MUL(tmp, _ramda, tmp);
		QD_sloppy_MUL(tmp, _ramda, t3);
		// (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_SUB(one, _xx, tmp);
		QD_sloppy_SUB(tmp, _yy, tmp);
		QD_sloppy_SUB(tmp, zz, tmp);
		QD_sloppy_SUB(one, _xx, tmp2);
		QD_sloppy_SUB(tmp2, _yy, tmp2);
		QD_sloppy_MUL(tmp, tmp2, tmp);
		QD_sloppy_MUL(tmp, _fme, tmp);
		QD_sloppy_MUL(tmp, _fme, t4);
		// zz * (1.0 - xx - yy) * fmf * fmf
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_SUB(one, _xx, tmp);
		QD_sloppy_SUB(tmp, _yy, tmp);
		QD_sloppy_MUL(tmp, zz, tmp);
		QD_sloppy_MUL(tmp, _fmf, tmp);
		QD_sloppy_MUL(tmp, _fmf, t5);
		// t1 - t2 + t3 + t4 + t5
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_SUB(t1, t2, tmp);
		QD_sloppy_ADD(tmp, t3, tmp);
		QD_sloppy_ADD(tmp, t4, tmp);
		QD_sloppy_ADD(tmp, t5, d);

		// w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
		qd_zeros(tmp); qd_zeros(tmp2);
		QD_sloppy_MUL(d, d, tmp);
		QD_sloppy_MUL(_cnt0, _cnt2, tmp2);
		QD_sloppy_MUL(tmp2, _cnt4, tmp2);
		QD_sloppy_MUL(tmp2, _gw30_i1, tmp2);
		QD_sloppy_MUL(tmp2, _gw30_i2, tmp2);
		QD_sloppy_MUL(tmp2, _gw30_i3, tmp2);
		QD_sloppy_DIV(tmp2, tmp, _w3);

		w3[id3+0] = _w3[0];
		w3[id3+1] = _w3[1];
		w3[id3+2] = _w3[2];
		w3[id3+3] = _w3[3];
}

