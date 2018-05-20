#include "td_arithmetic.h"

__kernel void _tdgemm(__global double *alpha,
                       __global double *beta,
                       __global double *matrix1,
                       __global double *matrix2,
                       __global double *matrix3,
                       int DIM)
{
    int idx = get_global_id(0) % DIM;
    int idy = get_global_id(0) / DIM;

    int i, j;
    double e1[3], e2[3], e3[3];
    double alp[3], bet[3];
    double tmp[3], ans[3];

    alp[0] = alpha[0]; alp[1] = alpha[1]; alp[2] = alpha[2];
    bet[0] = beta[0]; bet[1] = beta[1]; bet[2] = beta[2]; 
    tmp[0] = 0.0; tmp[1] = 0.0; tmp[2] = 0.0;
    ans[0] = 0.0; ans[1] = 0.0; ans[2] = 0.0;
    
    e3[0] = matrix3[idy * DIM*3 + idx*3 +0];
    e3[1] = matrix3[idy * DIM*3 + idx*3 +1];
    e3[2] = matrix3[idy * DIM*3 + idx*3 +2];
    
    TD_MUL(bet, e3, e3);

    for (i = 0; i < DIM; i++) {
  e1[0] = matrix1[idy * DIM*3 + i*3 +0];
  e1[1] = matrix1[idy * DIM*3 + i*3 +1];
  e1[2] = matrix1[idy * DIM*3 + i*3 +2];
  
  e2[0] = matrix2[i * DIM*3 + idx*3 +0];
  e2[1] = matrix2[i * DIM*3 + idx*3 +1];
  e2[2] = matrix2[i * DIM*3 + idx*3 +2];
  
	TD_MUL(e1, e2, tmp);
	TD_ADD(tmp, ans, ans);
    }

    TD_MUL(alp, ans, ans);
    TD_ADD(e3, ans, ans);

    matrix3[idy * DIM*3 + idx*3 +0] = ans[0];
    matrix3[idy * DIM*3 + idx*3 +1] = ans[1];
    matrix3[idy * DIM*3 + idx*3 +2] = ans[2];
}

