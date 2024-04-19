#!/bin/bash

for i in {1..36}
do
    pdfcrop -margins "0 0 0 -105" "$(printf "tmp/%02d.pdf" $i)" "$(printf "tmp/%02d_c.pdf" $i)"
done

pdfunite tmp/*_c.pdf slides_big.pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=slides.pdf slides_big.pdf
