#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <iostream>
#include <cstdlib>
#include <qd/dd_real.h> /* using qd-lib */
#include <qd/qd_real.h>
#include "td_real.cpp"
using namespace std;

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

//#define MSIZE 1024
//#define BLK 1*1
//#define CLFILE "tdgemm.cl"
//#define KERNEL "_tdgemm"
//#define GLOBAL ((MSIZE*MSIZE)/(BLK))
//#define LOCAL 64
#define DEV CL_DEVICE_TYPE_GPU
//#define PID 1
//#define DID 0

#define MAX_SOURCE_SIZE 0x100000
#define MAX_PLATFORM 2 // number of platform
#define MAX_DEVICE 2 // number of device
#define CHECK 1

void print(int N, qd_real *mat);
void compareAns(int NN, qd_real *ans, qd_real *C, qd_real *ret);
double get_time();
qd_real myqdrand(); // -1.0 ~ 1.0
void test_qd();
void loop_qdgemm();
void test_td();
void loop_tdgemm();

int MSIZE=128;
int BLK=1*1;
string CLFILE="tdgemm.cl";
char KERNEL[]="_tdgemm";
int GLOBAL=((MSIZE*MSIZE)/(BLK));
int LOCAL=64;
int PID=1;
int DID=0;

int main()
{
	// for random
  srand((unsigned int)time(NULL));
	
	// qd
	/*
	cout << "test" << endl;
	test_qd();
	cout << endl;
	
	for(int i=64; i<2000; i+=64){
	MSIZE=i;
	GLOBAL=((MSIZE*MSIZE)/(BLK));
	cout << i;
  loop_qdgemm();
	}
	*/
	
	// td
	
	cout << "test" << endl;
	test_td();
	cout << endl;
	
	for(int i=64; i<2000; i+=64){
	MSIZE=i;
	GLOBAL=((MSIZE*MSIZE)/(BLK));
	cout << i;
  loop_tdgemm();
	}
	
	
	return 0;
}

void print(int N, qd_real *mat)
{
  for(int i=0; i<N; i++){
    for(int j=0; j<N; j++)
    {
      cout << mat[i*N +j] << " ";
    }
  cout << endl;
  }
  cout << endl;
}

void print(int N, td_real *mat)
{
	for(int i=0; i<N; i++){
    for(int j=0; j<N; j++)
    {
      cout << mat[i*N +j] << " ";
    }
  cout << endl;
  }
  cout << endl;
}

void compareAns(int NN, qd_real *ans, qd_real *C, qd_real *ret)
{
  for(int i=0;i<NN;i++)
  for(int j=0;j<NN;j++)
   {
     ret[i*NN +j] = ans[i*NN+j] - C[i*NN +j];
   }
}

void compareAns(int NN, td_real *ans, td_real *C, td_real *ret)
{
	for(int i=0;i<NN;i++)
  for(int j=0;j<NN;j++)
   {
     ret[i*NN +j] = ans[i*NN+j] - C[i*NN +j];
   }
}

double get_time()
{
  static struct timeval now;
  gettimeofday(&now, NULL);
  return (double)(now.tv_sec + now.tv_usec/1000000.0);
}

qd_real myqdrand()
{
  if((int)(100*qdrand()[0]) %2 == 0)
    return qdrand();
  else
    return -qdrand();
}

