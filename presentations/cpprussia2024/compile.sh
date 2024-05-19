#!/bin/bash

rm -R ./tmp2
mkdir tmp2

for i in {1..39}
do
    while : ; do
        slidev export \
            --with-clicks \
            --range $i \
            --timeout 0 \
            --per-slide \
            --output "$(printf "tmp2/slide_%03d.pdf" $i)"
        if [[ $? == 0 ]]; then
            break
        fi
    done
done

pdfunite tmp2/slide_*.pdf slides_big.pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=slides.pdf slides_big.pdf
