#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION PYBASEVER [uid] [gid]"
  exit 1
}

test $# -ge 2 || usage

VERSION=$1
PYBASEVER=$2
PYMAJMIN=${PYBASEVER:0:1}${PYBASEVER:2}
ARCH=x86_64
MINGW_PREFIX=/usr/${ARCH}-w64-mingw32
uid=$3
gid=$4

cd /tmp
curl -L https://gitlab.com/agrumery/aGrUM/-/archive/${VERSION}/aGrUM-${VERSION}.tar.gz | tar xz
cd aGrUM-${VERSION}

PREFIX=$PWD/install
${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib \
  -DPython_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DUSE_SWIG=OFF \
  -DBUILD_PYTHON=ON \
  .
make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll ${PREFIX}/Lib/site-packages/*/*.pyd

cd ${PREFIX}/Lib/site-packages
cp -v ${MINGW_PREFIX}/bin/{libgcc_s,libstdc++,libgomp,libwinpthread,libssp}*.dll ${PREFIX}/bin/*.dll pyAgrum

touch numpy.py
curl -fSsLO https://raw.githubusercontent.com/benjaminp/six/master/six.py
PYTHONPATH=${PREFIX}/Lib/site-packages ${ARCH}-w64-mingw32-python${PYMAJMIN}-bin /io/mingw_test.py

zip -r agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip pyAgrum

if test -n "${uid}" -a -n "${gid}"
then
  sudo cp -v agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip /io
  sudo chown ${uid}:${gid} /io/agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip
fi

