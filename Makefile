all: tests install

install:
	cp -r ./lib/App /usr/share/perl5

tests:
	prove -Ilib -v ./t/*
