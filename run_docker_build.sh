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

FOR_PYTHON3=ON
if test "${PYBASEVER}" = "2.7"
then
  FOR_PYTHON3=OFF
fi

cd /tmp
git clone https://gitlab.com/agrumery/aGrUM.git workdir
cd workdir
git checkout ${VERSION}
PREFIX=$PWD/install
CXXFLAGS="-D_hypot=hypot -DNDEBUG -DMS_WIN64 -O1" ${ARCH}-w64-mingw32-cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib \
  -DPYTHON_INCLUDE_DIR=${MINGW_PREFIX}/include/python${PYMAJMIN} \
  -DPYTHON_LIBRARY=${MINGW_PREFIX}/lib/libpython${PYMAJMIN}.dll.a \
  -DPYTHON_EXECUTABLE=/usr/bin/${ARCH}-w64-mingw32-python${PYMAJMIN}-bin \
  -DPYTHON_SITE_PACKAGES=Lib/site-packages \
  -DFOR_PYTHON3=${FOR_PYTHON3} \
  -DUSE_SWIG=OFF \
  .
make install
${ARCH}-w64-mingw32-strip --strip-unneeded ${PREFIX}/bin/*.dll ${PREFIX}/Lib/site-packages/*/*.pyd

cd ${PREFIX}/Lib/site-packages
cp -v ${MINGW_PREFIX}/bin/{libgcc_s,libstdc++,libgomp,libwinpthread}*.dll ${PREFIX}/bin/*.dll pyAgrum

touch numpy.py
${ARCH}-w64-mingw32-python${PYMAJMIN}-bin -c "import pyAgrum as gum; bn = gum.fastBN('a->b->d;a->c->d->e;f->b'); bn.generateCPTs(); ie = gum.LazyPropagation(bn); print(ie.posterior('d'))"

zip -r agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip pyAgrum

if test -n "${uid}" -a -n "${gid}"
then
  sudo cp -v agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip /io
  sudo chown ${uid}:${gid} /io/agrum-${VERSION}-py${PYBASEVER}-${ARCH}.zip
fi

