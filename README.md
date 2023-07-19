usage

```shell
#
# build && install yosys
DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev ca-certificates gcc iverilog
cd yosys
make
sudo make install
cd ..
# run yosys
bash ./synth.sh | tee ./result/gcd.log
```