void test_qd()
{
	cl_device_id device_id[MAX_DEVICE];
  cl_context context=NULL;
  cl_command_queue command_queue=NULL;
  cl_program program=NULL;
  cl_kernel kernel=NULL;
  cl_platform_id platform_id[MAX_PLATFORM];
  cl_uint ret_num_devices;
  cl_uint ret_num_platforms;
  cl_int ret;

  // for time
  cl_event eve1;
  cl_ulong start;
  cl_ulong end;
  double s1,e1, s2,e2;
  double test=0.0;
  
  cl_mem _dev_alpha;
  cl_mem _dev_beta;
  cl_mem _dev_matrix1;
  cl_mem _dev_matrix2;
  cl_mem _dev_matrix3;
  
  int pid=PID;
  int did=DID;
  
  char platform_version[50];
  char platform_name[50];
  size_t info_real_size;

  FILE *fp;

  string filename = CLFILE;
  
  char *source_str;
  size_t source_size;
  
  qd_real alpha;
  qd_real beta;
  qd_real *_host_matrix1 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix2 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix3 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix3_tmp = new qd_real[MSIZE * MSIZE];

  
  for(int i=0;i<MAX_DEVICE;i++) device_id[i]=NULL;
  for(int i=0;i<MAX_PLATFORM;i++) platform_id[i]=NULL;
  
  alpha = myqdrand();
  beta = myqdrand();
  //alpha = 2.0;
  //beta = 0.0;
  
  for(int i=0;i<MSIZE*MSIZE;i++)
   {
    //_host_matrix1[i] = 1.0;
    //_host_matrix2[i] = 1.0;
    //_host_matrix3[i] = 0.0;
    _host_matrix1[i] = myqdrand();
    _host_matrix2[i] = myqdrand();
    _host_matrix3[i] = myqdrand();
    _host_matrix3_tmp[i] = _host_matrix3[i];
   }
  
  fp=fopen(filename.c_str(),"r");
  if(!fp){
    fprintf(stderr,"Failed to load kernel.\n");
    exit(1);
  }
  source_str=(char*)malloc(MAX_SOURCE_SIZE);
  source_size=fread(source_str,1,MAX_SOURCE_SIZE,fp);
  fclose(fp);

  ret=clGetPlatformIDs(MAX_PLATFORM,platform_id,&ret_num_platforms);

  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_VERSION,50,(void *)platform_version,&info_real_size);
  cout << "Platform Version : ";
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_version[i];
  }
  cout << endl;
  cout << "Platform Name    : ";
  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_NAME,50,(void *)platform_name,&info_real_size);
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_name[i];
  }
  cout << endl;

  ret = clGetDeviceIDs(platform_id[pid],DEV,1,device_id,&ret_num_devices);

  context = clCreateContext(NULL,1,device_id,NULL,NULL,&ret);
  command_queue = clCreateCommandQueue(context,device_id[did],CL_QUEUE_PROFILING_ENABLE,&ret);
	
  _dev_alpha = clCreateBuffer(context,CL_MEM_READ_WRITE,4*sizeof(double),NULL,&ret);
  _dev_beta = clCreateBuffer(context,CL_MEM_READ_WRITE,4*sizeof(double),NULL,&ret);
  _dev_matrix1 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix2 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix3 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
//cout << "test" << endl;
  program = clCreateProgramWithSource(context,1,(const char **)&source_str,(const size_t *)&source_size,&ret);
  /*** kernel build + error check ***/
  ret = clBuildProgram(program,1,device_id,"-I ./",NULL,NULL);
  if(ret != CL_SUCCESS) {
    if(ret == CL_BUILD_PROGRAM_FAILURE) {
      fprintf(stderr, "Error: %s\n", filename.c_str());
      cl_int logStatus;
      char * buildLog = NULL;
      size_t buildLogSize = 0;

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     &buildLogSize);

      buildLog = (char*)malloc(buildLogSize);
      memset(buildLog, 0, buildLogSize);

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     NULL);

      fprintf(stderr, "%s\n", buildLog);

      free(buildLog);
    }
    exit(-1);
   }
  /***************************************/

  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix1,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix1,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix2,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix2,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix3,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_alpha,CL_TRUE,0,4*sizeof(double),alpha.x,0,NULL,NULL);
	ret = clEnqueueWriteBuffer(command_queue,_dev_beta,CL_TRUE,0,4*sizeof(double),beta.x,0,NULL,NULL);
  
  kernel = clCreateKernel(program,KERNEL,&ret);
  
  int dim=MSIZE;
  // kernel argument
  ret = clSetKernelArg(kernel,0,sizeof(cl_mem),(void *)&_dev_alpha);
  ret = clSetKernelArg(kernel,1,sizeof(cl_mem),(void *)&_dev_beta);
  ret = clSetKernelArg(kernel,2,sizeof(cl_mem),(void *)&_dev_matrix1);
  ret = clSetKernelArg(kernel,3,sizeof(cl_mem),(void *)&_dev_matrix2);
  ret = clSetKernelArg(kernel,4,sizeof(cl_mem),(void *)&_dev_matrix3);
  ret = clSetKernelArg(kernel,5,sizeof(int),(void *)&dim);
