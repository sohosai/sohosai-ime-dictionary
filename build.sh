#!/usr/bin/env bash

set -ue

OUTPUT_DIR="build"

mkdir -p "${OUTPUT_DIR}"
cat data/*.tsv > "./${OUTPUT_DIR}/sohosai.txt"

cd "./${OUTPUT_DIR}"

# Google IME
cp sohosai.txt sohosai_GoogleIME.txt

# Microsoft IME (Windows)
nkf -w16L -Lw ./sohosai.txt > ./sohosai_Windows.txt

# macOS
tr '\t' ',' < sohosai.txt > sohosai_macOS.txt

# ATOK for Windows
sed 's/短縮よみ/名詞/g' ./sohosai.txt | sed '1s/^/!!ATOK_TANGO_TEXT_HEADER_1\n/' > ./sohosai_ATOK-Windows.txt
nkf --overwrite -w16L -Lw ./sohosai_ATOK-Windows.txt

# ATOK for Mac (macOS)
sed 's/短縮よみ/名詞/g' ./sohosai.txt | sed '1s/^/!!ATOK_TANGO_TEXT_HEADER_1\n/' > ./sohosai_ATOK-macOS.txt
nkf --overwrite -w16L ./sohosai_ATOK-macOS.txt

# plist
cat <<EOF > ./sohosai_macOS.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
EOF

cat sohosai.txt | while IFS=$'\t' read -r yomi name hinshi; do
  if [[ -n "$yomi" && -n "$name" ]]; then
    cat <<EOF >> ./sohosai_macOS.plist
<dict>
  <key>phrase</key>
  <string>${name}</string>
  <key>shortcut</key>
  <string>${yomi}</string>
</dict>
EOF
  fi
done

cat <<EOF >> ./sohosai_macOS.plist
</array>
</plist>
EOF

rm sohosai.txt
