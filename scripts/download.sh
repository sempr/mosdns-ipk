#!/bin/bash

mkdir -p tmp
pushd tmp
FILES=$(curl -fsS -L https://github.com/leemars/v2ray-rules-dat/releases/latest | grep download | grep -E "geo" | grep -v sha256sum | awk -F"href=\"" '{print $2}' | awk -F"\"" '{print $1}')
for f in $FILES; do
    curl -fsS -OL https://github.com$f
done

DOWNLOAD_URL=$(curl -fsS -L https://github.com/IrineSistiana/mosdns/releases/latest | grep mosdns-linux-amd64 | awk -F"href=\"" '{print $2}' | awk -F"\"" '{print $1}')
curl -fsS -OL "https://github.com${DOWNLOAD_URL}"
mkdir -p mosdns
unzip -o mosdns-linux-amd64.zip -d mosdns

# create package

mkdir -p package
pushd package
mkdir -p {control,data}
mkdir -p data/etc/mosdns
mkdir -p data/usr/bin
mv ../mosdns/mosdns data/usr/bin
mv ../{geoip,geosite}.dat data/etc/mosdns
tree .

cat <<EOF >>control/control
Package: mosdns-go
Version: 1.0
SourceName: mosdns-go
Architecture: x86_64
Description:  mosdns go
EOF

pushd control
tar cvzf ../control.tar.gz ./*
popd

pushd data
tar cvzf ../data.tar.gz ./*
popd
echo 2.0 >debian-binary
tar cvzf mosdns-go-1.0.ipk control.tar.gz data.tar.gz debian-binary
export PACKAGE_OUTPUT_PATH=${PWD}/mosdns-go-1.0.ipk
popd

popd

echo ${PACKAGE_OUTPUT_PATH}