#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>
#include <sys/time.h>
#include <math.h>
#include "support.cpp"
using namespace std;

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#define CLFILE "integral.cl"
#define KERNEL "feynman_d"

#define MAX_SOURCE_SIZE 0x100000
#define MAX_PLATFORM 2		// number of platform
#define MAX_DEVICE 2		// number of device

void feynman_ocl(int N, int GLOBAL, int LOCAL, int PID, int DID, double H, double RAMDA);

void feynman_ocl(int N, int GLOBAL, int LOCAL, int PID, int DID, double H, double RAMDA)
{
    int n = N;
    double h = H;
    int i1, i2;
    double *gw30 = new double[n];
    double *x30 = new double[n];
    double *w1 = new double[n];
    double *w2 = new double[n];
    double *w3 = new double[n];
    double y, pi, t;
    double knl_s, knl_e;
    double ocl_time = 0.0;

    double x, s, tt, fme, fmf, ramda;
    double ax, ay, az, bx, cnt0, cnt1, xx, by, cnt2, cnt3, yy, bz, cnt4, cnt5, zz, d, sum, result;

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

    int info = 0;
    int pid = PID;
    int did = DID;

    char platform_version[50];
    char platform_name[50];
    size_t info_real_size;

    FILE *fp;

    string filename = CLFILE;

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


    _w3 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double), NULL, &ret);
    _gw30 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double), NULL, &ret);
    _x30 = clCreateBuffer(context, CL_MEM_READ_WRITE, n * sizeof(double), NULL, &ret);


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
    pi = (4.0 * atan(1.0));

    for (int i = 1; i <= n; i++) {
	x = -(n / 2) - 1 + (i);
	t = x * h;
	y = (pi * 0.5 * sinh(t));
	x30[i - 1] = tanh(y);
	gw30[i - 1] = (0.5 * cosh(t) * pi * (1.0 - tanh(y) * tanh(y)));
    }


    ret = clEnqueueWriteBuffer(command_queue, _gw30, CL_TRUE, 0, n * sizeof(double), gw30, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, _x30, CL_TRUE, 0, n * sizeof(double), x30, 0, NULL, NULL);


    kernel = clCreateKernel(program, KERNEL, &ret);


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

	    // kernel argument
	    ret = clSetKernelArg(kernel, 0, sizeof(int), (void *) &n);
	    ret = clSetKernelArg(kernel, 1, sizeof(int), (void *) &i1);
	    ret = clSetKernelArg(kernel, 2, sizeof(int), (void *) &i2);
	    ret = clSetKernelArg(kernel, 3, sizeof(double), (void *) &s);
	    ret = clSetKernelArg(kernel, 4, sizeof(double), (void *) &tt);
	    ret = clSetKernelArg(kernel, 5, sizeof(double), (void *) &ramda);
	    ret = clSetKernelArg(kernel, 6, sizeof(double), (void *) &fme);
	    ret = clSetKernelArg(kernel, 7, sizeof(double), (void *) &fmf);
	    ret = clSetKernelArg(kernel, 8, sizeof(double), (void *) &cnt0);
	    ret = clSetKernelArg(kernel, 9, sizeof(double), (void *) &cnt2);
	    ret = clSetKernelArg(kernel, 10, sizeof(double), (void *) &cnt4);
	    ret = clSetKernelArg(kernel, 11, sizeof(double), (void *) &cnt5);
	    ret = clSetKernelArg(kernel, 12, sizeof(double), (void *) &xx);
	    ret = clSetKernelArg(kernel, 13, sizeof(double), (void *) &yy);
	    ret = clSetKernelArg(kernel, 14, sizeof(cl_mem), (void *) &_w3);
	    ret = clSetKernelArg(kernel, 15, sizeof(cl_mem), (void *) &_gw30);
	    ret = clSetKernelArg(kernel, 16, sizeof(cl_mem), (void *) &_x30);

	    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, &eve1);

	    clWaitForEvents(1, &eve1);
	    clGetEventProfilingInfo(eve1, CL_PROFILING_COMMAND_START, sizeof(cl_ulong), &start, NULL);
	    clGetEventProfilingInfo(eve1, CL_PROFILING_COMMAND_END, sizeof(cl_ulong), &end, NULL);

	    // read output buffer
	    ret = clEnqueueReadBuffer(command_queue, _w3, CL_TRUE, 0, n * sizeof(double), w3, 1, &eve1, NULL);
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
    std::cout << "double precision:        " << result << std::endl;
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

    ret = clReleaseMemObject(_w3);
    ret = clReleaseMemObject(_gw30);
    ret = clReleaseMemObject(_x30);

    ret = clReleaseEvent(eve1);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);

    free(source_str);
}
