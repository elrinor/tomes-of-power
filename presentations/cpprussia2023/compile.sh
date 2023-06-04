#!/bin/bash

rm -R ./tmp
mkdir tmp

for i in {1..97}
do
    while : ; do
        slidev export \
            --with-clicks \
            --range $i \
            --timeout 0 \
            --per-slide \
            --output "$(printf "tmp/slide_%03d.pdf" $i)"
        if [[ $? == 0 ]]; then
            break
        fi
    done
done

pdfunite tmp/slide_*.pdf slides_big.pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=slides.pdf slides_big.pdf