//cout << "test" << endl;
  size_t global_item_size = GLOBAL; // global thread
  size_t local_item_size = LOCAL;   // local thread

  ret = clEnqueueNDRangeKernel(command_queue,kernel,1,NULL,&global_item_size,&local_item_size,0,NULL,&eve1);
//cout << "test" << endl;
  clWaitForEvents(1,&eve1);  
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_START,sizeof(cl_ulong),&start,NULL);
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_END,sizeof(cl_ulong),&end,NULL);

  // read output buffer
  ret=clEnqueueReadBuffer(command_queue,_dev_matrix3,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,1,&eve1,NULL);

  double tim=(end - start)/1000000000.0;
  double n=MSIZE;
  double flop=2*n*n*n;
  double flops=flop/tim;
  
  cout.precision(16);
  
  if(CHECK == 1){
	qd_real *A = new qd_real[MSIZE * MSIZE];
  qd_real *B = new qd_real[MSIZE * MSIZE];
  qd_real *C = new qd_real[MSIZE * MSIZE];
  qd_real *Mret = new qd_real[MSIZE * MSIZE];

  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++)
    {
      A[i*MSIZE +j]=_host_matrix1[i*MSIZE+j];
      B[i*MSIZE +j]=_host_matrix2[i*MSIZE+j];
      C[i*MSIZE +j]=_host_matrix3_tmp[i*MSIZE+j];
    }

  qd_real abs,average=0.0,min=1.0e-13;

  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++){
     C[i*MSIZE +j] *= beta;
    for(int k=0;k<MSIZE;k++){
     C[i*MSIZE +j] += alpha * A[i*MSIZE +k] * B[k*MSIZE +j];
     }
    }

  // compare answer
  compareAns(MSIZE,_host_matrix3,C,Mret);
  
  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++){
    abs = fabs(Mret[i*MSIZE +j]);
    average += abs;
    if(min >= abs) min = abs;
  }
  
  average = average / (MSIZE*MSIZE);
  cout << endl;
  cout << "difference average = " << average << endl;
  cout << "minimum difference = " << min << endl;

  //print(MSIZE, _host_matrix3);
  //print(MSIZE, C);
  
	delete [] A;
	delete [] B;
	delete [] C;
	delete [] Mret;
}

  // free memory
  delete []_host_matrix1;
  delete []_host_matrix2;
  delete []_host_matrix3;
  delete []_host_matrix3_tmp;

  ret=clFlush(command_queue);
  ret=clFinish(command_queue);
  ret=clReleaseKernel(kernel);
  ret=clReleaseProgram(program);

  ret=clReleaseMemObject(_dev_alpha);
  ret=clReleaseMemObject(_dev_beta);
  ret=clReleaseMemObject(_dev_matrix1);
  ret=clReleaseMemObject(_dev_matrix2);
  ret=clReleaseMemObject(_dev_matrix3);
  
  ret=clReleaseEvent(eve1);
  ret=clReleaseCommandQueue(command_queue);
  ret=clReleaseContext(context);

  free(source_str);

  cout << "Gflop/s: " << flops/1000000000.0 << endl;
}

