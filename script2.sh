#!/bin/bash

set -e  # Ferma l'esecuzione in caso di errore
MAGISKBOOT=$(realpath ../magiskboot)

# Creazione cartella temporanea
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Unpacking recovery image..."
mkdir unpack
cd unpack

if [ ! -f ../r.img ]; then
    echo "Errore: r.img non trovato!"
    exit 1
fi

"$MAGISKBOOT" unpack ../r.img || { echo "Errore: boot image corrotta!"; exit 1; }

if [ ! -f ramdisk.cpio ]; then
    echo "Errore: ramdisk.cpio non trovato! Il boot image potrebbe essere incompatibile."
    exit 1
fi

"$MAGISKBOOT" cpio ramdisk.cpio extract

# Applica le patch binarie
echo "Patching system/bin/recovery..."
PATCHES=(
  "e10313aaf40300aa6ecc009420010034 e10313aaf40300aa6ecc0094" 
  "eec3009420010034 eec3009420010035"
  "3ad3009420010034 3ad3009420010035"
  "50c0009420010034 50c0009420010035"
  "080109aae80000b4 080109aae80000b5"
  "20f0a6ef38b1681c 20f0a6ef38b9681c"
  "23f03aed38b1681c 23f03aed38b9681c"
  "20f09eef38b1681c 20f09eef38b9681c"
  "26f0ceec30b1681c 26f0ceec30b9681c"
  "24f0fcee30b1681c 24f0fcee30b9681c"
  "27f02eeb30b1681c 27f02eeb30b9681c"
  "b4f082ee28b1701c b4f082ee28b970c1"
  "9ef0f4ec28b1701c 9ef0f4ec28b9701c"
  "9ef00ced28b1701c 9ef00ced28b9701c"
  "2001597ae0000054 2001597ae1000054"
  "24f0f2ea30b1681c 24f0f2ea30b9681c"
  "41010054a0020012f44f48a9 4101005420008052f44f48a9"
)

for PATCH in "${PATCHES[@]}"; do
  echo "Applying patch: $PATCH"
  "$MAGISKBOOT" hexpatch system/bin/recovery $PATCH
done

# Repack and copy the patched image
echo "Repacking the image..."
"$MAGISKBOOT" cpio ramdisk.cpio 'add 0755 system/bin/recovery system/bin/recovery'
"$MAGISKBOOT" repack ../r.img new-boot.img || { echo "Errore: repack fallito!"; exit 1; }

if [ ! -f new-boot.img ]; then
    echo "Errore: new-boot.img non trovato!"
    exit 1
fi

cp new-boot.img ../recovery-patched.img

if [ ! -f ../recovery-patched.img ]; then
    echo "Errore: recovery-patched.img non trovato!"
    exit 1
fi

echo "Patch completed successfully!"
