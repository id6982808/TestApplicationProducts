__kernel void gravity_q_kernel(__global double * g_xi, __global double * g_yi, __global double * g_zi, __global double * g_e2, __global double * g_rsqrt, __global double * g_xj, __global double * g_yj, __global double * g_zj, __global double * g_mj, __global double * g_ax, __global double * g_ay, __global double * g_az, __global double * g_dx, __global double * g_dy, __global double * g_dz, __global double * g_r1i, __global double * g_af)
{
	int id3;
	int id1 = get_global_id(0) % n;
	int id2 = get_global_id(0) / n;
	double t[4][4];
	double xi[4], yi[4], zi[4], e2[4], rsqrt[4];
	double xj[4], yj[4], zj[4], mj[4];
	double ax[4], ay[4], az[4];
	double dx[4], dy[4], dz[4], r1i[4], af[4];
	
	xi[0] = g_xi[id1*n*4 +id2*4 +0]; xi[1] = g_xi[id1*n*4 +id2*4 +1]; xi[2] = g_xi[id1*n*4 +id2*4 +2]; xi[3] = g_xi[id1*n*4 +id2*4 +3];
	yi[0] = g_yi[id1*n*4 +id2*4 +0]; yi[1] = g_yi[id1*n*4 +id2*4 +1]; yi[2] = g_yi[id1*n*4 +id2*4 +2]; yi[3] = g_yi[id1*n*4 +id2*4 +3];
	zi[0] = g_zi[id1*n*4 +id2*4 +0]; zi[1] = g_zi[id1*n*4 +id2*4 +1]; zi[2] = g_zi[id1*n*4 +id2*4 +2]; zi[3] = g_zi[id1*n*4 +id2*4 +3];
	e2[0] = g_e2[id1*n*4 +id2*4 +0]; e2[1] = g_e2[id1*n*4 +id2*4 +1]; e2[2] = g_e2[id1*n*4 +id2*4 +2]; e2[3] = g_e2[id1*n*4 +id2*4 +3];
	rsqrt[0] = g_rsqrt[id1*n*4 +id2*4 +0]; rsqrt[1] = g_rsqrt[id1*n*4 +id2*4 +1]; rsqrt[2] = g_rsqrt[id1*n*4 +id2*4 +2]; rsqrt[3] = g_rsqrt[id1*n*4 +id2*4 +3];
	ax[0] = 0.0; ax[1] = 0.0; ax[2] = 0.0; ax[3] = 0.0;
	ay[0] = 0.0; ay[1] = 0.0; ay[2] = 0.0; ay[3] = 0.0;
	az[0] = 0.0; az[1] = 0.0; az[2] = 0.0; az[3] = 0.0;
	dx[0] = g_dx[0]; dx[1] = g_dx[1]; dx[2] = g_dx[2]; dx[3] = g_dx[3];
	dy[0] = g_dy[0]; dy[1] = g_dy[1]; dy[2] = g_dy[2]; dy[3] = g_dy[3];
	dz[0] = g_dz[0]; dz[1] = g_dz[1]; dz[2] = g_dz[2]; dz[3] = g_dz[3];
	r1i[0] = g_r1i[0]; r1i[1] = g_r1i[1]; r1i[2] = g_r1i[2]; r1i[3] = g_r1i[3];
	af[0] = g_af[0]; af[1] = g_af[1]; af[2] = g_af[2]; af[3] = g_af[3];
	
	for(id3=0; id3<n*4; id3++){
	xj[0] = g_xj[id3*4 +0]; xj[1] = g_xj[id3*4 +1]; xj[2] = g_xj[id3*4 +2]; xj[3] = g_xj[id3*4 +3];
	yj[0] = g_yj[id3*4 +0]; yj[1] = g_yj[id3*4 +1]; yj[2] = g_yj[id3*4 +2]; yj[3] = g_yj[id3*4 +3];
	zj[0] = g_zj[id3*4 +0]; zj[1] = g_zj[id3*4 +1]; zj[2] = g_zj[id3*4 +2]; zj[3] = g_zj[id3*4 +3];
	mj[0] = g_mj[id3*4 +0]; mj[1] = g_mj[id3*4 +1]; mj[2] = g_mj[id3*4 +2]; mj[3] = g_mj[id3*4 +3];
	QD_sloppy_SUB(xj, xi, dx);
	
	QD_sloppy_SUB(yj, yi, dy);
	
	QD_sloppy_SUB(zj, zi, dz);
	
	
	QD_sloppy_MUL(mj, r1i, t[0]);
	QD_sloppy_MUL(t[0], mj, t[1]);
	QD_sloppy_MUL(t[1], r1i, t[2]);
	QD_sloppy_MUL(t[2], mj, t[3]);
	QD_sloppy_MUL(t[3], r1i, af);
	
	QD_sloppy_MUL(af, dx, t[0]);
	QD_sloppy_ADD(ax, t[0], ax);
	
	QD_sloppy_MUL(af, dy, t[0]);
	QD_sloppy_ADD(ay, t[0], ay);
	
	QD_sloppy_MUL(af, dz, t[0]);
	QD_sloppy_ADD(az, t[0], az);
	
	}
	g_ax[id1*n*4 +id2*4 +0] = ax[0]; g_ax[id1*n*4 +id2*4 +1] = ax[1]; g_ax[id1*n*4 +id2*4 +2] = ax[2]; g_ax[id1*n*4 +id2*4 +3] = ax[3];
	g_ay[id1*n*4 +id2*4 +0] = ay[0]; g_ay[id1*n*4 +id2*4 +1] = ay[1]; g_ay[id1*n*4 +id2*4 +2] = ay[2]; g_ay[id1*n*4 +id2*4 +3] = ay[3];
	g_az[id1*n*4 +id2*4 +0] = az[0]; g_az[id1*n*4 +id2*4 +1] = az[1]; g_az[id1*n*4 +id2*4 +2] = az[2]; g_az[id1*n*4 +id2*4 +3] = az[3];
}
