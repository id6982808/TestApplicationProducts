
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void feynman_d(int n, int id1, int id2, double s, double tt, double ramda, double fme, double fmf,
																			double cnt0, double cnt2, double cnt4, double cnt5, double xx, double yy,
																			__global double *w3, __global double *gw30, __global double *x30)
{
		// loop index (thread id)
		int id3 = get_global_id(0);

		// computed variables
		double zz, d;
		
		double _x30, _gw30i1, _gw30i2, _gw30i3, _w3;
		double tmp, tmp2, tmp3, tmp4, tmp5, tmp6, zero=0.0, t1, t2, t3, t4, t5;

		tmp = 0.0; tmp2 = 0.0; tmp3 = 0.0; tmp4 = 0.0; tmp5 = 0.0; tmp6 = 0.0;
		_x30 = x30[id3];
		_gw30i1 = gw30[id1];		
		_gw30i2 = gw30[id2];
		_gw30i3 = gw30[id3];

		// start computing
			zz = x30[id3] * cnt4 + cnt5;
			d = -xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
			w3[id3] = (cnt0 * cnt2 * cnt4 * gw30[id1] * gw30[id2] * gw30[id3]) / (d * d);
}
