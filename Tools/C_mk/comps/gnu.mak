#
# Generic setup for using gcc
#
CXX = g++
CC  = gcc
FC  = gfortran
F90 = gfortran

CXXFLAGS =
CFLAGS   =
FFLAGS   =
F90FLAGS =

########################################################################

gcc_version       := $(shell $(CXX) -dumpversion | head -1 | sed -e 's;.*  *;;')
gcc_major_version := $(shell $(CXX) -dumpversion | head -1 | sed -e 's;.*  *;;' | sed -e 's;\..*;;')
gcc_minor_version := $(shell $(CXX) -dumpversion | head -1 | sed -e 's;.*  *;;' | sed -e 's;[^.]*\.;;' | sed -e 's;\..*;;')

DEFINES += -DBL_GCC_VERSION='$(gcc_version)'
DEFINES += -DBL_GCC_MAJOR_VERSION=$(gcc_major_version)
DEFINES += -DBL_GCC_MINOR_VERSION=$(gcc_minor_version)

########################################################################

ifeq ($(DEBUG),TRUE)

  CXXFLAGS += -g -O0 -fno-inline -ggdb -Wall -Wno-sign-compare
  CFLAGS   += -g -O0 -fno-inline -ggdb -Wall -Wno-sign-compare

  FFLAGS   += -g -O0 -fbounds-check -fbacktrace -Wuninitialized -Wno-maybe-uninitialized -Wunused -ffpe-trap=invalid,zero -finit-real=snan
  F90FLAGS += -g -O0 -fbounds-check -fbacktrace -Wuninitialized -Wno-maybe-uninitialized -Wunused -ffpe-trap=invalid,zero -finit-real=snan

else

  CXXFLAGS += -g -O3
  CFLAGS   += -g -O3
  FFLAGS   += -g -O3
  F90FLAGS += -g -O3

endif

########################################################################

ifeq ($(gcc_major_version),4)
  CXXFLAGS += -std=c++11
else
  CXXFLAGS += -std=c++14
endif
CFLAGS     += -std=gnu99

FFLAGS   += -fimplicit-none -ffixed-line-length-none
F90FLAGS += -fimplicit-none -ffree-line-length-none
FFLAGS   += -fno-range-check -fno-second-underscore -J$(fmoddir) -I $(fmoddir)
F90FLAGS += -fno-range-check -fno-second-underscore -J$(fmoddir) -I $(fmoddir)

########################################################################

GENERIC_COMP_FLAGS =

ifeq ($(THREAD_SANITIZER),TRUE)
  GENERIC_COMP_FLAGS += -fsanitize=thread
endif
ifeq ($(FSANITIZER),TRUE)
  GENERIC_COMP_FLAGS += -fsanitize=address -fsanitize=undefined
endif

ifeq ($(USE_OMP),TRUE)
  GENERIC_COMP_FLAGS += -fopenmp
endif

CXXFLAGS += $(GENERIC_COMP_FLAGS)
CFLAGS   += $(GENERIC_COMP_FLAGS)
FFLAGS   += $(GENERIC_COMP_FLAGS)
F90FLAGS += $(GENERIC_COMP_FLAGS)

########################################################################

# ask gfortran the name of the library to link in.  First check for the
# static version.  If it returns only the name w/o a path, then it
# was not found.  In that case, ask for the shared-object version.
gfortran_liba  := $(shell $(F90) -print-file-name=libgfortran.a)
gfortran_libso := $(shell $(F90) -print-file-name=libgfortran.so)
quadmath_liba  := $(shell $(F90) -print-file-name=libquadmath.a)
quadmath_libso := $(shell $(F90) -print-file-name=libquadmath.so)
ifneq ($(gfortran_liba),libgfortran.a)  # if found the full path is printed, thus `neq`.
  gfortran_lib = $(gfortran_liba)
else
  gfortran_lib = $(gfortran_libso)
endif
ifneq ($(quadmath_liba),libquadmath.a)
  quadmath_lib = $(quadmath_liba)
else
  quadmath_lib = $(quadmath_libso)
endif

override XTRALIBS += $(gfortran_lib) $(quadmath_lib)