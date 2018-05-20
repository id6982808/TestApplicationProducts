#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void feynman_d_full(int n, double h, double s, double tt, double ramda, double fme, double fmf,
                             __global double *w1, __global double *gw30, __global double *x30)
{
  int id1 = get_global_id(0);
  int i, id2, id3;
  double ax, ay, az, bx, by, bz;
  double xx, yy, zz, d, sum, sum2;
  double w2, w3;
  double cnt0, cnt1, cnt2, cnt3, cnt4, cnt5;
  double x30_i1, x30_i2, x30_i3, gw30_i1, gw30_i2, gw30_i3, w1_i1;
  
  x30_i1 = x30[id1];
  gw30_i1 = gw30[id1];

  // start computing
  ax = 0.0;
  ay = 0.0;
  az = 0.0;
  bx = 1.0;
  cnt0 = (bx - ax) * 0.5;
  cnt1 = (bx + ax) * 0.5;

	xx = x30_i1 * cnt0 + cnt1;
	by = 1.0 - xx;
	cnt2 = (by - ay) * 0.5;
	cnt3 = (by + ay) * 0.5;
	sum2 = 0.0;
	for (id2 = 0; id2 < n; id2++) {
      x30_i2 = x30[id2];
	    yy = x30_i2 * cnt2 + cnt3;
	    bz = 1.0 - xx - yy;
	    cnt4 = (bz - az) * 0.5;
	    cnt5 = (bz + az) * 0.5;
         sum = 0.0;
	       for (id3 = 0; id3 < n; id3++) {
         x30_i3 = x30[id3];
         gw30_i2 = gw30[id2];
         gw30_i3 = gw30[id3];
	       zz = x30_i3 * cnt4 + cnt5;
	       d = -xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
	       w3 = (cnt0 * cnt2 * cnt4 * gw30_i1 * gw30_i2 * gw30_i3) / (d * d);
				 sum = sum + w3;
	       }
	    w2 = sum * h;
			sum2 = sum2 + w2;
	}
	w1_i1 = sum2 * h;   
  w1[id1] = w1_i1;
}