OLD_WD=`pwd`

apt-get install build-essential binutils bison gcc make golang

bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /root/.gvm/scripts/gvm
gvm install go1.12
gvm use go1.12 --default


git clone https://github.com/harmony-one/mcl.git $GOPATH/src/github.com/harmony-one/mcl
git clone https://github.com/harmony-one/harmony.git $GOPATH/src/github.com/harmony-one/harmony
git clone https://github.com/harmony-one/bls.git $GOPATH/src/github.com/harmony-one/bls
git clone https://github.com/go-delve/delve.git $GOPATH/src/github.com/go-delve/delve

cd $GOPATH/src/github.com/go-delve/delve
make install

cd $GOPATH/src/github.com/harmony-one/harmony
sed 's/DEBUG=false/DEBUG=true/g' scripts/go_executable_build.sh > scripts/go_executable_build.sh
make

cd bin
cp harmony $OLD_WD/
cp bootnode $OLD_WD/
cp txgen $OLD_WD/
cp wallet $OLD_WD/

cd $OLD_WD

echo "All done!"