void loop_qdgemm()
{
	cl_device_id device_id[MAX_DEVICE];
  cl_context context=NULL;
  cl_command_queue command_queue=NULL;
  cl_program program=NULL;
  cl_kernel kernel=NULL;
  cl_platform_id platform_id[MAX_PLATFORM];
  cl_uint ret_num_devices;
  cl_uint ret_num_platforms;
  cl_int ret;

  // for time
  cl_event eve1;
  cl_ulong start;
  cl_ulong end;
  double s1,e1, s2,e2;
  double test=0.0;
  
  cl_mem _dev_alpha;
  cl_mem _dev_beta;
  cl_mem _dev_matrix1;
  cl_mem _dev_matrix2;
  cl_mem _dev_matrix3;
  
  int pid=PID;
  int did=DID;
  
  char platform_version[50];
  char platform_name[50];
  size_t info_real_size;

  FILE *fp;

  string filename = CLFILE;
  
  char *source_str;
  size_t source_size;
  
  qd_real alpha;
  qd_real beta;
  qd_real *_host_matrix1 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix2 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix3 = new qd_real[MSIZE * MSIZE];
  qd_real *_host_matrix3_tmp = new qd_real[MSIZE * MSIZE];

  
  for(int i=0;i<MAX_DEVICE;i++) device_id[i]=NULL;
  for(int i=0;i<MAX_PLATFORM;i++) platform_id[i]=NULL;

  // for random
  srand((unsigned int)time(NULL));
  
  alpha = myqdrand();
  beta = myqdrand();
  //alpha = 2.0;
  //beta = 0.0;
  
  for(int i=0;i<MSIZE*MSIZE;i++)
   {
    //_host_matrix1[i] = 1.0;
    //_host_matrix2[i] = 1.0;
    //_host_matrix3[i] = 0.0;
    _host_matrix1[i] = myqdrand();
    _host_matrix2[i] = myqdrand();
    _host_matrix3[i] = myqdrand();
    _host_matrix3_tmp[i] = _host_matrix3[i];
   }
  
  fp=fopen(filename.c_str(),"r");
  if(!fp){
    fprintf(stderr,"Failed to load kernel.\n");
    exit(1);
  }
  source_str=(char*)malloc(MAX_SOURCE_SIZE);
  source_size=fread(source_str,1,MAX_SOURCE_SIZE,fp);
  fclose(fp);

  ret=clGetPlatformIDs(MAX_PLATFORM,platform_id,&ret_num_platforms);
/*
  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_VERSION,50,(void *)platform_version,&info_real_size);
  cout << "Platform Version : ";
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_version[i];
  }
  cout << endl;
  cout << "Platform Name    : ";
  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_NAME,50,(void *)platform_name,&info_real_size);
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_name[i];
  }
  cout << endl;
*/
  ret = clGetDeviceIDs(platform_id[pid],DEV,1,device_id,&ret_num_devices);

  context = clCreateContext(NULL,1,device_id,NULL,NULL,&ret);
  command_queue = clCreateCommandQueue(context,device_id[did],CL_QUEUE_PROFILING_ENABLE,&ret);
	
  _dev_alpha = clCreateBuffer(context,CL_MEM_READ_WRITE,4*sizeof(double),NULL,&ret);
  _dev_beta = clCreateBuffer(context,CL_MEM_READ_WRITE,4*sizeof(double),NULL,&ret);
  _dev_matrix1 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix2 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix3 = clCreateBuffer(context,CL_MEM_READ_WRITE,4*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
//cout << "test" << endl;
  program = clCreateProgramWithSource(context,1,(const char **)&source_str,(const size_t *)&source_size,&ret);
  /*** kernel build + error check ***/
  ret = clBuildProgram(program,1,device_id,"-I ./",NULL,NULL);
  if(ret != CL_SUCCESS) {
    if(ret == CL_BUILD_PROGRAM_FAILURE) {
      fprintf(stderr, "Error: %s\n", filename.c_str());
      cl_int logStatus;
      char * buildLog = NULL;
      size_t buildLogSize = 0;

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     &buildLogSize);

      buildLog = (char*)malloc(buildLogSize);
      memset(buildLog, 0, buildLogSize);

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     NULL);

      fprintf(stderr, "%s\n", buildLog);

      free(buildLog);
    }
    exit(-1);
   }
  /***************************************/

  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix1,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix1,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix2,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix2,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix3,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_alpha,CL_TRUE,0,4*sizeof(double),alpha.x,0,NULL,NULL);
	ret = clEnqueueWriteBuffer(command_queue,_dev_beta,CL_TRUE,0,4*sizeof(double),beta.x,0,NULL,NULL);
  
  kernel = clCreateKernel(program,KERNEL,&ret);
  
  int dim=MSIZE;
  // kernel argument
  ret = clSetKernelArg(kernel,0,sizeof(cl_mem),(void *)&_dev_alpha);
  ret = clSetKernelArg(kernel,1,sizeof(cl_mem),(void *)&_dev_beta);
  ret = clSetKernelArg(kernel,2,sizeof(cl_mem),(void *)&_dev_matrix1);
  ret = clSetKernelArg(kernel,3,sizeof(cl_mem),(void *)&_dev_matrix2);
  ret = clSetKernelArg(kernel,4,sizeof(cl_mem),(void *)&_dev_matrix3);
  ret = clSetKernelArg(kernel,5,sizeof(int),(void *)&dim);
//cout << "test" << endl;
  size_t global_item_size = GLOBAL; // global thread
  size_t local_item_size = LOCAL;   // local thread

  ret = clEnqueueNDRangeKernel(command_queue,kernel,1,NULL,&global_item_size,&local_item_size,0,NULL,&eve1);
