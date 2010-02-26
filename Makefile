#   Makefile for fgn-backup
#   Copyright (C) 2009 Erik Auerswald <auerswald@fg-networking.de>
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
MANDIR     := $(PREFIX)/share/man/man1
DOCDIR     := $(PREFIX)/share/doc/$(PKGNAME)
EXAMPLEDIR := $(DOCDIR)/examples
BIN        := fgn-backup
MODULES    := archive-tar logging mysql-dump check-free-ftp-space ftp-upload \
              show-help modules fgn-backup.global.conf
CONFIGS    := fgn-backup.crontab fgn-backup.logrotate
DOCS       := AUTHORS COPYING
EXAMPLES   := $(wildcard *.example*)
SOURCES    := $(addsuffix .in,$(BIN) $(MODULES))

all:
	@echo Targets:
	@echo "  install    - install $(PKGNAME) (understands PREFIX and DESTDIR)"
	@echo "  dist       - create a tar.bz2 archive of $(PKGNAME)"
	@echo "  tgz        - create a pseudo-slackware-package of $(PKGNAME)"
	@echo "  clean      - remove generated files (except archives/packages)"
	@echo "  real-clean - remove generated files including archives/packages"

install: $(BIN) $(MODULES) $(CONFIGS) $(DOCS) $(EXAMPLES)
	install -d -m 0755 -o root -g root \
	    $(DESTDIR)$(BINDIR) $(DESTDIR)$(LIBDIR) $(DESTDIR)$(MANDIR) \
	    $(DESTDIR)$(DOCDIR) $(DESTDIR)$(EXAMPLEDIR)
	install -d -m 0755 -o root -g root \
	    $(DESTDIR)/etc/cron.d $(DESTDIR)/etc/logrotate.d
	install -m 0755 -o root -g root $(BIN) $(DESTDIR)$(BINDIR)
	install -m 0644 -o root -g root $(MODULES) $(DESTDIR)$(LIBDIR)
	install -m 0644 -o root -g root fgn-backup.crontab \
	    $(DESTDIR)/etc/cron.d/$(PKGNAME)
	install -m 0644 -o root -g root fgn-backup.logrotate \
	    $(DESTDIR)/etc/logrotate.d/$(PKGNAME)
	install -m 0644 -o root -g root $(DOCS) $(DESTDIR)$(DOCDIR)
	install -m 0644 -o root -g root $(EXAMPLES) $(DESTDIR)$(EXAMPLEDIR)

dist: clean $(SOURCES) $(CONFIGS) $(DOCS) $(EXAMPLES) version
	TDIR=$(shell mktemp -d) ; \
	DNAME=$(PKGNAME)-$(shell cat version) ; \
	DDIR=$$TDIR/$$DNAME ; \
	mkdir $$DDIR ; \
	cp $(SOURCES) $(CONFIGS) $(DOCS) $(EXAMPLES) Makefile version $$DDIR ; \
	tar cvfj $$DNAME.tar.bz2 -C $$TDIR $$DNAME ; \
	$(RM) -rf $$TDIR

tgz: clean $(BIN) $(MODULES) $(CONFIGS) $(DOCS) $(EXAMPLES) version
	BUILDDIR=$(shell mktemp -d) ; \
	fakeroot $(MAKE) DESTDIR=$$BUILDDIR install ; \
	fakeroot tar cfz $(PKGNAME)-$(shell cat version).tgz -C $$BUILDDIR \
	    usr etc ; \
	$(RM) -rf $$BUILDDIR

clean:
	$(RM) version $(BIN) $(MODULES)

real-clean: clean
	$(RM) *.tar.bz2 *.tgz

$(BIN) $(MODULES): $(addsuffix .in,$(BIN) $(MODULES)) version
	sed -e 's/@@VERSION@@/$(shell cat version)/' \
	    -e 's|@@LIBDIR@@|$(LIBDIR)|' \
	    -e 's|@@DOCDIR@@|$(DOCDIR)|'  <$(addsuffix .in,$@) >$@

version:
	printf "git%05d" $(shell git log | grep ^commit | wc -l) > $@

.PHONY: all install dist clean real-clean
