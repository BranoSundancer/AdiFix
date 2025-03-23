# AdiFix

## Use Case

When sending ADIF QSOs via UDP from WSJT-X to my favorite logger I learned there is no DXXCC/COUNTRY/NAME value. Manual editing was a pain, so I created a proxy.

## Prerequisites

* Linux with:
  * wget - only for download of external data, you can use curl instead
  * socat - for the UDP handling (nc/netcat had some issues)
  * bash

* **dxcc** perl script + recent cty.dat. Useful for real country especially for special callsigns.

* **QRZ.com registration** - paid **subcription is not needed** for basic XMLRPC queries, however number of queries is limited per day. One QSO takes 1-3 QRZ queries. Useful for callsign name.

* Official **AARL DXCC list** in JSON format. Useful for DXCC to country translation (CTY.dat and QRZ.com **do not** report proper AARL country names for DXCC 291 or 54).

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
mv -v dxcc.json cty.dat /usr/local/share/dxcc/
```

## Config

Create a **config file** named with your callsign, for example `AB1CDE` with following content:
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

Run the server script with **config file as a parameter**:
```bash
./adifix_server.sh AB1CDE
```
The console output for monitoring is `stderr` (`stdout` is used for the forwarding itself). When UDP packet with QSO is received, you will see the UTC of the reception and in few seconds CALLSIGN and resolved values for NAME, COUNTRY and DXCC are displayed. If the QSO already contained those values, they are **never** modified.

You could also create systemctl or init service if you wish.
