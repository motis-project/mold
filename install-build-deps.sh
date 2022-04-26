#!/bin/bash -x
set -e

source /etc/os-release

case "$ID$VERSION_ID" in
ubuntu20.04)
  apt-get install -y build-essential git g++-10 cmake libssl-dev zlib1g-dev pkg-config git
  ;;
ubuntu22.04)
  apt-get install -y build-essential git g++ cmake libssl-dev zlib1g-dev pkg-config git
  ;;
fedora*)
  dnf install -y git gcc-g++ cmake openssl-devel zlib-devel
  ;;
*)
  echo "Error: don't know anything about build dependencies on $ID $VERSION_ID"
  exit 1
esac
