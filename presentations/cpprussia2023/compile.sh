#!/bin/bash

mkdir tmp

for i in {1..61}
do
    while : ; do
        slidev export \
            --with-clicks \
            --range $i \
            --timeout 0 \
            --per-slide \
            --output "$(printf "tmp/slide_%02d.pdf" $i)"
        if [[ $? == 0 ]]; then
            break
        fi
    done
done

pdfunite tmp/slide_*.pdf slides.pdf
