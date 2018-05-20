#include "qd_arithmetic.h"
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void feynman_qd_full_d4(int n, __global qd_real *_h, __global qd_real *_s, __global qd_real *_tt,
                              __global qd_real *_ramda, __global qd_real *_fme, __global qd_real *_fmf,
                              __global qd_real *w1, __global qd_real *gw30, __global qd_real *x30)
{
  int id1 = get_global_id(0);
  int i, id2, id3;
  qd_real ax, ay, az, bx, by, bz;
  qd_real xx, yy, zz, d, sum, sum2;
  qd_real w2, w3;
  qd_real cnt0, cnt1, cnt2, cnt3, cnt4, cnt5;
  qd_real x30_i1, x30_i2, x30_i3, gw30_i1, gw30_i2, gw30_i3, w1_i1;
  qd_real tmp1, tmp2, tmp3;
  qd_real t1, t2, t3, t4, t5;
  qd_real h, s, tt, ramda, fme, fmf;

  h = _h[0];
  s = _s[0];
  tt = _tt[0];
  ramda = _ramda[0];
  fme = _fme[0];
  fmf = _fmf[0];
  x30_i1 = x30[id1];
  gw30_i1 = gw30[id1];

  // start computing
  ax = getQD(0.0);
  ay = getQD(0.0);
  az = getQD(0.0);
  bx = getQD(1.0);
  tmp2 = getQD(0.5);
  QD_sloppy_SUB(&bx, &ax, &tmp1);
  QD_sloppy_MUL(&tmp1, &tmp2, &cnt0);
  QD_sloppy_ADD(&bx, &ax, &tmp1);
  QD_sloppy_MUL(&tmp1, &tmp2, &cnt1);

  QD_sloppy_MUL(&x30_i1, &cnt0, &tmp1);
  QD_sloppy_ADD(&tmp1, &cnt1, &xx);
  tmp1 = getQD(1.0);
  QD_sloppy_SUB(&tmp1, &xx, &by);
  tmp2 = getQD(0.5);
  QD_sloppy_SUB(&by, &ay, &tmp1);
  QD_sloppy_MUL(&tmp1, &tmp2, &cnt2);
  QD_sloppy_ADD(&by, &ay, &tmp1);
  QD_sloppy_MUL(&tmp1, &tmp2, &cnt3);
  
	sum2 = getQD(0.0);
	for (id2 = 0; id2 < n; id2++) {
      x30_i2 = x30[id2];
      QD_sloppy_MUL(&x30_i2, &cnt2, &tmp1);
      QD_sloppy_ADD(&tmp1, &cnt3, &yy);
      tmp1 = getQD(1.0);
      QD_sloppy_SUB(&tmp1, &xx, &tmp1);
      QD_sloppy_SUB(&tmp1, &yy, &bz);
      tmp2 = getQD(0.5);
      QD_sloppy_SUB(&bz, &az, &tmp1);
      QD_sloppy_MUL(&tmp1, &tmp2, &cnt4);
      QD_sloppy_ADD(&bz, &az, &tmp1);
      QD_sloppy_MUL(&tmp1, &tmp2, &cnt5);
      
			  sum = getQD(0.0);
	      for (id3 = 0; id3 < n; id3++) {
         x30_i3 = x30[id3];
         gw30_i2 = gw30[id2];
         gw30_i3 = gw30[id3];
         
        QD_sloppy_MUL(&x30_i3, &cnt4, &tmp1);
        QD_sloppy_ADD(&tmp1, &cnt5, &zz);

        // d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
        // -xx * yy * s
        QD_sloppy_MUL(&xx, &yy, &tmp1);
        QD_sloppy_MUL(&tmp1, &s, &tmp1);
        tmp2 = getQD(-1.0);
        QD_sloppy_MUL(&tmp2, &tmp1, &t1);
        // tt * zz * (1.0 - xx - yy - zz)
        tmp3 = getQD(1.0);
        QD_sloppy_MUL(&tt, &zz, &tmp1);
        QD_sloppy_SUB(&tmp3, &xx, &tmp2);
        QD_sloppy_SUB(&tmp2, &yy, &tmp2);
        QD_sloppy_SUB(&tmp2, &zz, &tmp2);
        QD_sloppy_MUL(&tmp1, &tmp2, &t2);
        // (xx + yy) * ramda * ramda
        QD_sloppy_ADD(&xx, &yy, &tmp1);
        QD_sloppy_MUL(&tmp1, &ramda, &tmp1);
        QD_sloppy_MUL(&tmp1, &ramda, &t3);
        // (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
        tmp3 = getQD(1.0);
        QD_sloppy_SUB(&tmp3, &xx, &tmp1);
        QD_sloppy_SUB(&tmp1, &yy, &tmp1);
        QD_sloppy_SUB(&tmp1, &zz, &tmp1);
        QD_sloppy_SUB(&tmp3, &xx, &tmp2);
        QD_sloppy_SUB(&tmp2, &yy, &tmp2);
        QD_sloppy_MUL(&tmp1, &tmp2, &tmp1);
        QD_sloppy_MUL(&tmp1, &fme, &tmp1);
        QD_sloppy_MUL(&tmp1, &fme, &t4);
        // zz * (1.0 - xx - yy) * fmf * fmf
        tmp3 = getQD(1.0);
        QD_sloppy_SUB(&tmp3, &xx, &tmp1);
        QD_sloppy_SUB(&tmp1, &yy, &tmp1);
        QD_sloppy_MUL(&tmp1, &zz, &tmp1);
        QD_sloppy_MUL(&tmp1, &fmf, &tmp1);
        QD_sloppy_MUL(&tmp1, &fmf, &t5);
        // t1 - t2 + t3 + t4 + t5
        QD_sloppy_SUB(&t1, &t2, &tmp1);
        QD_sloppy_ADD(&tmp1, &t3, &tmp1);
        QD_sloppy_ADD(&tmp1, &t4, &tmp1);
        QD_sloppy_ADD(&tmp1, &t5, &d);

        // w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
        QD_sloppy_MUL(&d, &d, &tmp1);
        QD_sloppy_MUL(&cnt0, &cnt2, &tmp2);
        QD_sloppy_MUL(&tmp2, &cnt4, &tmp2);
        QD_sloppy_MUL(&tmp2, &gw30_i1, &tmp2);
        QD_sloppy_MUL(&tmp2, &gw30_i2, &tmp2);
        QD_sloppy_MUL(&tmp2, &gw30_i3, &tmp2);
        QD_sloppy_DIV(&tmp2, &tmp1, &tmp3);
         
        w3 = tmp3;
				QD_sloppy_ADD(&sum, &w3, &sum);
	      }
      QD_sloppy_MUL(&sum, &h, &w2);
      QD_sloppy_ADD(&sum2, &w2, &sum2);
	}
  QD_sloppy_MUL(&sum2, &h, &w1_i1);
  w1[id1] = w1_i1;
}


