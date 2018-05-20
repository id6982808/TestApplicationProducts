#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "feynman_ocl.cpp"
#include "feynman_dd_ocl.cpp"
#include "feynman_td_ocl.cpp"
#include "feynman_qd_ocl.cpp"
#include "feynman_ocl_full.cpp"
#include "feynman_dd_ocl_full.cpp"
#include "feynman_td_ocl_full.cpp"
#include "feynman_qd_ocl_full.cpp"

extern double ext_ramda;	// reference by other files

// example:  ./main 1024 256 1.0e-30 10.0
int main(int argc, char *argv[])
{
    int N;
    int ocl_local_thread;
    int pid = PLAT_ID;
    int did = DEV_ID;
    double ramda;
    double nh;
    double h;

    if (argc == 0) {
	N = 256;
	ocl_local_thread = 256;
	ramda = 1.0e-30;
	nh = 10.0;
    } else if (argc != 5) {
	std::cout << "error on arguments." << std::endl;
	exit(1);
    } else {
	N = atoi(argv[1]);
	ocl_local_thread = atoi(argv[2]);
	ramda = atof(argv[3]);
	nh = atof(argv[4]);
    }

    h = nh / (double) N;
    ext_ramda = ramda;

    std::cout << "N = " << N << std::endl;
    std::cout << "ramda = " << ramda << std::endl;
    std::cout << "N * h = " << nh << std::endl;

    /* Feynman Integral (kernel includes single loop) */
    //feynman_ocl(N, N, ocl_local_thread, pid, did, h, ramda);
    //feynman_ocl_dd(N, N, ocl_local_thread, pid, did, h, ramda);
    //feynman_ocl_td(N, N, ocl_local_thread, pid, did, h, ramda);
    //feynman_ocl_qd(N, N, ocl_local_thread, pid, did, h, ramda);

    /* Feynman Integral (kernel includes triple loops) */
    feynman_ocl_full(N, N, ocl_local_thread, pid, did, h, ramda);
    feynman_ocl_dd_full(N, N, ocl_local_thread, pid, did, h, ramda);
    feynman_ocl_td_full(N, N, ocl_local_thread, pid, did, h, ramda);
    feynman_ocl_qd_full(N, N, ocl_local_thread, pid, did, h, ramda);

    return 0;
}
