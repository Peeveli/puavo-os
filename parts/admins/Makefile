prefix = /usr
sbindir = $(prefix)/sbin
binaries = libnss_puavoadmins.so.2 \
	puavoadmins-ssh-authorized-keys \
	puavoadmins-validate-orgjson
sysconfdir = /etc

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

CFLAGS = -g -fPIC -std=gnu99 -Wall -Wextra
LDFLAGS = -lm

CFLAGS += $(shell pkg-config --cflags json-c)
LDFLAGS += $(shell pkg-config --libs json-c)

# For some reason ruby lib directory is different under /usr and /usr/local
ifeq ($(prefix),/usr/local)
	RUBY_LIB_DIR = $(prefix)/lib/site_ruby
else
	RUBY_LIB_DIR = $(prefix)/lib/ruby/vendor_ruby
endif

all: $(binaries)
	bundle install --standalone --path lib/puavoadmins-vendor

puavoadmins-validate-orgjson: puavoadmins-validate-orgjson.o orgjson.o
	gcc -o $@ $^ $(LDFLAGS)

puavoadmins-ssh-authorized-keys: puavoadmins-ssh-authorized-keys.o orgjson.o
	gcc -o $@ $^ $(LDFLAGS)

libnss_puavoadmins.so.2: passwd.o group.o orgjson.o
	gcc -shared -o $@ -Wl,-soname,$@ $^ $(LDFLAGS)

%.o: %.c %.h common.h
	gcc $(CFLAGS) -c $< -o $@

%.o: %.c common.h
	gcc $(CFLAGS) -c $< -o $@

installdirs:
	mkdir -p $(DESTDIR)$(sbindir)
	mkdir -p $(DESTDIR)$(prefix)/lib
	mkdir -p $(DESTDIR)$(RUBY_LIB_DIR)
	mkdir -p $(DESTDIR)/var/lib/puavoadmins
	mkdir -p $(DESTDIR)$(sysconfdir)/puavoadmins/skel

install: installdirs all
	$(INSTALL_PROGRAM) -t $(DESTDIR)$(prefix)/lib \
		libnss_puavoadmins.so.2 \
		puavoadmins-ssh-authorized-keys \
		puavoadmins-validate-orgjson \
		puavoadmins-validate-pam-user

	$(INSTALL_PROGRAM) -t $(DESTDIR)$(sbindir) \
		puavoadmins-update

	$(INSTALL_DATA) -t $(DESTDIR)/var/lib/puavoadmins \
		org.json.lock

	cp -r lib/* $(DESTDIR)$(RUBY_LIB_DIR)

clean:
	rm -rf *.o
	rm -rf $(binaries)

.PHONY: all			\
	clean			\
	install			\
	installdirs
