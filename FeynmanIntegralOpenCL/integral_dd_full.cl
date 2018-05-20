#include "dd_arithmetic.h"
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void feynman_dd_full_d2(int n, __global dd_real *_h, __global dd_real *_s, __global dd_real *_tt,
                              __global dd_real *_ramda, __global dd_real *_fme, __global dd_real *_fmf,
                              __global dd_real *w1, __global dd_real *gw30, __global dd_real *x30)
{
  int id1 = get_global_id(0);
  int i, id2, id3;
  dd_real ax, ay, az, bx, by, bz;
  dd_real xx, yy, zz, d, sum, sum2;
  dd_real w2, w3;
  dd_real cnt0, cnt1, cnt2, cnt3, cnt4, cnt5;
  dd_real x30_i1, x30_i2, x30_i3, gw30_i1, gw30_i2, gw30_i3, w1_i1;
  dd_real tmp1, tmp2, tmp3;
  dd_real t1, t2, t3, t4, t5;
  dd_real h, s, tt, ramda, fme, fmf;

  h = _h[0];
  s = _s[0];
  tt = _tt[0];
  ramda = _ramda[0];
  fme = _fme[0];
  fmf = _fmf[0];
  x30_i1 = x30[id1];
  gw30_i1 = gw30[id1];

  // start computing
  ax = getDD(0.0);
  ay = getDD(0.0);
  az = getDD(0.0);
  bx = getDD(1.0);
  tmp2 = getDD(0.5);
  DD_TwoSub(&bx, &ax, &tmp1);
  DD_TwoProd(&tmp1, &tmp2, &cnt0);
  DD_TwoSum(&bx, &ax, &tmp1);
  DD_TwoProd(&tmp1, &tmp2, &cnt1);

  DD_TwoProd(&x30_i1, &cnt0, &tmp1);
  DD_TwoSum(&tmp1, &cnt1, &xx);
  tmp1 = getDD(1.0);
  DD_TwoSub(&tmp1, &xx, &by);
  tmp2 = getDD(0.5);
  DD_TwoSub(&by, &ay, &tmp1);
  DD_TwoProd(&tmp1, &tmp2, &cnt2);
  DD_TwoSum(&by, &ay, &tmp1);
  DD_TwoProd(&tmp1, &tmp2, &cnt3);
  
	sum2 = getDD(0.0);
	for (id2 = 0; id2 < n; id2++) {
      x30_i2 = x30[id2];
      DD_TwoProd(&x30_i2, &cnt2, &tmp1);
      DD_TwoSum(&tmp1, &cnt3, &yy);
      tmp1 = getDD(1.0);
      DD_TwoSub(&tmp1, &xx, &tmp1);
      DD_TwoSub(&tmp1, &yy, &bz);
      tmp2 = getDD(0.5);
      DD_TwoSub(&bz, &az, &tmp1);
      DD_TwoProd(&tmp1, &tmp2, &cnt4);
      DD_TwoSum(&bz, &az, &tmp1);
      DD_TwoProd(&tmp1, &tmp2, &cnt5);
      
			  sum = getDD(0.0);
	      for (id3 = 0; id3 < n; id3++) {
         x30_i3 = x30[id3];
         gw30_i2 = gw30[id2];
         gw30_i3 = gw30[id3];
         
        DD_TwoProd(&x30_i3, &cnt4, &tmp1);
        DD_TwoSum(&tmp1, &cnt5, &zz);

        // d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
        // -xx * yy * s
        DD_TwoProd(&xx, &yy, &tmp1);
        DD_TwoProd(&tmp1, &s, &tmp1);
        tmp2 = getDD(-1.0);
        DD_TwoProd(&tmp2, &tmp1, &t1);
        // tt * zz * (1.0 - xx - yy - zz)
        tmp3 = getDD(1.0);
        DD_TwoProd(&tt, &zz, &tmp1);
        DD_TwoSub(&tmp3, &xx, &tmp2);
        DD_TwoSub(&tmp2, &yy, &tmp2);
        DD_TwoSub(&tmp2, &zz, &tmp2);
        DD_TwoProd(&tmp1, &tmp2, &t2);
        // (xx + yy) * ramda * ramda
        DD_TwoSum(&xx, &yy, &tmp1);
        DD_TwoProd(&tmp1, &ramda, &tmp1);
        DD_TwoProd(&tmp1, &ramda, &t3);
        // (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
        tmp3 = getDD(1.0);
        DD_TwoSub(&tmp3, &xx, &tmp1);
        DD_TwoSub(&tmp1, &yy, &tmp1);
        DD_TwoSub(&tmp1, &zz, &tmp1);
        DD_TwoSub(&tmp3, &xx, &tmp2);
        DD_TwoSub(&tmp2, &yy, &tmp2);
        DD_TwoProd(&tmp1, &tmp2, &tmp1);
        DD_TwoProd(&tmp1, &fme, &tmp1);
        DD_TwoProd(&tmp1, &fme, &t4);
        // zz * (1.0 - xx - yy) * fmf * fmf
        tmp3 = getDD(1.0);
        DD_TwoSub(&tmp3, &xx, &tmp1);
        DD_TwoSub(&tmp1, &yy, &tmp1);
        DD_TwoProd(&tmp1, &zz, &tmp1);
        DD_TwoProd(&tmp1, &fmf, &tmp1);
        DD_TwoProd(&tmp1, &fmf, &t5);
        // t1 - t2 + t3 + t4 + t5
        DD_TwoSub(&t1, &t2, &tmp1);
        DD_TwoSum(&tmp1, &t3, &tmp1);
        DD_TwoSum(&tmp1, &t4, &tmp1);
        DD_TwoSum(&tmp1, &t5, &d);

        // w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
        DD_TwoProd(&d, &d, &tmp1);
        DD_TwoProd(&cnt0, &cnt2, &tmp2);
        DD_TwoProd(&tmp2, &cnt4, &tmp2);
        DD_TwoProd(&tmp2, &gw30_i1, &tmp2);
        DD_TwoProd(&tmp2, &gw30_i2, &tmp2);
        DD_TwoProd(&tmp2, &gw30_i3, &tmp2);
        DD_TwoDiv(&tmp2, &tmp1, &tmp3);
         
        w3 = tmp3;
				DD_TwoSum(&sum, &w3, &sum);
	      }
      DD_TwoProd(&sum, &h, &w2);
			DD_TwoSum(&sum2, &w2, &sum2);
	}
  DD_TwoProd(&sum2, &h, &w1_i1);
  w1[id1] = w1_i1;
}


