rootfs_dir    := /var/tmp/puavo-os/rootfs
rootfs_mirror := $(shell 					\
	awk '/^\s*deb .+ jessie main.*$$/ {print $$2; exit}'	\
	/etc/apt/sources.list 2>/dev/null)

subdirs := parts

.PHONY: all
all: $(subdirs)

.PHONY: $(subdirs)
$(subdirs):
	make -C $@

.PHONY: help
help:
	@echo 'Puavo OS Build System'
	@echo
	@echo 'Targets:'
	@echo '    deb-pkg-build               -  build Debian packages'
	@echo '    deb-pkg-install-build-deps  -  install build dependencies of Debian packages (requires root)'
	@echo '    release                     -  make release commit'
	@echo '    rootfs                      -  build Puavo OS root filesystem directory (requires root)'

.PHONY: deb-pkg-install-build-deps
deb-pkg-install-build-deps: .deb-pkg-install-build-deps-parts \
	.deb-pkg-install-build-deps-ports

.PHONY: .deb-pkg-install-build-deps-parts
.deb-pkg-install-build-deps-parts:
	mk-build-deps -i -t "apt-get --yes --force-yes" -r debian/control

.PHONY: .deb-pkg-install-build-deps-ports
.deb-pkg-install-build-deps-ports:
	$(MAKE) -C ports deb-pkg-install-build-deps

.PHONY: rootfs-create
rootfs-create: $(rootfs_dir)

$(rootfs_dir):
	mkdir -p '$(rootfs_dir).tmp'
	debootstrap --arch=amd64 --include=make jessie \
		'$(rootfs_dir).tmp' '$(rootfs_mirror)'
	git clone . '$(rootfs_dir).tmp/usr/local/src/puavo-os'

	mkdir '$(rootfs_dir).tmp/usr/local/src/puavo-os/debs'
	touch '$(rootfs_dir).tmp/usr/local/src/puavo-os/debs/Packages'

	echo 'deb [trusted=yes] file:///usr/local/src/puavo-os/debs /' \
		>'$(rootfs_dir).tmp/etc/apt/sources.list.d/puavo-os.list'

	mkdir '$(rootfs_dir).tmp/puavo-os'

	mv '$(rootfs_dir).tmp' '$(rootfs_dir)'

.PHONY: release
release:
	@parts/devscripts/bin/git-update-debian-changelog

.PHONY: rootfs-update
rootfs-update:
	GIT_DIR='$(rootfs_dir)/usr/local/src/puavo-os/.git' git fetch origin
	GIT_DIR='$(rootfs_dir)/usr/local/src/puavo-os/.git' git reset --hard origin/HEAD

	systemd-nspawn -D '$(rootfs_dir)' 'make -C /usr/local/src/puavo-os/Makefile update'

.PHONY: update
update: /puavo-os
	apt-get update

	apt-get install -V -y				\
		-o Dpkg::Options::="--force-confdef"	\
		-o Dpkg::Options::="--force-confold"	\
		devscripts equivs git

	apt-get dist-upgrade -V -y			\
		-o Dpkg::Options::="--force-confdef"	\
		-o Dpkg::Options::="--force-confold"	\

debs/Packages: deb-pkg-build
	apt-ftparchive --db debs/db packages debs >$@

debs/Packages.gz: debs/Packages
	gzip -f -k $<

.PHONY: deb-pkg-build
deb-pkg-build: .deb-pkg-build-parts .deb-pkg-build-ports

.PHONY: .deb-pkg-build-parts
.deb-pkg-build-parts: release
	dpkg-buildpackage -b -uc && parts/devscripts/bin/cp-changes debs

.PHONY: .deb-pkg-build-ports
.deb-pkg-build-ports:
	$(MAKE) -C ports deb-pkg-build

.PHONY: deb-pkg-update-repo
deb-pkg-update-repo: debs/Packages.gz
