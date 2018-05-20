#!/bin/bash

rm -f main.amd main.nvidia main.intel
g++ -W -O2 -D"PLAT_ID=1" -D"DEV_ID=0" -D"DEV=CL_DEVICE_TYPE_GPU" -I/home/nakamura/opt/NVIDIA_GPU_Computing_SDK/OpenCL/common/inc -L/home/nakamura/opt/NVIDIA_GPU_Computing_SDK/OpenCL/common/lib/Linux32 -o main.nvidia main.cpp -lOpenCL -I/home/nakamura/myresources/include/mpack -L/home/nakamura/myresources/lib -lmblas_dd -lmlapack_dd -fopenmp -lqd
g++ -W -O2 -D"PLAT_ID=0" -D"DEV_ID=0" -D"DEV=CL_DEVICE_TYPE_CPU" -I/home/nakamura/opt/Intel_OpenCL/usr/include -L/home/nakamura/opt/Intel_OpenCL/usr/lib64 -Wl,-rpath,/home/nakamura/opt/Intel_OpenCL/usr/lib64  -o main.intel main.cpp -lOpenCL -I/home/nakamura/myresources/include/mpack -L/home/nakamura/myresources/lib -lmblas_dd -lmlapack_dd -fopenmp -lqd
g++ -W -O2 -D"PLAT_ID=1" -D"DEV_ID=0" -D"DEV=CL_DEVICE_TYPE_GPU" -I/home/nakamura/opt/AMDAPP/include -L/home/nakamura/opt/AMDAPP/lib/x86 -Wl,-rpath,/home/nakamura/opt/AMDAPP/lib/x86  -o main.amd main.cpp -lOpenCL -I/home/nakamura/myresources/include/mpack -L/home/nakamura/myresources/lib -lmblas_dd -lmlapack_dd -fopenmp -lqd

