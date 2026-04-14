#!/bin/bash
SOURCE="Logo Assets/logo_1024.png"
DEST="AstroTerm/Assets.xcassets/AppIcon.appiconset"

# Gerekli tüm iOS ikon boyutlarını oluştur
# sips -z [height] [width] [source] --out [destination]

sips -s format png -z 1024 1024 "$SOURCE" --out "$DEST/Icon-1024.png"
sips -s format png -z 180 180 "$SOURCE" --out "$DEST/Icon-180.png"
sips -s format png -z 167 167 "$SOURCE" --out "$DEST/Icon-167.png"
sips -s format png -z 152 152 "$SOURCE" --out "$DEST/Icon-152.png"
sips -s format png -z 120 120 "$SOURCE" --out "$DEST/Icon-120.png"
sips -s format png -z 87 87 "$SOURCE" --out "$DEST/Icon-87.png"
sips -s format png -z 80 80 "$SOURCE" --out "$DEST/Icon-80.png"
sips -s format png -z 76 76 "$SOURCE" --out "$DEST/Icon-76.png"
sips -s format png -z 60 60 "$SOURCE" --out "$DEST/Icon-60.png"
sips -s format png -z 58 58 "$SOURCE" --out "$DEST/Icon-58.png"
sips -s format png -z 40 40 "$SOURCE" --out "$DEST/Icon-40.png"
sips -s format png -z 29 29 "$SOURCE" --out "$DEST/Icon-29.png"
sips -s format png -z 20 20 "$SOURCE" --out "$DEST/Icon-20.png"

echo "✅ Tüm uygulama ikonları yeni logodan başarıyla oluşturuldu."
