# XXX re-enable our mirror once it has i386-arch for Debian Jessie/Stretch
# debootstrap_mirror	:= http://mirror.opinsys.fi/debian/
image_class		:= opinsys
images_urlbase		:= https://images.opinsys.fi
rootfs_dir		:= /virtualtmp/opinsys-os/rootfs
upload_dir              := /srv/aptirepo/puavo-os
upload_login            := aptirepo-http
upload_server           := archive-internal.opinsys.fi
