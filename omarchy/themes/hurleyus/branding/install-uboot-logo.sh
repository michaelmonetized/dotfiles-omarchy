#!/usr/bin/env bash
set -euo pipefail

# Patch the compiled-in U-Boot splash (160x160 8-bit RLE BMP, 6932 bytes)
# then rebuild m1n1 stage2 on the ESP.

BMP="$(cd "$(dirname "$0")" && pwd)/uboot-logo.bmp"
SRC="/usr/lib/asahi-boot/u-boot-nodtb.bin"
OUT="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/hurleyus-u-boot-nodtb.bin"

if [[ ! -f $BMP ]]; then
  echo "Missing $BMP" >&2
  exit 1
fi
if [[ ! -f $SRC ]]; then
  echo "Missing $SRC (not an Asahi U-Boot install?)" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

python3 - "$SRC" "$BMP" "$OUT" <<'PY'
import pathlib, struct, sys

src, bmp_path, out = map(pathlib.Path, sys.argv[1:4])
data = bytearray(src.read_bytes())
bmp = bmp_path.read_bytes()
if bmp[:2] != b"BM":
    raise SystemExit("uboot-logo.bmp is not a BMP")
if len(bmp) > 6932:
    raise SystemExit(f"BMP is {len(bmp)} bytes, slot is 6932")

off = None
start = 0
while True:
    i = data.find(b"BM", start)
    if i < 0:
        break
    if i + 34 <= len(data):
        size, _, _, _, dib, width, height = struct.unpack_from("<IHHIIII", data, i + 2)
        bpp = struct.unpack_from("<H", data, i + 28)[0]
        if width == 160 and height == 160 and bpp == 8 and 4000 <= size <= 6932:
            off = i
            break
    start = i + 2

if off is None:
    raise SystemExit("Could not find 160x160 8-bit BMP slot in u-boot-nodtb.bin")

data[off : off + len(bmp)] = bmp
if len(bmp) < 6932:
    # keep the slot size; leftover bytes after bfSize are ignored
    pass
out.write_bytes(data)
print(f"Patched U-Boot splash at offset {off} ({len(bmp)} bytes) -> {out}")
PY

sudo env U_BOOT="$OUT" update-m1n1
echo "Asahi U-Boot splash is Hurleyus. Reboot to see it."
