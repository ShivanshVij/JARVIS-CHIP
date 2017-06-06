
#!/bin/bash

#This script will install Jarvis onto the CHIP with a choice for either pocketsphinx or snowboy for hotword detection

echo "Preparing for Installation"
echo "Installing dependencies from apt..."

sudo apt-get update
sudo apt-get install python-pyaudio python3-pyaudio sox git python-pip python-dev build-essential make automake gcc g++ bison byacc -y
sudo apt-get install autoconf cpp autotools-dev libc6-dev libjack-jackd2-0 jackd2 -y
sudo apt-get install libatlas-base-dev -y

echo "making sure everything is up to date..."
sudo apt-get upgrade -y

echo "setting up pip..."
sudo pip install --upgrade pip
sudo pip install pyaudio

echo "Cloning dependencies from github and downloading files..."

cd ..
git clone https://github.com/alexylem/jarvis.git
git clone https://github.com/Kitt-AI/snowboy.git
wget https://s3-us-west-2.amazonaws.com/snowboy/snowboy-releases/rpi-arm-raspbian-8.0-1.1.0.tar.bz2


echo "Installing Swig from source"
#Installing the best version of swig
if [ ! -e swig-3.0.7.tar.gz ]; then
  wget -T 10 -t 3 \
    http://prdownloads.sourceforge.net/swig/swig-3.0.7.tar.gz || exit 1;
fi

tar -xovzf swig-3.0.7.tar.gz || exit 1
ln -s swig-3.0.7 swig

cd swig

# We first have to install PCRE.
if [ ! -e pcre-8.37.tar.gz ]; then
  wget -T 10 -t 3 \
    https://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz || exit 1;
fi
Tools/pcre-build.sh

./configure --with-pic
make
sudo make install

cd ..

tar xvjf rpi-arm-raspbian-8.0-1.1.0.tar.bz2
rm -rf rpi-arm-raspbian-8.0-1.1.0.tar.bz2
rm -rf swig-3.0.7.tar.gz
cd snowboy
cd swig/Python
sudo make
sudo cp _snowboydetect.so ~/jarvis/stt_engines/snowboy/_snowboydetect.so
sudo cp snowboydetect.py ~/jarvis/stt_engines/snowboy/snowboydetect.py
cd ..
cd ..
cd examples/Python
sudo mkdir ~/jarvis/stt_engines/snowboy/resources
cd resources
sudo cp common.res ~/jarvis/stt_engines/snowboy/resources/common.res
cd ..
cd ..
cd ..
cd ..
cd rpi-arm-raspbian-8.0-1.1.0
sudo cp snowboydecoder.py ~/jarvis/stt_engines/snowboy/snowboydecoder.py
cd ..
rm -rf rpi-arm-raspbian-8.0-1.1.0
sudo axp209 --no-limit