//cout << "test" << endl;
  clWaitForEvents(1,&eve1);  
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_START,sizeof(cl_ulong),&start,NULL);
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_END,sizeof(cl_ulong),&end,NULL);

  // read output buffer
  ret=clEnqueueReadBuffer(command_queue,_dev_matrix3,CL_TRUE,0,4*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,1,&eve1,NULL);

  double tim=(end - start)/1000000000.0;
  double n=MSIZE;
  double flop=2*n*n*n;
  double flops=flop/tim;
  
  cout.precision(16);
  

  // free memory
  delete []_host_matrix1;
  delete []_host_matrix2;
  delete []_host_matrix3;
  delete []_host_matrix3_tmp;

  ret=clFlush(command_queue);
  ret=clFinish(command_queue);
  ret=clReleaseKernel(kernel);
  ret=clReleaseProgram(program);

  ret=clReleaseMemObject(_dev_alpha);
  ret=clReleaseMemObject(_dev_beta);
  ret=clReleaseMemObject(_dev_matrix1);
  ret=clReleaseMemObject(_dev_matrix2);
  ret=clReleaseMemObject(_dev_matrix3);
  
  ret=clReleaseEvent(eve1);
  ret=clReleaseCommandQueue(command_queue);
  ret=clReleaseContext(context);

  free(source_str);

  cout << " " << flops/1000000000.0 << endl;
}

void test_td()
{
	cl_device_id device_id[MAX_DEVICE];
  cl_context context=NULL;
  cl_command_queue command_queue=NULL;
  cl_program program=NULL;
  cl_kernel kernel=NULL;
  cl_platform_id platform_id[MAX_PLATFORM];
  cl_uint ret_num_devices;
  cl_uint ret_num_platforms;
  cl_int ret;

  // for time
  cl_event eve1;
  cl_ulong start;
  cl_ulong end;
  double s1,e1, s2,e2;
  double test=0.0;
  
  cl_mem _dev_alpha;
  cl_mem _dev_beta;
  cl_mem _dev_matrix1;
  cl_mem _dev_matrix2;
  cl_mem _dev_matrix3;
  
  int pid=PID;
  int did=DID;
  
  char platform_version[50];
  char platform_name[50];
  size_t info_real_size;

  FILE *fp;

  string filename = CLFILE;
  
  char *source_str;
  size_t source_size;
  
  td_real alpha;
  td_real beta;
  td_real *_host_matrix1 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix2 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix3 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix3_tmp = new td_real[MSIZE * MSIZE];

  
  for(int i=0;i<MAX_DEVICE;i++) device_id[i]=NULL;
  for(int i=0;i<MAX_PLATFORM;i++) platform_id[i]=NULL;
  
  alpha = myqdrand();
  beta = myqdrand();
  //alpha = 2.0;
  //beta = 0.0;
  
  for(int i=0;i<MSIZE*MSIZE;i++)
   {
    //_host_matrix1[i] = 1.0;
    //_host_matrix2[i] = 1.0;
    //_host_matrix3[i] = 0.0;
    _host_matrix1[i] = myqdrand();
    _host_matrix2[i] = myqdrand();
    _host_matrix3[i] = myqdrand();
    _host_matrix3_tmp[i] = _host_matrix3[i];
   }
  
  fp=fopen(filename.c_str(),"r");
  if(!fp){
    fprintf(stderr,"Failed to load kernel.\n");
    exit(1);
  }
  source_str=(char*)malloc(MAX_SOURCE_SIZE);
  source_size=fread(source_str,1,MAX_SOURCE_SIZE,fp);
  fclose(fp);

  ret=clGetPlatformIDs(MAX_PLATFORM,platform_id,&ret_num_platforms);

  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_VERSION,50,(void *)platform_version,&info_real_size);
  cout << "Platform Version : ";
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_version[i];
  }
  cout << endl;
  cout << "Platform Name    : ";
  clGetPlatformInfo(platform_id[pid],CL_PLATFORM_NAME,50,(void *)platform_name,&info_real_size);
  for(unsigned int i=0;i<info_real_size;i++){
   cout << platform_name[i];
  }
  cout << endl;

  ret = clGetDeviceIDs(platform_id[pid],DEV,1,device_id,&ret_num_devices);

  context = clCreateContext(NULL,1,device_id,NULL,NULL,&ret);
  command_queue = clCreateCommandQueue(context,device_id[did],CL_QUEUE_PROFILING_ENABLE,&ret);
	
  _dev_alpha = clCreateBuffer(context,CL_MEM_READ_WRITE,3*sizeof(double),NULL,&ret);
  _dev_beta = clCreateBuffer(context,CL_MEM_READ_WRITE,3*sizeof(double),NULL,&ret);
  _dev_matrix1 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix2 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix3 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
