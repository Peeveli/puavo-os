prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
sbindir = $(exec_prefix)/sbin
datarootdir = $(prefix)/share
templatedir = $(datarootdir)/puavo-ds-slave/templates

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

.PHONY: all
all:

.PHONY: installdirs
installdirs:
	mkdir -p $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(sbindir)
	mkdir -p $(DESTDIR)$(datarootdir)/puavo-ds-slave
	mkdir -p $(DESTDIR)$(templatedir)/etc/init
	mkdir -p $(DESTDIR)/etc/bash_completion.d

.PHONY : bin/puavo-ds-installdirs
bin/puavo-ds-installdirs:
	mkdir -p bin
	echo "PUAVO_DS_TEMPLATEDIR=$(templatedir)" > $@

.PHONY: install
install: bin/puavo-ds-installdirs installdirs
	$(INSTALL_PROGRAM) -t $(DESTDIR)$(sbindir) \
		puavo-init-ds-slave \
		puavo-init-ldap-slave \
		puavo-init-kdc-slave

	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/puavo-ds-slave \
		init_ldap_slave.ldif.erb

	$(INSTALL_PROGRAM) -t $(DESTDIR)$(bindir) \
                bin/*

	$(INSTALL_DATA) -t $(DESTDIR)/etc/bash_completion.d \
		bash_completion.d/*

	rm -f bin/puavo-bootserver-installdirs

.PHONY: clean
clean:
