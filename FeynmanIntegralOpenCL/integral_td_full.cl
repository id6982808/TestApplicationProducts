#include "td_arithmetic.h"
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void feynman_td_full(int n, __global double *_h, __global double *_s, __global double *_tt,
                              __global double *_ramda, __global double *_fme, __global double *_fmf,
                              __global double *w1, __global double *gw30, __global double *x30)
{
  int id1 = get_global_id(0) * 3;
  int i, id2, id3;
  int gbid2, gbid3;
  double ax[3], ay[3], az[3], bx[3], by[3], bz[3];
  double xx[3], yy[3], zz[3], d[3], sum[3], sum2[3];
  double w2[3], w3[3];
  double cnt0[3], cnt1[3], cnt2[3], cnt3[3], cnt4[3], cnt5[3];
  double x30_i1[3], x30_i2[3], x30_i3[3], gw30_i1[3], gw30_i2[3], gw30_i3[3], w1_i1[3];
  double tmp1[3], tmp2[3], tmp3[3];
  double t1[3], t2[3], t3[3], t4[3], t5[3];
  double h[3], s[3], tt[3], ramda[3], fme[3], fmf[3];

  h[0] = _h[0]; h[1] = _h[1]; h[2] = _h[2];
  s[0] = _s[0]; s[1] = _s[1]; s[2] = _s[2];
  tt[0] = _tt[0]; tt[1] = _tt[1]; tt[2] = _tt[2];
  ramda[0] = _ramda[0]; ramda[1] = _ramda[1]; ramda[2] = _ramda[2];
  fme[0] = _fme[0]; fme[1] = _fme[1]; fme[2] = _fme[2];
  fmf[0] = _fmf[0]; fmf[1] = _fmf[1]; fmf[2] = _fmf[2];
  x30_i1[0] = x30[id1+0]; x30_i1[1] = x30[id1+1]; x30_i1[2] = x30[id1+2];
  gw30_i1[0] = gw30[id1+0]; gw30_i1[1] = gw30[id1+1]; gw30_i1[2] = gw30[id1+2];

  // start computing
  ax[0] = 0.0; ax[1] = 0.0; ax[2] = 0.0;
  ay[0] = 0.0; ay[1] = 0.0; ay[2] = 0.0;
  az[0] = 0.0; az[1] = 0.0; az[2] = 0.0;
  bx[0] = 1.0; bx[1] = 0.0; bx[2] = 0.0;
  tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0;
  TD_SUB(bx, ax, tmp1);
  TD_MUL(tmp1, tmp2, cnt0);
  TD_ADD(bx, ax, tmp1);
  TD_MUL(tmp1, tmp2, cnt1);

  TD_MUL(x30_i1, cnt0, tmp1);
  TD_ADD(tmp1, cnt1, xx);
  tmp1[0] = 1.0; tmp1[1] = 0.0; tmp1[2] = 0.0;
  TD_SUB(tmp1, xx, by);
  tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0;
  TD_SUB(by, ay, tmp1);
  TD_MUL(tmp1, tmp2, cnt2);
  TD_ADD(by, ay, tmp1);
  TD_MUL(tmp1, tmp2, cnt3);
  
	td_zeros(sum2);
	for (id2 = 0, gbid2 = 0; id2 < n; id2++, gbid2+=3) {
      x30_i2[0] = x30[gbid2+0]; x30_i2[1] = x30[gbid2+1]; x30_i2[2] = x30[gbid2+2];
      TD_MUL(x30_i2, cnt2, tmp1);
      TD_ADD(tmp1, cnt3, yy);
      tmp1[0] = 1.0; tmp1[1] = 0.0; tmp1[2] = 0.0;
      TD_SUB(tmp1, xx, tmp1);
      TD_SUB(tmp1, yy, bz);
      tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0;
      TD_SUB(bz, az, tmp1);
      TD_MUL(tmp1, tmp2, cnt4);
      TD_ADD(bz, az, tmp1);
      TD_MUL(tmp1, tmp2, cnt5);
      
			  td_zeros(sum);
	      for (id3 = 0, gbid3 = 0; id3 < n; id3++, gbid3+=3) {
         x30_i3[0] = x30[gbid3+0]; x30_i3[1] = x30[gbid3+1]; x30_i3[2] = x30[gbid3+2];
         gw30_i2[0] = gw30[gbid2+0]; gw30_i2[1] = gw30[gbid2+1]; gw30_i2[2] = gw30[gbid2+2];
         gw30_i3[0] = gw30[gbid3+0]; gw30_i3[1] = gw30[gbid3+1]; gw30_i3[2] = gw30[gbid3+2];
         
        TD_MUL(x30_i3, cnt4, tmp1);
        TD_ADD(tmp1, cnt5, zz);

        // d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
        // -xx * yy * s 
        TD_MUL(xx, yy, tmp1);
        TD_MUL(tmp1, s, tmp1);
        tmp2[0] = -1.0; tmp2[1] = 0.0; tmp2[2] = 0.0;
        TD_MUL(tmp2, tmp1, t1);
        // tt * zz * (1.0 - xx - yy - zz)
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0;
        TD_MUL(tt, zz, tmp1);
        TD_SUB(tmp3, xx, tmp2);
        TD_SUB(tmp2, yy, tmp2);
        TD_SUB(tmp2, zz, tmp2);
        TD_MUL(tmp1, tmp2, t2);
        // (xx + yy) * ramda * ramda
        TD_ADD(xx, yy, tmp1);
        TD_MUL(tmp1, ramda, tmp1);
        TD_MUL(tmp1, ramda, t3);
        // (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0;
        TD_SUB(tmp3, xx, tmp1);
        TD_SUB(tmp1, yy, tmp1);
        TD_SUB(tmp1, zz, tmp1);
        TD_SUB(tmp3, xx, tmp2);
        TD_SUB(tmp2, yy, tmp2);
        TD_MUL(tmp1, tmp2, tmp1);
        TD_MUL(tmp1, fme, tmp1);
        TD_MUL(tmp1, fme, t4);
        // zz * (1.0 - xx - yy) * fmf * fmf
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0;
        TD_SUB(tmp3, xx, tmp1);
        TD_SUB(tmp1, yy, tmp1);
        TD_MUL(tmp1, zz, tmp1);
        TD_MUL(tmp1, fmf, tmp1);
        TD_MUL(tmp1, fmf, t5);
        // t1 - t2 + t3 + t4 + t5
        TD_SUB(t1, t2, tmp1);
        TD_ADD(tmp1, t3, tmp1);
        TD_ADD(tmp1, t4, tmp1);
        TD_ADD(tmp1, t5, d);

        // w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
        TD_MUL(d, d, tmp1);
        TD_MUL(cnt0, cnt2, tmp2);
        TD_MUL(tmp2, cnt4, tmp2);
        TD_MUL(tmp2, gw30_i1, tmp2);
        TD_MUL(tmp2, gw30_i2, tmp2);
        TD_MUL(tmp2, gw30_i3, tmp2);
        TD_DIV(tmp2, tmp1, tmp1);
         
        w3[0] = tmp1[0]; w3[1] = tmp1[1]; w3[2] = tmp1[2];
				TD_ADD(sum, w3, sum);
	      }
      TD_MUL(sum, h, w2);
      TD_ADD(sum2, w2, sum2);
	}
  TD_MUL(sum2, h, w1_i1);
  w1[id1+0] = w1_i1[0];
  w1[id1+1] = w1_i1[1];
  w1[id1+2] = w1_i1[2];
}
