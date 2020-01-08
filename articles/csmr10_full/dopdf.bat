latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
bibtex article
latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
latex -file-line-error-style -interaction=nonstopmode -src-specials article.tex
dvips article -o
ps2pdf14 article.ps