//cout << "test" << endl;
  program = clCreateProgramWithSource(context,1,(const char **)&source_str,(const size_t *)&source_size,&ret);
  /*** kernel build + error check ***/
  ret = clBuildProgram(program,1,device_id,"-I ./",NULL,NULL);
  if(ret != CL_SUCCESS) {
    if(ret == CL_BUILD_PROGRAM_FAILURE) {
      fprintf(stderr, "Error: %s\n", filename.c_str());
      cl_int logStatus;
      char * buildLog = NULL;
      size_t buildLogSize = 0;

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     &buildLogSize);

      buildLog = (char*)malloc(buildLogSize);
      memset(buildLog, 0, buildLogSize);

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     NULL);

      fprintf(stderr, "%s\n", buildLog);

      free(buildLog);
    }
    exit(-1);
   }
  /***************************************/

  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix1,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix1[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix2,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix2[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix3,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix3[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_alpha,CL_TRUE,0,3*sizeof(double),alpha.x,0,NULL,NULL);
	ret = clEnqueueWriteBuffer(command_queue,_dev_beta,CL_TRUE,0,3*sizeof(double),beta.x,0,NULL,NULL);
  
  kernel = clCreateKernel(program,KERNEL,&ret);
  
  int dim=MSIZE;
  // kernel argument
  ret = clSetKernelArg(kernel,0,sizeof(cl_mem),(void *)&_dev_alpha);
  ret = clSetKernelArg(kernel,1,sizeof(cl_mem),(void *)&_dev_beta);
  ret = clSetKernelArg(kernel,2,sizeof(cl_mem),(void *)&_dev_matrix1);
  ret = clSetKernelArg(kernel,3,sizeof(cl_mem),(void *)&_dev_matrix2);
  ret = clSetKernelArg(kernel,4,sizeof(cl_mem),(void *)&_dev_matrix3);
  ret = clSetKernelArg(kernel,5,sizeof(int),(void *)&dim);
//cout << "test" << endl;
  size_t global_item_size = GLOBAL; // global thread
  size_t local_item_size = LOCAL;   // local thread

  ret = clEnqueueNDRangeKernel(command_queue,kernel,1,NULL,&global_item_size,&local_item_size,0,NULL,&eve1);
//cout << "test" << endl;
  clWaitForEvents(1,&eve1);  
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_START,sizeof(cl_ulong),&start,NULL);
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_END,sizeof(cl_ulong),&end,NULL);

  // read output buffer
  ret=clEnqueueReadBuffer(command_queue,_dev_matrix3,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,1,&eve1,NULL);

  double tim=(end - start)/1000000000.0;
  double n=MSIZE;
  double flop=2*n*n*n;
  double flops=flop/tim;
  
  cout.precision(16);
  
  if(CHECK == 1){
	td_real *A = new td_real[MSIZE * MSIZE];
  td_real *B = new td_real[MSIZE * MSIZE];
  td_real *C = new td_real[MSIZE * MSIZE];
  td_real *Mret = new td_real[MSIZE * MSIZE];

  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++)
    {
      A[i*MSIZE +j]=_host_matrix1[i*MSIZE+j];
      B[i*MSIZE +j]=_host_matrix2[i*MSIZE+j];
      C[i*MSIZE +j]=_host_matrix3_tmp[i*MSIZE+j];
    }

  qd_real abs,average=0.0,min=1.0e-13;

  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++){
     C[i*MSIZE +j] = beta * C[i*MSIZE +j];
    for(int k=0;k<MSIZE;k++){
     C[i*MSIZE +j] = alpha * A[i*MSIZE +k] * B[k*MSIZE +j] + C[i*MSIZE +j];
     }
    }

  // compare answer
  compareAns(MSIZE,_host_matrix3,C,Mret);
  
  for(int i=0;i<MSIZE;i++)
   for(int j=0;j<MSIZE;j++){
    abs = fabs(Mret[i*MSIZE +j].toQDreal());
    average += abs;
    if(min >= abs) min = abs;
  }
  
  average = average / (MSIZE*MSIZE);
  cout << endl;
  cout << "difference average = " << average << endl;
  cout << "minimum difference = " << min << endl;

  //print(MSIZE, _host_matrix3);
  //print(MSIZE, C);
  
	delete [] A;
	delete [] B;
	delete [] C;
	delete [] Mret;
}

  // free memory
  delete []_host_matrix1;
  delete []_host_matrix2;
  delete []_host_matrix3;
  delete []_host_matrix3_tmp;

  ret=clFlush(command_queue);
  ret=clFinish(command_queue);
  ret=clReleaseKernel(kernel);
  ret=clReleaseProgram(program);

  ret=clReleaseMemObject(_dev_alpha);
  ret=clReleaseMemObject(_dev_beta);
  ret=clReleaseMemObject(_dev_matrix1);
  ret=clReleaseMemObject(_dev_matrix2);
  ret=clReleaseMemObject(_dev_matrix3);
  
  ret=clReleaseEvent(eve1);
  ret=clReleaseCommandQueue(command_queue);
  ret=clReleaseContext(context);

  free(source_str);

  cout << "Gflop/s: " << flops/1000000000.0 << endl;
	
}
void loop_tdgemm()
{
	cl_device_id device_id[MAX_DEVICE];
  cl_context context=NULL;
  cl_command_queue command_queue=NULL;
  cl_program program=NULL;
  cl_kernel kernel=NULL;
  cl_platform_id platform_id[MAX_PLATFORM];
  cl_uint ret_num_devices;
  cl_uint ret_num_platforms;
  cl_int ret;

  // for time
  cl_event eve1;
  cl_ulong start;
  cl_ulong end;
  double s1,e1, s2,e2;
  double test=0.0;
  
  cl_mem _dev_alpha;
  cl_mem _dev_beta;
  cl_mem _dev_matrix1;
  cl_mem _dev_matrix2;
  cl_mem _dev_matrix3;
  
  int pid=PID;
  int did=DID;
  
  char platform_version[50];
  char platform_name[50];
  size_t info_real_size;

  FILE *fp;

  string filename = CLFILE;
  
  char *source_str;
  size_t source_size;
  
  td_real alpha;
  td_real beta;
  td_real *_host_matrix1 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix2 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix3 = new td_real[MSIZE * MSIZE];
  td_real *_host_matrix3_tmp = new td_real[MSIZE * MSIZE];

  
  for(int i=0;i<MAX_DEVICE;i++) device_id[i]=NULL;
  for(int i=0;i<MAX_PLATFORM;i++) platform_id[i]=NULL;
  
  alpha = myqdrand();
  beta = myqdrand();
  //alpha = 2.0;
  //beta = 0.0;
  
  for(int i=0;i<MSIZE*MSIZE;i++)
   {
    //_host_matrix1[i] = 1.0;
    //_host_matrix2[i] = 1.0;
    //_host_matrix3[i] = 0.0;
    _host_matrix1[i] = myqdrand();
    _host_matrix2[i] = myqdrand();
    _host_matrix3[i] = myqdrand();
    _host_matrix3_tmp[i] = _host_matrix3[i];
   }
  
  fp=fopen(filename.c_str(),"r");
  if(!fp){
    fprintf(stderr,"Failed to load kernel.\n");
    exit(1);
  }
  source_str=(char*)malloc(MAX_SOURCE_SIZE);
  source_size=fread(source_str,1,MAX_SOURCE_SIZE,fp);
  fclose(fp);

  ret=clGetPlatformIDs(MAX_PLATFORM,platform_id,&ret_num_platforms);

  ret = clGetDeviceIDs(platform_id[pid],DEV,1,device_id,&ret_num_devices);

  context = clCreateContext(NULL,1,device_id,NULL,NULL,&ret);
  command_queue = clCreateCommandQueue(context,device_id[did],CL_QUEUE_PROFILING_ENABLE,&ret);
	
  _dev_alpha = clCreateBuffer(context,CL_MEM_READ_WRITE,3*sizeof(double),NULL,&ret);
  _dev_beta = clCreateBuffer(context,CL_MEM_READ_WRITE,3*sizeof(double),NULL,&ret);
  _dev_matrix1 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix2 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
  _dev_matrix3 = clCreateBuffer(context,CL_MEM_READ_WRITE,3*(MSIZE * MSIZE)*sizeof(double),NULL,&ret);
//cout << "test" << endl;
  program = clCreateProgramWithSource(context,1,(const char **)&source_str,(const size_t *)&source_size,&ret);
  /*** kernel build + error check ***/
  ret = clBuildProgram(program,1,device_id,"-I ./",NULL,NULL);
  if(ret != CL_SUCCESS) {
    if(ret == CL_BUILD_PROGRAM_FAILURE) {
      fprintf(stderr, "Error: %s\n", filename.c_str());
      cl_int logStatus;
      char * buildLog = NULL;
      size_t buildLogSize = 0;

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     &buildLogSize);

      buildLog = (char*)malloc(buildLogSize);
      memset(buildLog, 0, buildLogSize);

      logStatus = clGetProgramBuildInfo (program, 
                                     device_id[did],
                                     CL_PROGRAM_BUILD_LOG,
                                     buildLogSize,
                                     buildLog,
                                     NULL);

      fprintf(stderr, "%s\n", buildLog);

      free(buildLog);
    }
    exit(-1);
   }
  /***************************************/

  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix1,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix1[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix2,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix2[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_matrix3,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix3[0].x,0,NULL,NULL);
  ret = clEnqueueWriteBuffer(command_queue,_dev_alpha,CL_TRUE,0,3*sizeof(double),alpha.x,0,NULL,NULL);
	ret = clEnqueueWriteBuffer(command_queue,_dev_beta,CL_TRUE,0,3*sizeof(double),beta.x,0,NULL,NULL);
  
  kernel = clCreateKernel(program,KERNEL,&ret);
  
  int dim=MSIZE;
  // kernel argument
  ret = clSetKernelArg(kernel,0,sizeof(cl_mem),(void *)&_dev_alpha);
  ret = clSetKernelArg(kernel,1,sizeof(cl_mem),(void *)&_dev_beta);
  ret = clSetKernelArg(kernel,2,sizeof(cl_mem),(void *)&_dev_matrix1);
  ret = clSetKernelArg(kernel,3,sizeof(cl_mem),(void *)&_dev_matrix2);
  ret = clSetKernelArg(kernel,4,sizeof(cl_mem),(void *)&_dev_matrix3);
  ret = clSetKernelArg(kernel,5,sizeof(int),(void *)&dim);
//cout << "test" << endl;
  size_t global_item_size = GLOBAL; // global thread
  size_t local_item_size = LOCAL;   // local thread

  ret = clEnqueueNDRangeKernel(command_queue,kernel,1,NULL,&global_item_size,&local_item_size,0,NULL,&eve1);
//cout << "test" << endl;
  clWaitForEvents(1,&eve1);  
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_START,sizeof(cl_ulong),&start,NULL);
  clGetEventProfilingInfo(eve1,CL_PROFILING_COMMAND_END,sizeof(cl_ulong),&end,NULL);

  // read output buffer
  ret=clEnqueueReadBuffer(command_queue,_dev_matrix3,CL_TRUE,0,3*(MSIZE*MSIZE)*sizeof(double),_host_matrix3,1,&eve1,NULL);

  double tim=(end - start)/1000000000.0;
  double n=MSIZE;
  double flop=2*n*n*n;
  double flops=flop/tim;
  
  cout.precision(16);

  // free memory
  delete []_host_matrix1;
  delete []_host_matrix2;
  delete []_host_matrix3;
  delete []_host_matrix3_tmp;

  ret=clFlush(command_queue);
  ret=clFinish(command_queue);
  ret=clReleaseKernel(kernel);
  ret=clReleaseProgram(program);

  ret=clReleaseMemObject(_dev_alpha);
  ret=clReleaseMemObject(_dev_beta);
  ret=clReleaseMemObject(_dev_matrix1);
  ret=clReleaseMemObject(_dev_matrix2);
  ret=clReleaseMemObject(_dev_matrix3);
  
  ret=clReleaseEvent(eve1);
  ret=clReleaseCommandQueue(command_queue);
  ret=clReleaseContext(context);

  free(source_str);
	
	cout << " " << flops/1000000000.0 << endl;
}