#!/bin/bash
# Copyright (c) 2016-2021, Myriota Pty Ltd, All Rights Reserved
# SPDX-License-Identifier: BSD-3-Clause-Attribution
#
# This file is licensed under the BSD with attribution  (the "License"); you
# may not use these files except in compliance with the License.
#
# You may obtain a copy of the License here:
# LICENSE-BSD-3-Clause-Attribution.txt and at
# https://spdx.org/licenses/BSD-3-Clause-Attribution.html
#
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ $OSTYPE == 'linux'* ]]; then
  echo "SDK Installation on Linux System"
  sudo apt-get -y update

  # Myriota Development Board requirements
  if $(cat /etc/os-release | grep -q "Ubuntu 20.04"); then
      sudo apt-get -y install make curl python3 python3-pip python-is-python3
      sudo -H pip3 install -r requirements.txt
  elif $(cat /etc/os-release | grep -q "Ubuntu 16.04"); then
    echo -e "\t======================================================================="
    echo -e "\tWARNING: Ubuntu 16.04 is not supported. Some installations may fail"
    echo -e "\t======================================================================="
    sudo apt-get -y install make curl python bzip2
    curl -O https://bootstrap.pypa.io/2.7/get-pip.py
    sudo python get-pip.py
    sudo python -m pip install --upgrade "pip < 21.0"
    sudo -H pip install -r requirements.txt
  else
      sudo apt-get -y install make curl python python-pip
      sudo -H pip install -r requirements.txt
  fi
  curl -O https://downloads.myriota.com/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
  sudo mkdir -p /opt/gcc-arm
  sudo tar -xjvf gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -C /opt/gcc-arm --strip-components=1
  sudo cp module/g2/99-myriota-g2.rules /etc/udev/rules.d
  sudo udevadm control --reload-rules && sudo udevadm trigger

  # Satellite Simulator requirements
  sudo apt-get -y install build-essential rtl-sdr
  make -C tools/ satellite_simulator

  # Tools for testing
  sudo apt-get -y install expect
elif [[ $OSTYPE == 'darwin'* ]]; then
  echo "SDK Installation on macOS"
  # check if installation of homebrew necessary
  if [ -z $(which brew) ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # Myriota Development Board requirements
  brew install make curl python3 coreutils expect
  pip3 install -r requirements.txt

  echo "Change symlink for relevant tools"
  ln -sf /usr/local/bin/python3 /usr/local/bin/python
  ln -sf /usr/local/opt/coreutils/libexec/gnubin/cp /usr/local/bin/cp
  ln -sf /usr/local/opt/coreutils/libexec/gnubin/mv /usr/local/bin/mv

  echo "Install ARM compiler"
  curl -O https://downloads.myriota.com/gcc-arm-none-eabi-7-2017-q4-major-mac.tar.bz2
  sudo mkdir -p /opt/gcc-arm
  sudo tar -xvjf gcc-arm-none-eabi-7-2017-q4-major-mac.tar.bz2 -C /opt/gcc-arm --strip-components=1

  # Satellite Simulator requirements
  # require gcc major version 7 (brew install gcc is version 8)
  brew install gcc@7
  # gcc defaults to clang on macOS -> create symbolic links for the real thing
  ln -sf /usr/local/bin/gcc-7 /usr/local/bin/cc
  ln -sf /usr/local/bin/g++-7 /usr/local/bin/c++
  ln -sf /usr/local/bin/gcc-7 /usr/local/bin/gcc
  ln -sf /usr/local/bin/g++-7 /usr/local/bin/g++
  brew install rtl-sdr
  make -C tools/ satellite_simulator
fi
