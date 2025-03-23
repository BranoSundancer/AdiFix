# AdiFix

## Use Case

When sending ADIF QSOs via UDP from WSJT-X to my favorite logger I learned there is no DXXCC/COUNTRY/NAME value. Manual editing was a pain, so I created a proxy.

## Prerequisites

Linux with:
* wget
* socat
* bash

QRZ.com registration is required. Paid subcription is not needed, however number of queries is limited per day. One QSO takes 1-3 QRZ queries.

## Install

```bash
cd DIRECTORY_WITH_ADIFIX_FILES
wget https://git.fkurz.net/dj1yfk/dxcc/raw/branch/master/dxcc
chmod 755 dxcc
wget https://github.com/k0swe/dxcc-json/raw/refs/heads/main/dxcc.json
wget https://www.country-files.com/bigcty/download/2025/bigcty-20250312.zip # check for the latest ZIP file at https://www.country-files.com/category/big-cty/
unzip bigcty-20250312.zip cty.dat

# with sudo
mkdir /usr/local/share/dxcc/
mv -v dxcc.json /usr/local/share/dxcc/
mv -v cty.dat /usr/local/share/dxcc/
```

## Config

Create a file named with your callsign, for example `AB1CDE` with following content:
```bash
# QRZ username and password
QRZ_USER=AB1CDE
QRZ_PASS=MyQRZpa$$word
# listening port (UDP)
ADIFIX_LISTEN=5333
# forwarning IP:port (UDP)
ADIFIX_FORWARD=1.2.3.4:5333
```

## Run

```bash
./adifix_server.sh
```

You could also create systemctl or init service if you wish.
