PDFLATEX=pdflatex
LATEX=latex
BIBTEX=bibtex
DVI2PDF=dvipdf
PS2PDF=ps2pdf
UNAME:=$(shell uname -s)
ifeq ($(UNAME),Linux)
	VIEWER=xdg-open
endif
ifeq ($(UNAME), Darwin)
	VIEWER=open -a preview
endif

FILE_NAME=main

.PHONY: all, clean, view

all:
	# $(LATEX) $(FILE_NAME).tex
	$(PDFLATEX) $(FILE_NAME).tex
	$(BIBTEX) $(FILE_NAME).aux
	$(PDFLATEX) $(FILE_NAME).tex
	$(PDFLATEX) $(FILE_NAME).tex
	# $(LATEX) $(FILE_NAME).tex
	# $(LATEX) $(FILE_NAME).tex
	# $(DVI2PDF) $(FILE_NAME).dvi
	# $(PS2PDF) $(FILE_NAME).ps

view: all
	$(VIEWER) $(FILE_NAME).pdf
	rm *.log *.aux *.out *.blg *.bbl
	#rm *-eps-converted-to.pdf
	pdffonts main.pdf

clean:
	rm *.log *.aux *.dvi *.out *.blg *.bbl *.ps *.bak
