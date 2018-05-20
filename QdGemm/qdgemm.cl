#include "td_arithmetic.h"
#include "qd_arithmetic.h"

__kernel void _qdgemm(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = get_global_id(0) % DIM;
    int idy = get_global_id(0) / DIM;

    int i, j;
    qd_real e1, e2, e3;
    qd_real alp, bet;
    qd_real tmp, ans;
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    ans = zero;
    
    e3 = matrix3[idy * DIM + idx];
    QD_sloppy_MUL(&bet, &e3, &e3);

    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans, &ans);
    }

    QD_sloppy_MUL(&alp, &ans, &ans);
    QD_sloppy_ADD(&e3, &ans, &ans);

    matrix3[idy * DIM + idx] = ans;
}

__kernel void _qdgemm_1x2(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = 2 * (get_global_id(0) % (DIM / 2));
    int idy = 1 * (get_global_id(0) / (DIM / 2));

    int i, j;
    qd_real e1, e2, e3[1*2];
    qd_real alp, bet;
    qd_real tmp, ans[1*2];
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    for(i=0;i<1*2;i++){
      ans[i] = zero;
    }
    
    e3[0] = matrix3[idy * DIM + idx];
    e3[1] = matrix3[idy * DIM + (idx+1)];
    QD_sloppy_MUL(&bet, &e3[0], &e3[0]);
    QD_sloppy_MUL(&bet, &e3[1], &e3[1]);
    
    
    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[0], &ans[0]);
  
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[1], &ans[1]);
    }

    QD_sloppy_MUL(&alp, &ans[0], &ans[0]);
    QD_sloppy_ADD(&e3[0], &ans[0], &ans[0]);
    QD_sloppy_MUL(&alp, &ans[1], &ans[1]);
    QD_sloppy_ADD(&e3[1], &ans[1], &ans[1]);

    matrix3[idy * DIM + idx] = ans[0];
    matrix3[idy * DIM + (idx+1)] = ans[1];
}

__kernel void _qdgemm_2x1(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = 1 * (get_global_id(0) % (DIM / 1));
    int idy = 2 * (get_global_id(0) / (DIM / 1));

    int i, j;
    qd_real e1, e2, e3[2*1];
    qd_real alp, bet;
    qd_real tmp, ans[2*1];
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    for(i=0;i<2*1;i++){
      ans[i] = zero;
    }
    
    e3[0] = matrix3[idy * DIM + idx];
    e3[1] = matrix3[(idy+1) * DIM + idx];
    QD_sloppy_MUL(&bet, &e3[0], &e3[0]);
    QD_sloppy_MUL(&bet, &e3[1], &e3[1]);
    
    
    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[0], &ans[0]);
  
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[1], &ans[1]);
    }

    QD_sloppy_MUL(&alp, &ans[0], &ans[0]);
    QD_sloppy_ADD(&e3[0], &ans[0], &ans[0]);
    QD_sloppy_MUL(&alp, &ans[1], &ans[1]);
    QD_sloppy_ADD(&e3[1], &ans[1], &ans[1]);

    matrix3[idy * DIM + idx] = ans[0];
    matrix3[(idy+1) * DIM + idx] = ans[1];
}

__kernel void _qdgemm_2x2(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = 2 * (get_global_id(0) % (DIM / 2));
    int idy = 2 * (get_global_id(0) / (DIM / 2));

    int i, j;
    qd_real e1, e2, e3[4];
    qd_real alp, bet;
    qd_real tmp, ans[4];
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    for(i=0;i<4;i++){
      ans[i] = zero;
    }
    
    e3[0] = matrix3[idy * DIM + idx];
    e3[1] = matrix3[idy * DIM + (idx+1)];
    e3[2] = matrix3[(idy+1) * DIM + idx];
    e3[3] = matrix3[(idy+1) * DIM + (idx+1)];
    QD_sloppy_MUL(&bet, &e3[0], &e3[0]);
    QD_sloppy_MUL(&bet, &e3[1], &e3[1]);
    QD_sloppy_MUL(&bet, &e3[2], &e3[2]);
    QD_sloppy_MUL(&bet, &e3[3], &e3[3]);
    
    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[0], &ans[0]);
  
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[1], &ans[1]);
  
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[2], &ans[2]);
  
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[3], &ans[3]);
    }

    QD_sloppy_MUL(&alp, &ans[0], &ans[0]);
    QD_sloppy_ADD(&e3[0], &ans[0], &ans[0]);
    QD_sloppy_MUL(&alp, &ans[1], &ans[1]);
    QD_sloppy_ADD(&e3[1], &ans[1], &ans[1]);
    QD_sloppy_MUL(&alp, &ans[2], &ans[2]);
    QD_sloppy_ADD(&e3[2], &ans[2], &ans[2]);
    QD_sloppy_MUL(&alp, &ans[3], &ans[3]);
    QD_sloppy_ADD(&e3[3], &ans[3], &ans[3]);

    matrix3[idy * DIM + idx] = ans[0];
    matrix3[idy * DIM + (idx+1)] = ans[1];
    matrix3[(idy+1) * DIM + idx] = ans[2];
    matrix3[(idy+1) * DIM + (idx+1)] = ans[3];
}

