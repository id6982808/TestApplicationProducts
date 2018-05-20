#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>
#include <sys/time.h>
#include <math.h>
#include <qd/qd_real.h>
#include "support.cpp"
using namespace std;

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#define CLFILE_QD "integral_qd.cl"
#define KERNEL_QD "feynman_qd_d4"

#define MAX_SOURCE_SIZE 0x100000
#define MAX_PLATFORM 2		// number of platform
#define MAX_DEVICE 2		// number of device

void feynman_ocl_qd(int N, int GLOBAL, int LOCAL, int PID, int DID, double H, double RAMDA);

void feynman_ocl_qd(int N, int GLOBAL, int LOCAL, int PID, int DID, double H, double RAMDA)
{
    int n = N;
    qd_real h = H;
    int i1, i2;
    qd_real *gw30 = new qd_real[n];
    qd_real *x30 = new qd_real[n];
    qd_real *w1 = new qd_real[n];
    qd_real *w2 = new qd_real[n];
    qd_real *w3 = new qd_real[n];
    qd_real y, pi, t;
    double knl_s, knl_e;
    double ocl_time = 0.0;

    qd_real x, s, tt, fme, fmf, ramda;
    qd_real ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;

    /* parameter set */
    s = -500.0 * 500.0;
    tt = -150.0 * 150.0;
    fme = 0.5e-3;
    fmf = 150.0;
    ramda = RAMDA;

    // opencl components
    cl_device_id device_id[MAX_DEVICE];
    cl_context context = NULL;
    cl_command_queue command_queue = NULL;
    cl_program program = NULL;
    cl_kernel kernel = NULL;
    cl_platform_id platform_id[MAX_PLATFORM];
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret;

    // opencl time
    cl_event eve1;
    cl_ulong start;
    cl_ulong end;

    cl_mem _w3, _gw30, _x30;
    cl_mem _s, _tt, _ramda, _fme, _fmf, _cnt0, _cnt2, _cnt4, _cnt5, _xx, _yy;

    int info = 0;
    int pid = PID;
    int did = DID;

    char platform_version[50];
    char platform_name[50];
    size_t info_real_size;

    FILE *fp;

    string filename = CLFILE_QD;

    char *source_str;
    size_t source_size;

    for (int i = 0; i < MAX_DEVICE; i++)
	device_id[i] = NULL;
    for (int i = 0; i < MAX_PLATFORM; i++)
	platform_id[i] = NULL;

    fp = fopen(filename.c_str(), "r");
    if (!fp) {
	fprintf(stderr, "Failed to load kernel.\n");
	exit(1);
    }
    source_str = (char *) malloc(MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    ret = clGetPlatformIDs(MAX_PLATFORM, platform_id, &ret_num_platforms);
    if (info == 1) {
	clGetPlatformInfo(platform_id[pid], CL_PLATFORM_VERSION, 50, (void *) platform_version, &info_real_size);
	cout << "Platform Version : ";
	for (unsigned int i = 0; i < info_real_size; i++) {
	    cout << platform_version[i];
	}
	cout << endl;
	cout << "Platform Name    : ";
	clGetPlatformInfo(platform_id[pid], CL_PLATFORM_NAME, 50, (void *) platform_name, &info_real_size);
	for (unsigned int i = 0; i < info_real_size; i++) {
	    cout << platform_name[i];
	}
	cout << endl;
    }
    ret = clGetDeviceIDs(platform_id[pid], DEV, 1, device_id, &ret_num_devices);

    context = clCreateContext(NULL, 1, device_id, NULL, NULL, &ret);
    command_queue = clCreateCommandQueue(context, device_id[did], CL_QUEUE_PROFILING_ENABLE, &ret);

    _cnt0 = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _cnt2 = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _cnt4 = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _cnt5 = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _xx = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _yy = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);

    _s = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _tt = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _ramda = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _fme = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);
    _fmf = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(double) * 4, NULL, &ret);

    _w3 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double) * 4, NULL, &ret);
    _gw30 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double) * 4, NULL, &ret);
    _x30 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double) * 4, NULL, &ret);


    program = clCreateProgramWithSource(context, 1, (const char **) &source_str, (const size_t *) &source_size, &ret);
  /*** kernel build + error check ***/
    ret = clBuildProgram(program, 1, device_id, "-I ./", NULL, NULL);
    if (ret != CL_SUCCESS) {
	if (ret == CL_BUILD_PROGRAM_FAILURE) {
	    fprintf(stderr, "Error: %s\n", filename.c_str());
	    cl_int logStatus;
	    char *buildLog = NULL;
	    size_t buildLogSize = 0;

	    logStatus = clGetProgramBuildInfo(program, device_id[did], CL_PROGRAM_BUILD_LOG, buildLogSize, buildLog, &buildLogSize);

	    buildLog = (char *) malloc(buildLogSize);
	    memset(buildLog, 0, buildLogSize);

	    logStatus = clGetProgramBuildInfo(program, device_id[did], CL_PROGRAM_BUILD_LOG, buildLogSize, buildLog, NULL);

	    fprintf(stderr, "%s\n", buildLog);

	    free(buildLog);
	}
	exit(-1);
    }
  /***************************************/


    /* prepare integration */
    // double exponential integral
    pi = (qd_real(4.0) * atan(qd_real(1.0)));

    for (int i = 1; i <= n; i++) {
	x = -(n / 2) - 1 + (i);
	t = x * h;
	y = (pi * qd_real(0.5) * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (qd_real(0.5) * cosh(t) * pi * (qd_real(1.0) - tanh(y) * tanh(y)));
    }

    ret = clEnqueueWriteBuffer(command_queue, _s, CL_TRUE, 0, sizeof(double) * 4, &s, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _tt, CL_TRUE, 0, sizeof(double) * 4, &tt, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _ramda, CL_TRUE, 0, sizeof(double) * 4, &ramda, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _fme, CL_TRUE, 0, sizeof(double) * 4, &fme, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _fmf, CL_TRUE, 0, sizeof(double) * 4, &fmf, 0, NULL, NULL);

    ret = clEnqueueWriteBuffer(command_queue, _gw30, CL_TRUE, 0, n * sizeof(double) * 4, gw30, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _x30, CL_TRUE, 0, n * sizeof(double) * 4, x30, 0, NULL, NULL);


    kernel = clCreateKernel(program, KERNEL_QD, &ret);


    size_t global_item_size = GLOBAL;	// global thread
    size_t local_item_size = LOCAL;	// local thread

    knl_s = get_time();
    ax = 0.0;
    ay = 0.0;
    az = 0.0;
    bx = 1.0;
    cnt0 = (bx - ax) * 0.5;
    cnt1 = (bx + ax) * 0.5;

    for (i1 = 0; i1 < n; i1++) {
	xx = x30[i1] * cnt0 + cnt1;
	by = 1.0 - xx;
	cnt2 = (by - ay) * 0.5;
	cnt3 = (by + ay) * 0.5;

	for (i2 = 0; i2 < n; i2++) {
	    yy = x30[i2] * cnt2 + cnt3;
	    bz = 1.0 - xx - yy;
	    cnt4 = (bz - az) * 0.5;
	    cnt5 = (bz + az) * 0.5;
	    /*
	       for (int i3 = 0; i3 < n; i3++) {
	       zz = x30[i3] * cnt4 + cnt5;
	       d = -xx * yy * s - tt * zz * (1.0 - xx - yy - zz) + (xx + yy) * ramda * ramda + (1.0 - xx - yy - zz) * (1.0 - xx - yy) * fme * fme + zz * (1.0 - xx - yy) * fmf * fmf;
	       w3[i3] = (cnt0 * cnt2 * cnt4 * gw30[i1] * gw30[i2] * gw30[i3]) / (d * d);
	       }
	     */


	    ret = clEnqueueWriteBuffer(command_queue, _cnt0, CL_TRUE, 0, sizeof(double) * 4, &cnt0, 0, NULL, NULL);
	    ret = clEnqueueWriteBuffer(command_queue, _cnt2, CL_TRUE, 0, sizeof(double) * 4, &cnt2, 0, NULL, NULL);
	    ret = clEnqueueWriteBuffer(command_queue, _cnt4, CL_TRUE, 0, sizeof(double) * 4, &cnt4, 0, NULL, NULL);
	    ret = clEnqueueWriteBuffer(command_queue, _cnt5, CL_TRUE, 0, sizeof(double) * 4, &cnt5, 0, NULL, NULL);
	    ret = clEnqueueWriteBuffer(command_queue, _xx, CL_TRUE, 0, sizeof(double) * 4, &xx, 0, NULL, NULL);
	    ret = clEnqueueWriteBuffer(command_queue, _yy, CL_TRUE, 0, sizeof(double) * 4, &yy, 0, NULL, NULL);


	    // kernel argument
	    ret = clSetKernelArg(kernel, 0, sizeof(int), (void *) &n);
	    ret = clSetKernelArg(kernel, 1, sizeof(int), (void *) &i1);
	    ret = clSetKernelArg(kernel, 2, sizeof(int), (void *) &i2);
	    ret = clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *) &_s);
	    ret = clSetKernelArg(kernel, 4, sizeof(cl_mem), (void *) &_tt);
	    ret = clSetKernelArg(kernel, 5, sizeof(cl_mem), (void *) &_ramda);
	    ret = clSetKernelArg(kernel, 6, sizeof(cl_mem), (void *) &_fme);
	    ret = clSetKernelArg(kernel, 7, sizeof(cl_mem), (void *) &_fmf);
	    ret = clSetKernelArg(kernel, 8, sizeof(cl_mem), (void *) &_cnt0);
	    ret = clSetKernelArg(kernel, 9, sizeof(cl_mem), (void *) &_cnt2);
	    ret = clSetKernelArg(kernel, 10, sizeof(cl_mem), (void *) &_cnt4);
	    ret = clSetKernelArg(kernel, 11, sizeof(cl_mem), (void *) &_cnt5);
	    ret = clSetKernelArg(kernel, 12, sizeof(cl_mem), (void *) &_xx);
	    ret = clSetKernelArg(kernel, 13, sizeof(cl_mem), (void *) &_yy);
	    ret = clSetKernelArg(kernel, 14, sizeof(cl_mem), (void *) &_w3);
	    ret = clSetKernelArg(kernel, 15, sizeof(cl_mem), (void *) &_gw30);
	    ret = clSetKernelArg(kernel, 16, sizeof(cl_mem), (void *) &_x30);

	    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, &eve1);

	    clWaitForEvents(1, &eve1);
	    clGetEventProfilingInfo(eve1, CL_PROFILING_COMMAND_START, sizeof(cl_ulong), &start, NULL);
	    clGetEventProfilingInfo(eve1, CL_PROFILING_COMMAND_END, sizeof(cl_ulong), &end, NULL);

	    // read output buffer
	    ret = clEnqueueReadBuffer(command_queue, _w3, CL_TRUE, 0, n * sizeof(double) * 4, w3, 1, &eve1, NULL);
	    ocl_time += (end - start) / 1000000000.0;

	    sum = 0.0;
	    for (int i = 0; i < n; i++)
		sum = sum + w3[i];
	    w2[i2] = sum * h;
	}

	sum = 0.0;
	for (int i = 0; i < n; i++)
	    sum = sum + w2[i];
	w1[i1] = sum * h;
    }

    sum = 0.0;
    for (int i = 0; i < n; i++)
	sum = sum + w1[i];

    result = sum * h;
    knl_e = get_time();


    std::cout.precision(35);
    std::cout << "quad-double precision:   " << result << std::endl;
    std::cout << "error to analytical:     " << analytical(1) - result << std::endl;
    std::cout.precision(3);
    std::cout << "full loop time: " << knl_e - knl_s << " sec." << std::endl;
    std::cout << "opencl time:    " << ocl_time << " sec." << std::endl << std::endl;

    delete[]w1;
    delete[]w2;
    delete[]w3;
    delete[]gw30;
    delete[]x30;

    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);

    ret = clReleaseMemObject(_s);
    ret = clReleaseMemObject(_tt);
    ret = clReleaseMemObject(_ramda);
    ret = clReleaseMemObject(_fme);
    ret = clReleaseMemObject(_fmf);
    ret = clReleaseMemObject(_cnt0);
    ret = clReleaseMemObject(_cnt2);
    ret = clReleaseMemObject(_cnt4);
    ret = clReleaseMemObject(_cnt5);
    ret = clReleaseMemObject(_xx);
    ret = clReleaseMemObject(_yy);
    ret = clReleaseMemObject(_w3);
    ret = clReleaseMemObject(_gw30);
    ret = clReleaseMemObject(_x30);

    ret = clReleaseEvent(eve1);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);

    free(source_str);
}
