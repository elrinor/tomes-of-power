.PHONY:
all: wcre11.pdf

wcre11.aux: wcre11.tex workflow.pdf if-then-else.pdf
	pdflatex wcre11.tex

wcre11.bbl: wcre11.bib wcre11.aux
	-bibtex wcre11

wcre11.pdf: wcre11.bbl wcre11.tex workflow.pdf if-then-else.pdf
	pdflatex wcre11.tex

workflow.pdf: workflow.dot
	dot -Tpdf workflow.dot > workflow.pdf

if-then-else.pdf: if-then-else.dot
	dot -Tpdf if-then-else.dot > if-then-else.pdf

.PHONY:
clean:
	rm -f wcre11.aux wcre11.bbl wcre11.blg wcre11.log wcre11.pdf workflow.pdf if-then-else.pdf