__kernel void _qdgemm_4x4(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = 4 * (get_global_id(0) % (DIM / 4));
    int idy = 4 * (get_global_id(0) / (DIM / 4));

    int i, j;
    qd_real e1, e2, e3[4*4];
    qd_real alp, bet;
    qd_real tmp, ans[4*4];
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    for(i=0;i<4*4;i++){
      ans[i] = zero;
    }
    
    e3[0] = matrix3[idy * DIM + idx];
    e3[1] = matrix3[idy * DIM + (idx+1)];
    e3[2] = matrix3[idy * DIM + (idx+2)];
    e3[3] = matrix3[idy * DIM + (idx+3)];
    e3[4] = matrix3[(idy+1) * DIM + idx];
    e3[5] = matrix3[(idy+1) * DIM + (idx+1)];
    e3[6] = matrix3[(idy+1) * DIM + (idx+2)];
    e3[7] = matrix3[(idy+1) * DIM + (idx+3)];
    e3[8] = matrix3[(idy+2) * DIM + idx];
    e3[9] = matrix3[(idy+2) * DIM + (idx+1)];
    e3[10] = matrix3[(idy+2) * DIM + (idx+2)];
    e3[11] = matrix3[(idy+2) * DIM + (idx+3)];
    e3[12] = matrix3[(idy+3) * DIM + idx];
    e3[13] = matrix3[(idy+3) * DIM + (idx+1)];
    e3[14] = matrix3[(idy+3) * DIM + (idx+2)];
    e3[15] = matrix3[(idy+3) * DIM + (idx+3)];
    
    QD_sloppy_MUL(&bet, &e3[0], &e3[0]);
    QD_sloppy_MUL(&bet, &e3[1], &e3[1]);
    QD_sloppy_MUL(&bet, &e3[2], &e3[2]);
    QD_sloppy_MUL(&bet, &e3[3], &e3[3]);
    QD_sloppy_MUL(&bet, &e3[4], &e3[4]);
    QD_sloppy_MUL(&bet, &e3[5], &e3[5]);
    QD_sloppy_MUL(&bet, &e3[6], &e3[6]);
    QD_sloppy_MUL(&bet, &e3[7], &e3[7]);
    QD_sloppy_MUL(&bet, &e3[8], &e3[8]);
    QD_sloppy_MUL(&bet, &e3[9], &e3[9]);
    QD_sloppy_MUL(&bet, &e3[10], &e3[10]);
    QD_sloppy_MUL(&bet, &e3[11], &e3[11]);
    QD_sloppy_MUL(&bet, &e3[12], &e3[12]);
    QD_sloppy_MUL(&bet, &e3[13], &e3[13]);
    QD_sloppy_MUL(&bet, &e3[14], &e3[14]);
    QD_sloppy_MUL(&bet, &e3[15], &e3[15]);
    
    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[0], &ans[0]);
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[1], &ans[1]);
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + (idx+2)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[2], &ans[2]);
  e1 = matrix1[idy * DIM + i];
  e2 = matrix2[i * DIM + (idx+3)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[3], &ans[3]);
  
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[4], &ans[4]);
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[5], &ans[5]);
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + (idx+2)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[6], &ans[6]);
  e1 = matrix1[(idy+1) * DIM + i];
  e2 = matrix2[i * DIM + (idx+3)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[7], &ans[7]);
  
  e1 = matrix1[(idy+2) * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[8], &ans[8]);
  e1 = matrix1[(idy+2) * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[9], &ans[9]);
  e1 = matrix1[(idy+2) * DIM + i];
  e2 = matrix2[i * DIM + (idx+2)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[10], &ans[10]);
  e1 = matrix1[(idy+2) * DIM + i];
  e2 = matrix2[i * DIM + (idx+3)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[11], &ans[11]);
  
  e1 = matrix1[(idy+3) * DIM + i];
  e2 = matrix2[i * DIM + idx];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[12], &ans[12]);
  e1 = matrix1[(idy+3) * DIM + i];
  e2 = matrix2[i * DIM + (idx+1)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[13], &ans[13]);
  e1 = matrix1[(idy+3) * DIM + i];
  e2 = matrix2[i * DIM + (idx+2)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[14], &ans[14]);
  e1 = matrix1[(idy+3) * DIM + i];
  e2 = matrix2[i * DIM + (idx+3)];
	QD_sloppy_MUL(&e1, &e2, &tmp);
	QD_sloppy_ADD(&tmp, &ans[15], &ans[15]);
    }

    QD_sloppy_MUL(&alp, &ans[0], &ans[0]);
    QD_sloppy_ADD(&e3[0], &ans[0], &ans[0]);
    QD_sloppy_MUL(&alp, &ans[1], &ans[1]);
    QD_sloppy_ADD(&e3[1], &ans[1], &ans[1]);
    QD_sloppy_MUL(&alp, &ans[2], &ans[2]);
    QD_sloppy_ADD(&e3[2], &ans[2], &ans[2]);
    QD_sloppy_MUL(&alp, &ans[3], &ans[3]);
    QD_sloppy_ADD(&e3[3], &ans[3], &ans[3]);
    QD_sloppy_MUL(&alp, &ans[4], &ans[4]);
    QD_sloppy_ADD(&e3[4], &ans[4], &ans[4]);
    QD_sloppy_MUL(&alp, &ans[5], &ans[5]);
    QD_sloppy_ADD(&e3[5], &ans[5], &ans[5]);
    QD_sloppy_MUL(&alp, &ans[6], &ans[6]);
    QD_sloppy_ADD(&e3[6], &ans[6], &ans[6]);
    QD_sloppy_MUL(&alp, &ans[7], &ans[7]);
    QD_sloppy_ADD(&e3[7], &ans[7], &ans[7]);
    QD_sloppy_MUL(&alp, &ans[8], &ans[8]);
    QD_sloppy_ADD(&e3[8], &ans[8], &ans[8]);
    QD_sloppy_MUL(&alp, &ans[9], &ans[9]);
    QD_sloppy_ADD(&e3[9], &ans[9], &ans[9]);
    QD_sloppy_MUL(&alp, &ans[10], &ans[10]);
    QD_sloppy_ADD(&e3[10], &ans[10], &ans[10]);
    QD_sloppy_MUL(&alp, &ans[11], &ans[11]);
    QD_sloppy_ADD(&e3[11], &ans[11], &ans[11]);
    QD_sloppy_MUL(&alp, &ans[12], &ans[12]);
    QD_sloppy_ADD(&e3[12], &ans[12], &ans[12]);
    QD_sloppy_MUL(&alp, &ans[13], &ans[13]);
    QD_sloppy_ADD(&e3[13], &ans[13], &ans[13]);
    QD_sloppy_MUL(&alp, &ans[14], &ans[14]);
    QD_sloppy_ADD(&e3[14], &ans[14], &ans[14]);
    QD_sloppy_MUL(&alp, &ans[15], &ans[15]);
    QD_sloppy_ADD(&e3[15], &ans[15], &ans[15]);

    matrix3[idy * DIM + idx] = ans[0];
    matrix3[idy * DIM + (idx+1)] = ans[1];
    matrix3[idy * DIM + (idx+2)] = ans[2];
    matrix3[idy * DIM + (idx+3)] = ans[3];
    matrix3[(idy+1) * DIM + idx] = ans[4];
    matrix3[(idy+1) * DIM + (idx+1)] = ans[5];
    matrix3[(idy+1) * DIM + (idx+2)] = ans[6];
    matrix3[(idy+1) * DIM + (idx+3)] = ans[7];
    matrix3[(idy+2) * DIM + idx] = ans[8];
    matrix3[(idy+2) * DIM + (idx+1)] = ans[9];
    matrix3[(idy+2) * DIM + (idx+2)] = ans[10];
    matrix3[(idy+2) * DIM + (idx+3)] = ans[11];
    matrix3[(idy+3) * DIM + idx] = ans[12];
    matrix3[(idy+3) * DIM + (idx+1)] = ans[13];
    matrix3[(idy+3) * DIM + (idx+2)] = ans[14];
    matrix3[(idy+3) * DIM + (idx+3)] = ans[15];
}

