prefix = /usr
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

.PHONY: all
all: po/fi/puavo-user-registration.mo

puavo-user-registration.pot: puavo-user-registration
	xgettext --omit-header --language python --keyword=_tr -o $@ $^

%.po: po/puavo-user-registration.pot
	msgmerge --update --no-fuzzy-matching --backup=off $@ $<
	touch $@

%.mo: %.po
	msgfmt $< --output-file $@

.PHONY: installdirs
installdirs:
	mkdir -p $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(datarootdir)/applications
	mkdir -p $(DESTDIR)$(datarootdir)/puavo-conf/definitions
	mkdir -p $(DESTDIR)$(datarootdir)/puavo-user-registration
	mkdir -p $(DESTDIR)$(datarootdir)/locale/fi/LC_MESSAGES

.PHONY: install
install: installdirs
	$(INSTALL_PROGRAM) -t $(DESTDIR)$(bindir) puavo-user-registration
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/applications \
		puavo-user-registration.desktop
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/puavo-conf/definitions \
		puavo-user-registration.json
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/puavo-user-registration \
		background_1366.png \
		background_1920.png \
		puavo-user-registration.css \
		puavo-user-registration.glade
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/locale/fi/LC_MESSAGES \
		po/fi/puavo-user-registration.mo

.PHONY: clean
clean:
	rm -rf po/*/*.mo po/*.pot
