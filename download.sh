#!/bin/sh

release=0.13.2
for pybasever in 2.7 3.6 3.7
do
  _file=agrum-py${pybasever}-${_arch}.zip
  wget -c https://github.com/openturns/build-agrum/releases/download/v${release}/${_file} -P /tmp
done

sha256sum /tmp/*.zip