/* extra kernel */
__kernel void _tdgemm(__global qd_real *alpha,
                       __global qd_real *beta,
                       __global qd_real *matrix1,
                       __global qd_real *matrix2,
                       __global qd_real *matrix3,
                       int DIM)
{
    int idx = get_global_id(0) % DIM;
    int idy = get_global_id(0) / DIM;

    int i, j;
    qd_real e1, e2, e3;
    qd_real alp, bet;
    qd_real tmp, ans;
    qd_real zero = (qd_real)(0.0, 0.0, 0.0, 0.0);

    alp = alpha[0];
    bet = beta[0];
    tmp = zero;
    ans = zero;
    
    e3 = matrix3[idy * DIM + idx];
    e3.w = 0.0;
    TD_MUL(&bet, &e3, &e3);

    for (i = 0; i < DIM; i++) {
  e1 = matrix1[idy * DIM + i];
  e1.w = 0.0;
  e2 = matrix2[i * DIM + idx];
  e2.w = 0.0;
	TD_MUL(&e1, &e2, &tmp);
	TD_ADD(&tmp, &ans, &ans);
    }

    TD_MUL(&alp, &ans, &ans);
    TD_ADD(&e3, &ans, &ans);

    ans.w = 0.0;
    matrix3[idy * DIM + idx] = ans;
}