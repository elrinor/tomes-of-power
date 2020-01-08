latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
bibtex article
latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
dvips article -o -j0 -G0
ps2pdf -sPAPERSIZE#a4 -dCompatibilityLevel#1.3 -dEmbedAllFonts#true -dSubsetFonts#true -dMaxSubsetPct#100 -dAutoFilterColorImages#false -dColorImageFilter#/FlateEncode  -dAutoFilterGrayImages#false -dGrayImageFilter#/FlateEncode -dAutoFilterMonoImages#false -dMonoImageFilter#/CCITTFaxEncode article.ps article.pdf

