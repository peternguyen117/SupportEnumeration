CUDAPATH = /home/apps/fas/GPU/cuda_6.5.14
MAGMAPATH = /home/apps/fas/GPU/MAGMA/magma-1.6.1/

CC = icc
NVCC = $(CUDAPATH)/bin/nvcc
CFLAGS = -mkl -g -O0 -xHost -fno-alias -Wall -Werror -pedantic -std=c99 -openmp #-profile-functions 

# CFLAGS = -L${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread \
# -g -O1 -xHost -fno-alias -std=c99 -openmp #-profile-functions 
# CFLAGS = -fopenmp -m64 -I${MKLROOT}/include #-Wl --no-as-needed -L${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread \
-g -O3 -std=c99  #-profile-functions

# LINKLINE =  -Wl --no-as-needed -L${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -lm    

MCFLAGS = -fPIC -openmp -L$(MAGMAPATH)/lib -lmagma -lcublas -lcudart -I$(MAGMAPATH)/include

# NVCC Compiler-specific flags (phitest supports only 2.x capability)
# override NVCCFLAGS += -I$(CUDAPATH)/include -O3
NVCCFLAGS = -I$(CUDAPATH)/include -O3

LFLAGS = -L$(CUDAPATH)/lib64 -lcuda -lcudart -lm
GENCODE_SM20 = -gencode=arch=compute_20,code=\"sm_20,compute_20\"
GENCODE = $(GENCODE_SM20)

SerialsupEnum: SerialsupEnumNew.o readData.o subsets.o\
/home/fas/hpcprog/ahs3/cpsc424/utils/timing/timing.o
	$(CC) -o $@ $(CFLAGS) $^ -lm

OMPsupEnum: OMPsupEnumNoRecur.o readData.o subsets.o\
/home/fas/hpcprog/ahs3/cpsc424/utils/timing/timing.o
	$(CC) -o $@ $(CFLAGS) $^

MagmasupEnum: MagmasupEnum.o
	$(CC) -o $@ $(MCFLAGS) $^

GPUpairs: GPUpairs.o
	$(NVCC) $(GENCODE) $(LFLAGS) -o $@ $<

MagmasupEnum.o : MagmasupEnum.c
	$(CC) -o $@ $(MCFLAGS) -c $<

%.o : %.cu
	$(NVCC) $(GENCODE) $(NVCCFLAGS) -o $@ -c $<

%.o : %.c
	$(CC) $(CFLAGS) -c $< -lm

clean:
	rm -f *.o serial GPUpairs SerialsupEnum OMPsupEnum

