#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION PYBASEVER ARCH [uid] [gid]"
  exit 1
}

test $# -ge 3 || usage

VERSION=$1
PYBASEVER=$2
PYMAJMIN=${PYBASEVER:0:1}${PYBASEVER:2:1}
ARCH=$3
MINGW_PREFIX=/usr/${ARCH}-w64-mingw32
uid=$4
gid=$5

cd /tmp
curl -L https://gitlab.com/agrumery/aGrUM/-/archive/${VERSION}/aGrUM-${VERSION}.tar.gz | tar xz
cd aGrUM-${VERSION}
# https://gitlab.com/agrumery/aGrUM/issues/24
curl -L https://gitlab.com/agrumery/aGrUM/merge_requests/175.patch | patch -p1

PREFIX=$PWD/install
# https://gitlab.com/agrumery/aGrUM/issues/15
CXXFLAGS="-fno-strict-aliasing" ${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib \
  -DPYTHON_INCLUDE_DIR=${MINGW_PREFIX}/include/python${PYMAJMIN} \
  -DPYTHON_LIBRARY=${MINGW_PREFIX}/lib/libpython${PYMAJMIN}.dll.a \
  -DPYTHON_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DPYTHON_INSTALL=Lib/site-packages \
  -DUSE_SWIG=OFF \
  .
make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll ${PREFIX}/Lib/site-packages/*/*.pyd

cd ${PREFIX}/Lib/site-packages
cp -v ${MINGW_PREFIX}/bin/{libgcc_s,libstdc++,libgomp,libwinpthread}*.dll ${PREFIX}/bin/*.dll pyAgrum

touch numpy.py
PYTHONPATH=${PREFIX}/Lib/site-packages ${ARCH}-w64-mingw32-python${PYMAJMIN}-bin /io/mingw_test.py

zip -r agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip pyAgrum

if test -n "${uid}" -a -n "${gid}"
then
  sudo cp -v agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip /io
  sudo chown ${uid}:${gid} /io/agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip
fi