__kernel void feynman_dd_full(int n, __global double *_h, __global double *_s, __global double *_tt,
                              __global double *_ramda, __global double *_fme, __global double *_fmf,
                              __global double *w1, __global double *gw30, __global double *x30)
{
  int id1 = get_global_id(0) * 2;
  int i, id2, id3;
  int gbid2, gbid3;
  double ax[2], ay[2], az[2], bx[2], by[2], bz[2];
  double xx[2], yy[2], zz[2], d[2], sum[2], sum2[2];
  double w2[2], w3[2];
  double cnt0[2], cnt1[2], cnt2[2], cnt3[2], cnt4[2], cnt5[2];
  double x30_i1[2], x30_i2[2], x30_i3[2], gw30_i1[2], gw30_i2[2], gw30_i3[2], w1_i1[2];
  double tmp1[2], tmp2[2], tmp3[2];
  double t1[2], t2[2], t3[2], t4[2], t5[2];
  double h[2], s[2], tt[2], ramda[2], fme[2], fmf[2];

  h[0] = _h[0]; h[1] = _h[1];
  s[0] = _s[0]; s[1] = _s[1];
  tt[0] = _tt[0]; tt[1] = _tt[1];
  ramda[0] = _ramda[0]; ramda[1] = _ramda[1];
  fme[0] = _fme[0]; fme[1] = _fme[1];
  fmf[0] = _fmf[0]; fmf[1] = _fmf[1];
  x30_i1[0] = x30[id1+0]; x30_i1[1] = x30[id1+1];
  gw30_i1[0] = gw30[id1+0]; gw30_i1[1] = gw30[id1+1];

  // start computing
  ax[0] = 0.0; ax[1] = 0.0;
  ay[0] = 0.0; ay[1] = 0.0;
  az[0] = 0.0; az[1] = 0.0;
  bx[0] = 1.0; bx[1] = 0.0;
  DD_TwoSub(bx, ax, tmp1);
  tmp2[0] = 0.5; tmp2[1] = 0.0;
  DD_TwoProd(tmp1, tmp2, cnt0);
  DD_TwoSum(bx, ax, tmp1);
  DD_TwoProd(tmp1, tmp2, cnt1);

  DD_TwoProd(x30_i1, cnt0, tmp1);
  DD_TwoSum(tmp1, cnt1, xx);
  tmp1[0] = 1.0; tmp1[1] = 0.0;
  DD_TwoSub(tmp1, xx, by);
  tmp2[0] = 0.5; tmp2[1] = 0.0;
  DD_TwoSub(by, ay, tmp1);
  DD_TwoProd(tmp1, tmp2, cnt2);
  DD_TwoSum(by, ay, tmp1);
  DD_TwoProd(tmp1, tmp2, cnt3);
  
	dd_zeros(sum2);
	for (id2 = 0, gbid2 = 0; id2 < n; id2++, gbid2+=2) {
      x30_i2[0] = x30[gbid2+0]; x30_i2[1] = x30[gbid2+1];
      DD_TwoProd(x30_i2, cnt2, tmp1);
      DD_TwoSum(tmp1, cnt3, yy);
      tmp1[0] = 1.0; tmp1[1] = 0.0;
      DD_TwoSub(tmp1, xx, tmp1);
      DD_TwoSub(tmp1, yy, bz);
      tmp2[0] = 0.5; tmp2[1] = 0.0;
      DD_TwoSub(bz, az, tmp1);
      DD_TwoProd(tmp1, tmp2, cnt4);
      DD_TwoSum(bz, az, tmp1);
      DD_TwoProd(tmp1, tmp2, cnt5);
      
        dd_zeros(sum);
	      for (id3 = 0, gbid3 = 0; id3 < n; id3++, gbid3+=2) {
         x30_i3[0] = x30[gbid3+0]; x30_i3[1] = x30[gbid3+1];
         gw30_i2[0] = gw30[gbid2+0]; gw30_i2[1] = gw30[gbid2+1];
         gw30_i3[0] = gw30[gbid3+0]; gw30_i3[1] = gw30[gbid3+1];
         
        DD_TwoProd(x30_i3, cnt4, tmp1);
        DD_TwoSum(tmp1, cnt5, zz);

        // d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
        // -xx * yy * s 
        DD_TwoProd(xx, yy, tmp1);
        DD_TwoProd(tmp1, s, tmp1);
        tmp2[0] = -1.0; tmp2[1] = 0.0;
        DD_TwoProd(tmp2, tmp1, t1);
        // tt * zz * (1.0 - xx - yy - zz)
        tmp3[0] = 1.0; tmp3[1] = 0.0;
        DD_TwoProd(tt, zz, tmp1);
        DD_TwoSub(tmp3, xx, tmp2);
        DD_TwoSub(tmp2, yy, tmp2);
        DD_TwoSub(tmp2, zz, tmp2);
        DD_TwoProd(tmp1, tmp2, t2);
        // (xx + yy) * ramda * ramda
        DD_TwoSum(xx, yy, tmp1);
        DD_TwoProd(tmp1, ramda, tmp1);
        DD_TwoProd(tmp1, ramda, t3);
        // (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
        tmp3[0] = 1.0; tmp3[1] = 0.0;
        DD_TwoSub(tmp3, xx, tmp1);
        DD_TwoSub(tmp1, yy, tmp1);
        DD_TwoSub(tmp1, zz, tmp1);
        DD_TwoSub(tmp3, xx, tmp2);
        DD_TwoSub(tmp2, yy, tmp2);
        DD_TwoProd(tmp1, tmp2, tmp1);
        DD_TwoProd(tmp1, fme, tmp1);
        DD_TwoProd(tmp1, fme, t4);
        // zz * (1.0 - xx - yy) * fmf * fmf
        tmp3[0] = 1.0; tmp3[1] = 0.0;
        DD_TwoSub(tmp3, xx, tmp1);
        DD_TwoSub(tmp1, yy, tmp1);
        DD_TwoProd(tmp1, zz, tmp1);
        DD_TwoProd(tmp1, fmf, tmp1);
        DD_TwoProd(tmp1, fmf, t5);
        // t1 - t2 + t3 + t4 + t5
        DD_TwoSub(t1, t2, tmp1);
        DD_TwoSum(tmp1, t3, tmp1);
        DD_TwoSum(tmp1, t4, tmp1);
        DD_TwoSum(tmp1, t5, d);

        // w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
        DD_TwoProd(d, d, tmp1);
        DD_TwoProd(cnt0, cnt2, tmp2);
        DD_TwoProd(tmp2, cnt4, tmp2);
        DD_TwoProd(tmp2, gw30_i1, tmp2);
        DD_TwoProd(tmp2, gw30_i2, tmp2);
        DD_TwoProd(tmp2, gw30_i3, tmp2);
        DD_TwoDiv(tmp2, tmp1, tmp1);
         
        w3[0] = tmp1[0]; w3[1] = tmp1[1];
				DD_TwoSum(sum, w3, sum);
	      }
      DD_TwoProd(sum, h, w2);
      DD_TwoSum(sum2, w2, sum2);
	}
  DD_TwoProd(sum2, h, w1_i1);
  w1[id1+0] = w1_i1[0];
  w1[id1+1] = w1_i1[1];
}