__kernel void feynman_qd_full(int n, __global double *_h, __global double *_s, __global double *_tt,
                              __global double *_ramda, __global double *_fme, __global double *_fmf,
                              __global double *w1, __global double *gw30, __global double *x30)
{
  int id1 = get_global_id(0) * 4;
  int i, id2, id3;
  int gbid2, gbid3;
  double ax[4], ay[4], az[4], bx[4], by[4], bz[4];
  double xx[4], yy[4], zz[4], d[4], sum[4], sum2[4];
  double w2[4], w3[4];
  double cnt0[4], cnt1[4], cnt2[4], cnt3[4], cnt4[4], cnt5[4];
  double x30_i1[4], x30_i2[4], x30_i3[4], gw30_i1[4], gw30_i2[4], gw30_i3[4], w1_i1[4];
  double tmp1[4], tmp2[4], tmp3[4];
  double t1[4], t2[4], t3[4], t4[4], t5[4];
  double h[4], s[4], tt[4], ramda[4], fme[4], fmf[4];

  h[0] = _h[0]; h[1] = _h[1]; h[2] = _h[2]; h[3] = _h[3];
  s[0] = _s[0]; s[1] = _s[1]; s[2] = _s[2]; s[3] = _s[3];
  tt[0] = _tt[0]; tt[1] = _tt[1]; tt[2] = _tt[2]; tt[3] = _tt[3];
  ramda[0] = _ramda[0]; ramda[1] = _ramda[1]; ramda[2] = _ramda[2]; ramda[3] = _ramda[3];
  fme[0] = _fme[0]; fme[1] = _fme[1]; fme[2] = _fme[2]; fme[3] = _fme[3];
  fmf[0] = _fmf[0]; fmf[1] = _fmf[1]; fmf[2] = _fmf[2]; fmf[3] = _fmf[3];
  x30_i1[0] = x30[id1+0]; x30_i1[1] = x30[id1+1]; x30_i1[2] = x30[id1+2]; x30_i1[3] = x30[id1+3];
  gw30_i1[0] = gw30[id1+0]; gw30_i1[1] = gw30[id1+1]; gw30_i1[2] = gw30[id1+2]; gw30_i1[3] = gw30[id1+3];

  // start computing
  ax[0] = 0.0; ax[1] = 0.0; ax[2] = 0.0; ax[3] = 0.0;
  ay[0] = 0.0; ay[1] = 0.0; ay[2] = 0.0; ay[3] = 0.0;
  az[0] = 0.0; az[1] = 0.0; az[2] = 0.0; az[3] = 0.0;
  bx[0] = 1.0; bx[1] = 0.0; bx[2] = 0.0; bx[3] = 0.0;
  QD_sloppy_SUB(bx, ax, tmp1);
  tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0; tmp2[3] = 0.0;
  QD_sloppy_MUL(tmp1, tmp2, cnt0);
  QD_sloppy_ADD(bx, ax, tmp1);
  QD_sloppy_MUL(tmp1, tmp2, cnt1);

  QD_sloppy_MUL(x30_i1, cnt0, tmp1);
  QD_sloppy_ADD(tmp1, cnt1, xx);
  tmp1[0] = 1.0; tmp1[1] = 0.0; tmp1[2] = 0.0; tmp1[3] = 0.0;
  QD_sloppy_SUB(tmp1, xx, by);
  tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0; tmp2[3] = 0.0;
  QD_sloppy_SUB(by, ay, tmp1);
  QD_sloppy_MUL(tmp1, tmp2, cnt2);
  QD_sloppy_ADD(by, ay, tmp1);
  QD_sloppy_MUL(tmp1, tmp2, cnt3);
  
	qd_zeros(sum2);
	for (id2 = 0, gbid2 = 0; id2 < n; id2++, gbid2+=4) {
      x30_i2[0] = x30[gbid2+0]; x30_i2[1] = x30[gbid2+1]; x30_i2[2] = x30[gbid2+2]; x30_i2[3] = x30[gbid2+3];
      QD_sloppy_MUL(x30_i2, cnt2, tmp1);
      QD_sloppy_ADD(tmp1, cnt3, yy);
      tmp1[0] = 1.0; tmp1[1] = 0.0; tmp1[2] = 0.0; tmp1[3] = 0.0;
      QD_sloppy_SUB(tmp1, xx, tmp1);
      QD_sloppy_SUB(tmp1, yy, bz);
      tmp2[0] = 0.5; tmp2[1] = 0.0; tmp2[2] = 0.0; tmp2[3] = 0.0;
      QD_sloppy_SUB(bz, az, tmp1);
      QD_sloppy_MUL(tmp1, tmp2, cnt4);
      QD_sloppy_ADD(bz, az, tmp1);
      QD_sloppy_MUL(tmp1, tmp2, cnt5);
      
			  qd_zeros(sum);
	      for (id3 = 0, gbid3 = 0; id3 < n; id3++, gbid3+=4) {
         x30_i3[0] = x30[gbid3+0]; x30_i3[1] = x30[gbid3+1]; x30_i3[2] = x30[gbid3+2]; x30_i3[3] = x30[gbid3+3];
         gw30_i2[0] = gw30[gbid2+0]; gw30_i2[1] = gw30[gbid2+1]; gw30_i2[2] = gw30[gbid2+2]; gw30_i2[3] = gw30[gbid2+3];
         gw30_i3[0] = gw30[gbid3+0]; gw30_i3[1] = gw30[gbid3+1]; gw30_i3[2] = gw30[gbid3+2]; gw30_i3[3] = gw30[gbid3+3];
         
        QD_sloppy_MUL(x30_i3, cnt4, tmp1);
        QD_sloppy_ADD(tmp1, cnt5, zz);

        // d =-xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
        // -xx * yy * s 
        QD_sloppy_MUL(xx, yy, tmp1);
        QD_sloppy_MUL(tmp1, s, tmp1);
        tmp2[0] = -1.0; tmp2[1] = 0.0; tmp2[2] = 0.0; tmp2[3] = 0.0;
        QD_sloppy_MUL(tmp2, tmp1, t1);
        // tt * zz * (1.0 - xx - yy - zz)
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0; tmp3[3] = 0.0;
        QD_sloppy_MUL(tt, zz, tmp1);
        QD_sloppy_SUB(tmp3, xx, tmp2);
        QD_sloppy_SUB(tmp2, yy, tmp2);
        QD_sloppy_SUB(tmp2, zz, tmp2);
        QD_sloppy_MUL(tmp1, tmp2, t2);
        // (xx + yy) * ramda * ramda
        QD_sloppy_ADD(xx, yy, tmp1);
        QD_sloppy_MUL(tmp1, ramda, tmp1);
        QD_sloppy_MUL(tmp1, ramda, t3);
        // (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0; tmp3[3] = 0.0;
        QD_sloppy_SUB(tmp3, xx, tmp1);
        QD_sloppy_SUB(tmp1, yy, tmp1);
        QD_sloppy_SUB(tmp1, zz, tmp1);
        QD_sloppy_SUB(tmp3, xx, tmp2);
        QD_sloppy_SUB(tmp2, yy, tmp2);
        QD_sloppy_MUL(tmp1, tmp2, tmp1);
        QD_sloppy_MUL(tmp1, fme, tmp1);
        QD_sloppy_MUL(tmp1, fme, t4);
        // zz * (1.0 - xx - yy) * fmf * fmf
        tmp3[0] = 1.0; tmp3[1] = 0.0; tmp3[2] = 0.0; tmp3[3] = 0.0;
        QD_sloppy_SUB(tmp3, xx, tmp1);
        QD_sloppy_SUB(tmp1, yy, tmp1);
        QD_sloppy_MUL(tmp1, zz, tmp1);
        QD_sloppy_MUL(tmp1, fmf, tmp1);
        QD_sloppy_MUL(tmp1, fmf, t5);
        // t1 - t2 + t3 + t4 + t5
        QD_sloppy_SUB(t1, t2, tmp1);
        QD_sloppy_ADD(tmp1, t3, tmp1);
        QD_sloppy_ADD(tmp1, t4, tmp1);
        QD_sloppy_ADD(tmp1, t5, d);

        // w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
        QD_sloppy_MUL(d, d, tmp1);
        QD_sloppy_MUL(cnt0, cnt2, tmp2);
        QD_sloppy_MUL(tmp2, cnt4, tmp2);
        QD_sloppy_MUL(tmp2, gw30_i1, tmp2);
        QD_sloppy_MUL(tmp2, gw30_i2, tmp2);
        QD_sloppy_MUL(tmp2, gw30_i3, tmp2);
        QD_sloppy_DIV(tmp2, tmp1, tmp1);
         
        w3[0] = tmp1[0]; w3[1] = tmp1[1]; w3[2] = tmp1[2]; w3[3] = tmp1[3];
				QD_sloppy_ADD(sum, w3, sum);
	      }
      QD_sloppy_MUL(sum, h, w2);
      QD_sloppy_ADD(sum2, w2, sum2);
	}
  QD_sloppy_MUL(sum2, h, w1_i1);
  w1[id1+0] = w1_i1[0];
  w1[id1+1] = w1_i1[1];
	w1[id1+2] = w1_i1[2];
  w1[id1+3] = w1_i1[3];
}
