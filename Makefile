PKGNAME    := fgn-backup
PREFIX     := /usr/local
BINDIR     := $(PREFIX)/bin
LIBDIR     := $(PREFIX)/lib/$(PKGNAME)
MANDIR     := $(PREFIX)/share/man/man1
DOCDIR     := $(PREFIX)/share/doc/$(PKGNAME)
EXAMPLEDIR := $(DOCDIR)/examples
BIN        := fgn-backup
MODULES    := archive-tar logging mysql-dump check-free-ftp-space ftp-upload
DOCS       := AUTHORS
EXAMPLES   := $(wildcard *.example*)

all:
	@echo Targets:
	@echo "  install - install $(PKGNAME) (understands PREFIX and DESTDIR)"
	@echo "  dist    - create a tar.bz2 archive of $(PKGNAME)"
	@echo "  tgz     - create a pseudo-slackware-package of $(PKGNAME)"
	@echo "  clean   - remove generated files (except archives/packages)"

install: $(BIN) $(MODULES) $(DOCS) $(EXAMPLES)
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

dist: $(BIN) $(MODULES) $(DOCS) $(EXAMPLES)
	tar cfj $(PKGNAME)-$(shell cat version).tar.bz2 $(BIN) $(MODULES) \
	    $(DOCS) $(EXAMPLES) Makefile

tgz: $(BIN) $(MODULES) $(DOCS) $(EXAMPLES)
	BUILDDIR=$(shell mktemp -d) ; \
	fakeroot $(MAKE) DESTDIR=$$BUILDDIR install ; \
	fakeroot tar cfz $(PKGNAME)-$(shell cat version).tgz -C $$BUILDDIR \
	    usr etc ; \
	$(RM) -rf $$BUILDDIR

clean:
	$(RM) version $(BIN) $(MODULES)

$(BIN) $(MODULES): $(addsuffix .in,$(BIN) $(MODULES)) version
	sed 's/@@VERSION@@/$(shell cat version)/' <$(addsuffix .in,$@) >$@

version:
	printf "svn%05d" \
	    $(shell svn info | sed -n 's/^Revision: \([0-9]\+\)$$/\1/p') > $@

.PHONY: all install dist clean version
