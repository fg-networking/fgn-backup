PKGNAME    := fgn-backup
PREFIX     := /usr/local
BINDIR     := $(PREFIX)/bin
LIBDIR     := $(PREFIX)/lib/$(PKGNAME)
MANDIR     := $(PREFIX)/share/man/man1
DOCDIR     := $(PREFIX)/share/doc/$(PKGNAME)
EXAMPLEDIR := $(DOCDIR)/examples
BIN        := fgn-backup
MODULES    := archive-tar logging mysql-dump
CONFIGS    := $(wildcard fgn-backup.*)
DOCS       := AUTHORS
EXAMPLES   := $(wildcard *.example*)
SOURCES    := $(BIN) $(MODULES) $(CONFIGS)

all:
	@echo Targets:
	@echo "  install - install $(PKGNAME) (understands PREFIX and DESTDIR)"
	@echo "  dist    - create a tar.bz2 archive of $(PKGNAME)"
	@echo "  tgz     - create a pseudo-slackware-package of $(PKGNAME)"
	@echo "  clean   - remove generated file (except archives/packages)"

install: $(SOURCES) version
	install -d -m 0755 -o root -g root \
	    $(DESTDIR)$(BINDIR) $(DESTDIR)$(LIBDIR) $(DESTDIR)$(MANDIR) \
	    $(DESTDIR)$(DOCDIR) $(DESTDIR)$(EXAMPLEDIR)
	install -d -m 0755 -o root -g root \
	    $(DESTDIR)/etc/cron.d $(DESTDIR)/etc/logrotate.d
	install -m 0700 -o root -g root $(BIN) $(DESTDIR)$(BINDIR)
	install -m 0600 -o root -g root $(MODULES) $(DESTDIR)$(LIBDIR)
	install -m 0644 -o root -g root fgn-backup.crontab \
	    $(DESTDIR)/etc/cron.d/$(PKGNAME)
	install -m 0644 -o root -g root fgn-backup.logrotate \
	    $(DESTDIR)/etc/logrotate.d/$(PKGNAME)
	install -m 0644 -o root -g root $(DOCS) $(DESTDIR)$(DOCDIR)
	install -m 0644 -o root -g root $(EXAMPLES) $(DESTDIR)$(EXAMPLEDIR)
	sed -i 's/@@VERSION@@/$(shell cat version)/' \
	    $(DESTDIR)$(BINDIR)/$(BIN) \
	    $(addprefix $(DESTDIR)$(LIBDIR)/,$(MODULES))

dist: $(SOURCES) version
	tar cfj $(PKGNAME)-$(shell cat version).tar.bz2 $(SOURCES) Makefile

tgz: $(SOURCES) version
	BUILDDIR=$(shell mktemp -d) ; \
	fakeroot $(MAKE) DESTDIR=$$BUILDDIR install ; \
	fakeroot tar cfz $(PKGNAME)-$(shell cat version).tgz -C $$BUILDDIR \
	    usr etc ; \
	$(RM) -rf $$BUILDDIR

clean:
	$(RM) version

version:
	printf "svn%05d" \
	    $(shell svn info | sed -n 's/^Revision: \([0-9]\+\)$$/\1/p') > $@

.PHONY: all install dist clean version
