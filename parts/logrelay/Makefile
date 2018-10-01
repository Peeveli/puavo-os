
prefix ?= /usr/local

build:
	npm install

install-dirs:
	mkdir -p $(DESTDIR)$(prefix)/lib/node_modules/puavo-logrelay
	mkdir -p $(DESTDIR)/etc
	mkdir -p $(DESTDIR)$(prefix)/bin

install: install-dirs
	cp -r index.coffee package.json node_modules/ lib/ bin/ $(DESTDIR)$(prefix)/lib/node_modules/puavo-logrelay
	install -m 644 config.json $(DESTDIR)/etc/puavo-logrelay.json
	ln -fs ../lib/node_modules/puavo-logrelay/bin/puavo-logrelay $(DESTDIR)$(prefix)/bin/puavo-logrelay

.PHONY: test
test:
	npm test

clean:
	rm -rf node_modules

watch-test:
	./watch.sh npm test

