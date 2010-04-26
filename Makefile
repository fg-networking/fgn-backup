#   Makefile for fgn-backup
#   Copyright (C) 2009-2010 Erik Auerswald <auerswald@fg-networking.de>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

PKGNAME    := fgn-backup
PREFIX     := /usr/local
BINDIR     := $(PREFIX)/sbin
LIBDIR     := $(PREFIX)/share/$(PKGNAME)
MODDIR     := $(LIBDIR)/modules.d
MANDIR     := $(PREFIX)/share/man/man8
DOCDIR     := $(PREFIX)/share/doc/$(PKGNAME)
EXAMPLEDIR := $(DOCDIR)/examples
LOGDIR     := /var/log/$(PKGNAME)
BIN        := fgn-backup
MODULES    := archive-tar logging mysql-dump check-free-ftp-space ftp-upload \
              show-help modules openldap-dump
GCONFIGS   := fgn-backup.global.conf
DOCS       := AUTHORS COPYING
EXAMPLES   := fgn-backup.conf.example fgn-backup.crontab.example \
              fgn-backup.logrotate.example tar-exclude.example.root \
              tar-exclude.example.var
SOURCES    := $(addsuffix .in,$(BIN) $(GCONFIGS) $(MODULES) $(EXAMPLES))

all:
	@echo Targets:
	@echo "  install    - install $(PKGNAME) (supports PREFIX and DESTDIR)"
	@echo "  dist       - create a tar.bz2 archive of $(PKGNAME)"
	@echo "  tgz        - create a pseudo-slackware-package of $(PKGNAME)"
	@echo "  clean      - remove generated files (except archives/packages)"
	@echo "  real-clean - remove generated files including archives/packages"

install: $(BIN) $(MODULES) $(GCONFIGS) $(DOCS) $(EXAMPLES)
	install -d -m 0755 -o root -g root \
	    $(DESTDIR)$(BINDIR) $(DESTDIR)$(LIBDIR) $(DESTDIR)$(MODDIR) \
	    $(DESTDIR)$(MANDIR) $(DESTDIR)$(DOCDIR) $(DESTDIR)$(EXAMPLEDIR)
	install -m 0755 -o root -g root $(BIN) $(DESTDIR)$(BINDIR)
	install -m 0644 -o root -g root $(GCONFIGS) $(DESTDIR)$(LIBDIR)
	install -m 0644 -o root -g root $(MODULES) $(DESTDIR)$(MODDIR)
	install -m 0644 -o root -g root $(DOCS) $(DESTDIR)$(DOCDIR)
	install -m 0644 -o root -g root $(EXAMPLES) $(DESTDIR)$(EXAMPLEDIR)

dist: clean $(SOURCES) $(DOCS) version
	TDIR=$(shell mktemp -d) ; \
	DNAME=$(PKGNAME)-$(shell cat version) ; \
	DDIR=$$TDIR/$$DNAME ; \
	mkdir $$DDIR ; \
	cp $(SOURCES) $(DOCS) Makefile version $$DDIR; \
	tar cvfj $$DNAME.tar.bz2 -C $$TDIR $$DNAME ; \
	$(RM) -rf $$TDIR

tgz: clean $(BIN) $(MODULES) $(GCONFIGS) $(DOCS) $(EXAMPLES) version
	BUILDDIR=$(shell mktemp -d) ; \
	fakeroot $(MAKE) DESTDIR=$$BUILDDIR install ; \
	fakeroot tar cfz $(PKGNAME)-$(shell cat version).tgz -C $$BUILDDIR . ; \
	$(RM) -rf $$BUILDDIR

clean:
	$(RM) version $(BIN) $(MODULES) $(GCONFIGS) $(EXAMPLES)

real-clean: clean
	$(RM) *.tar.bz2 *.tgz

$(BIN) $(MODULES) $(GCONFIGS) $(EXAMPLES): \
           $(addsuffix .in,$(BIN) $(MODULES) $(EXAMPLES)) version
	sed -e 's/@@VERSION@@/$(shell cat version)/g' \
	    -e 's|@@LIBDIR@@|$(LIBDIR)|g' \
	    -e 's|@@MODDIR@@|$(MODDIR)|g' \
	    -e 's|@@DOCDIR@@|$(DOCDIR)|g' \
	    -e 's|@@EXAMPLEDIR@@|$(EXAMPLEDIR)|g' \
	    -e 's|@@BINDIR@@|$(BINDIR)|g' \
	    -e 's|@@LOGDIR@@|$(LOGDIR)|g' <$(addsuffix .in,$@) >$@

version:
	printf "git%05d" $(shell git log | grep ^commit | wc -l) > $@

.PHONY: all install dist clean real-clean
