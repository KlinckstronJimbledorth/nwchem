#!/bin/bash 
if [[ "$SCALAPACK_SIZE" != "4"  ]] ; then
    echo SCALAPACK_SIZE must be equal to 4
    exit 1
fi
if [[ "$BLAS_SIZE" != "4"  ]] ; then
    echo BLAS_SIZE must be equal to 4 for SCALAPACK
    exit 1
fi
if [[ -z "$USE_64TO32"   ]] ; then
    echo USE_64TO32 must be set
    exit 1
fi
if [[ ! -z "$BUILD_OPENBLAS"   ]] ; then
    BLASOPT="-L`pwd`/../lib -lopenblas"
fi
#git clone https://github.com/scibuilder/scalapack.git
#svn co --non-interactive --trust-server-cert https://icl.utk.edu/svn/scalapack-dev/scalapack/trunk/ scalapack
rm -rf scalapack*
curl -L http://www.netlib.org/scalapack/scalapack.tgz -o scalapack.tgz
VERSION=2.0.2
tar xzf scalapack.tgz
patch -p0 < mpistruct.patch
ln -sf scalapack-${VERSION} scalapack
mkdir -p scalapack/build
cd scalapack/build
if  [[ -n ${FC} ]] &&   [[ ${FC} == xlf ]] || [[ ${FC} == xlf_r ]] || [[ ${FC} == xlf90 ]]|| [[ ${FC} == xlf90_r ]]; then
    Fortran_FLAGS=" -qintsize=4 -qextname "
elif [[ -n ${FC} ]] &&   [[ ${FC} == flang ]]; then
#unset FC=flang since cmake gets lost
    unset FC
fi
FFLAGS="$Fortran_FLAGS" cmake -Wno-dev ../ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_Fortran_FLAGS="$Fortran_FLAGS" -DTEST_SCALAPACK=OFF  -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF  -DBLAS_openblas_LIBRARY="$BLASOPT"  -DBLAS_LIBRARIES="$BLASOPT"  -DLAPACK_openblas_LIBRARY="$BLASOPT"  -DLAPACK_LIBRARIES="$BLASOPT" 
make V=0 -j3 scalapack/fast
mkdir -p ../../../lib
cp lib/libscalapack.a ../../../lib