__kernel void _tdgemm_2x2(__global double *alpha,
                       __global double *beta,
                       __global double *matrix1,
                       __global double *matrix2,
                       __global double *matrix3,
                       int DIM)
{
    int idx = 2 * (get_global_id(0) % (DIM / 2));
    int idy = 2 * (get_global_id(0) / (DIM / 2));

    int i, j;
    double e1[3], e2[3], e3[2*2][3];
    double alp[3], bet[3];
    double tmp[3], ans[2*2][3];

    alp[0] = alpha[0]; alp[1] = alpha[1]; alp[2] = alpha[2];
    bet[0] = beta[0]; bet[1] = beta[1]; bet[2] = beta[2]; 
    tmp[0] = 0.0; tmp[1] = 0.0; tmp[2] = 0.0;
    for(i=0; i<2*2; i++){
      ans[i][0] = 0.0; ans[i][1] = 0.0; ans[i][2] = 0.0;
    }
    e3[0][0] = matrix3[idy * DIM*3 + idx*3 +0];
    e3[0][1] = matrix3[idy * DIM*3 + idx*3 +1];
    e3[0][2] = matrix3[idy * DIM*3 + idx*3 +2];
    e3[1][0] = matrix3[idy * DIM*3 + (idx+1)*3 +0];
    e3[1][1] = matrix3[idy * DIM*3 + (idx+1)*3 +1];
    e3[1][2] = matrix3[idy * DIM*3 + (idx+1)*3 +2];
    e3[2][0] = matrix3[(idy+1) * DIM*3 + idx*3 +0];
    e3[2][1] = matrix3[(idy+1) * DIM*3 + idx*3 +1];
    e3[2][2] = matrix3[(idy+1) * DIM*3 + idx*3 +2];
    e3[3][0] = matrix3[(idy+1) * DIM*3 + (idx+1)*3 +0];
    e3[3][1] = matrix3[(idy+1) * DIM*3 + (idx+1)*3 +1];
    e3[3][2] = matrix3[(idy+1) * DIM*3 + (idx+1)*3 +2];
    
    TD_MUL(bet, e3[0], e3[0]);
    TD_MUL(bet, e3[1], e3[1]);
    TD_MUL(bet, e3[2], e3[2]);
    TD_MUL(bet, e3[3], e3[3]);

    for (i = 0; i < DIM; i++) {
  e1[0] = matrix1[idy * DIM*3 + i*3 +0];
  e1[1] = matrix1[idy * DIM*3 + i*3 +1];
  e1[2] = matrix1[idy * DIM*3 + i*3 +2];
  e2[0] = matrix2[i * DIM*3 + idx*3 +0];
  e2[1] = matrix2[i * DIM*3 + idx*3 +1];
  e2[2] = matrix2[i * DIM*3 + idx*3 +2];
	TD_MUL(e1, e2, tmp);
	TD_ADD(tmp, ans[0], ans[0]);
  
  e1[0] = matrix1[idy * DIM*3 + i*3 +0];
  e1[1] = matrix1[idy * DIM*3 + i*3 +1];
  e1[2] = matrix1[idy * DIM*3 + i*3 +2];
  e2[0] = matrix2[i * DIM*3 + (idx+1)*3 +0];
  e2[1] = matrix2[i * DIM*3 + (idx+1)*3 +1];
  e2[2] = matrix2[i * DIM*3 + (idx+1)*3 +2];
	TD_MUL(e1, e2, tmp);
	TD_ADD(tmp, ans[1], ans[1]);
  
  e1[0] = matrix1[(idy+1) * DIM*3 + i*3 +0];
  e1[1] = matrix1[(idy+1) * DIM*3 + i*3 +1];
  e1[2] = matrix1[(idy+1) * DIM*3 + i*3 +2];
  e2[0] = matrix2[i * DIM*3 + idx*3 +0];
  e2[1] = matrix2[i * DIM*3 + idx*3 +1];
  e2[2] = matrix2[i * DIM*3 + idx*3 +2];
	TD_MUL(e1, e2, tmp);
	TD_ADD(tmp, ans[2], ans[2]);
  
  e1[0] = matrix1[(idy+1) * DIM*3 + i*3 +0];
  e1[1] = matrix1[(idy+1) * DIM*3 + i*3 +1];
  e1[2] = matrix1[(idy+1) * DIM*3 + i*3 +2];
  e2[0] = matrix2[i * DIM*3 + (idx+1)*3 +0];
  e2[1] = matrix2[i * DIM*3 + (idx+1)*3 +1];
  e2[2] = matrix2[i * DIM*3 + (idx+1)*3 +2];
	TD_MUL(e1, e2, tmp);
	TD_ADD(tmp, ans[3], ans[3]);
    }

    TD_MUL(alp, ans[0], ans[0]);
    TD_ADD(e3[0], ans[0], ans[0]);
    TD_MUL(alp, ans[1], ans[1]);
    TD_ADD(e3[1], ans[1], ans[1]);
    TD_MUL(alp, ans[2], ans[2]);
    TD_ADD(e3[2], ans[2], ans[2]);
    TD_MUL(alp, ans[3], ans[3]);
    TD_ADD(e3[3], ans[3], ans[3]);

    matrix3[idy * DIM*3 + idx*3 +0] = ans[0][0];
    matrix3[idy * DIM*3 + idx*3 +1] = ans[0][1];
    matrix3[idy * DIM*3 + idx*3 +2] = ans[0][2];
    matrix3[idy * DIM*3 + (idx+1)*3 +0] = ans[1][0];
    matrix3[idy * DIM*3 + (idx+1)*3 +1] = ans[1][1];
    matrix3[idy * DIM*3 + (idx+1)*3 +2] = ans[1][2];
    matrix3[(idy+1) * DIM*3 + idx*3 +0] = ans[2][0];
    matrix3[(idy+1) * DIM*3 + idx*3 +1] = ans[2][1];
    matrix3[(idy+1) * DIM*3 + idx*3 +2] = ans[2][2];
    matrix3[(idy+1) * DIM*3 + (idx+1)*3 +0] = ans[3][0];
    matrix3[(idy+1) * DIM*3 + (idx+1)*3 +1] = ans[3][1];
    matrix3[(idy+1) * DIM*3 + (idx+1)*3 +2] = ans[3][2];
}