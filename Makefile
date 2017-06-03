#!/usr/bin/make -f

fontpath=/usr/share/fonts/truetype/malayalam
fonts=Dyuthi-Regular
feature=features/features.fea
PY=python2.7
buildscript=tools/build.py
default: compile
all: compile webfonts

compile:
	@for font in `echo ${fonts}`;do \
		echo "Generating $$font.ttf";\
		$(PY) $(buildscript) $$font.sfd $(feature);\
	done;

webfonts:compile
	@echo "Generating webfonts";
	@for font in `echo ${fonts}`;do \
		sfntly -w $${font}.ttf $${font}.woff;\
		sfntly -e -x $${font}.ttf $${font}.eot;\
		[ -x `which woff2_compress` ] && woff2_compress $${font}.ttf;\
	done;

install: compile
	@for font in `echo ${fonts}`;do \
		install -D -m 0644 $${font}.ttf ${DESTDIR}/${fontpath}/$${font}.ttf;\
	done;

ifeq ($(shell ls -l *.ttf 2>/dev/null | wc -l),0)
test: compile run-test
else
test: run-test
endif

run-test:
	@for font in `echo ${fonts}`; do \
		echo "Testing font $${font}";\
		hb-view $${font}.ttf --font-size 14 --margin 100 --line-space 1.5 --foreground=333333  --text-file tests/tests.txt --output-file tests/$${font}.pdf;\
	done;
clean:
	@rm -rf *.otf *.ttf *.woff *.woff2 *.sfd-* tests/*.pdf
