class packages {
  require ::apt::multiarch
  include ::packages::abitti
  include ::packages::backports
  include ::packages::compat_32bit
  include ::packages::distribution_tweaks
  include ::packages::pinned
  include ::packages::purged

  # install packages by default
  Package { ensure => present, }

  #
  # Puavo OS packages
  #

  @package {
    'puavo-ltsp-bootserver':
      ensure => present,
      tag    => [ 'tag_puavo_bootserver' ];
  }

  @package {
    [ 'fluent-plugin-puavo'
    , 'iivari-client'
    , 'opinsys-ca-certificates'
    , 'puavo-autopilot'
    , 'puavo-bigtouch-shutdown'
    , 'puavo-blackboard'
    , 'puavo-client'
    , 'puavo-conf'
    , 'puavo-core'
    , 'puavo-devscripts'
    , 'puavo-hw-log'
    , 'puavo-hw-tools'
    , 'puavo-ltsp-client'
    , 'puavo-ltsp-install'
    , 'puavo-pkg'
    , 'puavo-sharedir-client'
    , 'puavo-vpn-client'
    , 'puavo-wlanap'
    , 'puavo-wlanmapper'
    , 'puavomenu'
    , 'ruby-puavowlan'
    , 'webkiosk-language-selector'
    , 'webmenu' ]:
      ensure => present,
      tag    => [ 'tag_puavo' ];
  }

  #
  # packages from the Debian repositories
  #

  @package {
    [ 'bind9'
    , 'bind9utils'
    , 'dnsmasq'
    , 'incron'
    , 'isc-dhcp-server'
    , 'krb5-kdc'
    , 'logrotate'
    , 'mdadm'
    , 'monitoring-plugins'
    , 'munin'
    , 'munin-node'
    , 'nagios-nrpe-server'
    , 'nginx'
    , 'openbsd-inetd'
    , 'python-numpy'
    , 'python-redis'
    , 'pxelinux'
    , 'ruby-ipaddress'
    , 'samba'
    , 'shorewall'
    , 'slapd'
    , 'syslinux-common'
    , 'winbind' ]:
      tag => [ 'tag_basic', 'tag_debian_bootserver', ];
  }

  @package {
    [ 'acpitool'
    , 'arandr'
    , 'clusterssh'
    , 'console-setup'
    , 'dconf-tools'
    , 'elinks'
    , 'ethtool'
    , 'expect'
    , 'fping'
    , 'gawk'
    , 'git'
    , 'htop'
    , 'iftop'
    , 'inetutils-traceroute'
    , 'initramfs-tools'
    , 'initramfs-tools-core'
    , 'inotify-tools'
    , 'iperf'
    , 'libstdc++5'
    , 'lm-sensors'
    , 'lshw'
    , 'lsof'
    , 'ltrace'
    , 'lynx'
    , 'm4'
    , 'mlocate'
    , 'moreutils'
    , 'nmap'
    , 'powertop'
    , 'procps'
    , 'pssh'
    , 'pv'
    , 'pwgen'
    , 'pwman3'
    , 'read-edid'
    , 'rsyslog'
    , 'screen'
    , 'setserial'
    , 'smartmontools'
    , 'sshfs'
    , 'strace'
    , 'sudo'
    , 'sysfsutils'
    , 'sysstat'
    , 'telnet'
    , 'terminator'
    , 'tmux'
    , 'tshark'
    , 'vinagre'
    , 'vrms'
    , 'w3m'
    , 'wakeonlan'
    , 'whois'
    , 'x11vnc'
    , 'xbacklight'
    , 'xinput-calibrator' ]:
      tag => [ 'tag_admin', 'tag_debian_desktop', ];

    [ 'libasound2-plugins'
    , 'mumble'
    , 'pavucontrol'
    , 'pavumeter'
    , 'pulseaudio-esound-compat'
    , 'qstopmotion'
    , 'simplescreenrecorder'
    , 'timidity' ]:
      tag => [ 'tag_audio', 'tag_debian_desktop', ];

    [ 'bash'
    , 'bash-completion'
    , 'bridge-utils'
    , 'gdebi-core'
    , 'grub-pc'
    , 'libpam-modules'
    , 'lvm2'
    , 'nfs-common'
    , 'openssh-client'
    , 'openssh-server'
    , 'pm-utils'
    , 'rng-tools'
    , 'systemd'
    , 'udev'
    , 'vlan' ]:
      tag => [ 'tag_basic', 'tag_debian_desktop', ];

    [ 'debootstrap'
    , 'squashfs-tools'
    , 'systemd-container' ]:
      tag => [ 'tag_builder', 'tag_debian_desktop', ];

    [ 'gdm3'
    , 'network-manager-openvpn-gnome'
    , 'network-manager-vpnc-gnome'
    , 'notify-osd'
    , 'onboard'
    , 'onboard-data'
    , 'python-appindicator'
    , 'python-gtk2'
    , 'python-notify'
    , 'shared-mime-info' ]:
      tag => [ 'tag_desktop', 'tag_debian_desktop', ];

    [ 'acct'
    , 'ack-grep'
    , 'build-essential'
    , 'bvi'
    , 'cdbs'
    , 'debconf-doc'
    , 'devscripts'
    , 'dh-make'
    , 'dpkg-dev'
    , 'dput'
    , 'fakeroot'
    , 'gdb'
    , 'gettext'
    , 'gnupg'
    , 'manpages-dev'
    , 'perl-doc'
    , 'pinfo'
    , 'sloccount'
    , 'translate-toolkit'
    , 'vim-nox' ]:
      tag => [ 'tag_devel', 'tag_debian_desktop', ];

    [ 'dkms'
    , 'glx-alternative-mesa'
    , 'libgl1-mesa-glx'
    , 'nvidia-settings'
    # , 'r8168-dkms'		# XXX missing from Debian
    , 'update-glx'
    , 'xserver-xorg-input-evdev'
    , 'xserver-xorg-video-all' ]:
      tag => [ 'tag_drivers', 'tag_debian_desktop', ];

    [ 'mutt' ]:
      tag => [ 'tag_email', 'tag_debian_desktop', ];

    [ 'virtualbox'
    , 'virtualbox-dkms'
    , 'wine'
    , 'wine32'
    , 'wine64'
    , 'winetricks' ]:
      tag => [ 'tag_emulation', 'tag_debian_desktop', ];

    'firmware-linux-free':
      tag => [ 'tag_firmware', 'tag_debian_desktop', ];

    [ 'fontconfig'
    , 'gnome-font-viewer'
    , 'ttf-freefont'
    , 'xfonts-terminus'
    , 'xfonts-utils' ]:
      tag => [ 'tag_fonts', 'tag_debian_desktop', ];

    [ 'aisleriot'
    , 'dosbox'
    , 'extremetuxracer'
    , 'freeciv-client-gtk'
    , 'gcompris'
    , 'gcompris-sound-en'
    , 'gcompris-sound-de'
    , 'gcompris-sound-fi'
    , 'gcompris-sound-sv'
    , 'gnome-games'
    , 'gnubg'
    , 'gnuchess'
    , 'khangman'
    , 'ktouch'
    , 'kwordquiz'
    , 'laby'
    , 'luola'
    , 'neverball'
    , 'neverputt'
    , 'openttd'
    , 'qml-module-qtmultimedia'		# required by khangman
    , 'supertuxkart'
    , 'tuxmath'
    , 'tuxpaint'
    , 'tuxpaint-stamps-default'
    , 'xmoto' ]:
      tag => [ 'tag_games', 'tag_debian_desktop', ];

    [ 'dbus-x11'
    , 'gnome-applets'
    , 'gnome-power-manager'
    , 'gnome-user-guide'
    , 'libgnome2-perl'
    , 'libgnomevfs2-bin'
    , 'libgnomevfs2-extra'
    , 'notification-daemon' ]:
      tag => [ 'tag_gnome', 'tag_debian_desktop', ];

    [ 'blender'
    , 'breeze-icon-theme'	# wanted (not required) by kdenlive
    , 'dia'
    , 'dvgrab'
    , 'fotowall'
    , 'freecad'
    , 'gimp'
    , 'gimp-data-extras'
    , 'gimp-gap'
    , 'gimp-plugin-registry'
    , 'gimp-ufraw'
    , 'gthumb'
    , 'inkscape'
    , 'kdenlive'
    , 'kino'
    , 'kolourpaint4'
    , 'krita'
    , 'libav-tools'
    , 'libsane'
    , 'libsane-extras'
    # , 'luciole'		# XXX missing from Debian
    , 'mjpegtools'
    , 'mypaint'
    , 'nautilus-image-converter'
    , 'okular'
    , 'openshot'
    , 'pencil2d'
    # , 'photofilmstrip'	# XXX missing from Debian
    , 'pinta'
    , 'pitivi'
    , 'python-lxml'
    , 'sane-utils'
    , 'xsane' ]:
      tag => [ 'tag_graphics', 'tag_debian_desktop', ];

    # XXX some issue on Debian
    # [ 'kdump-tools' ]:
    #   tag => [ 'tag_kernelutils', 'tag_debian_desktop', ];

    [ 'irssi'
    , 'irssi-plugin-xmpp'
    , 'pidgin'
    , 'pidgin-libnotify'
    , 'pidgin-plugin-pack' ]:
      tag => [ 'tag_instant_messaging', 'tag_debian_desktop', ];

    # XXX enable if issues are fixed
    # [ 'laptop-mode-tools' ]:
    #   tag => [ 'tag_laptop', 'tag_debian_desktop', ];

    # , 'clam-chordata'		# XXX missing from Debian Jessie
    [ 'goobox'
    , 'gstreamer1.0-clutter'
    , 'gstreamer1.0-libav'
    , 'gstreamer1.0-plugins-bad'
    , 'gstreamer1.0-plugins-base'
    , 'gstreamer1.0-plugins-good'
    , 'gstreamer1.0-plugins-ugly'
    , 'gstreamer1.0-tools'
    , 'gtk-recordmydesktop'
    , 'kaffeine'
    , 'libdvd-pkg'
    , 'libdvdread4'
    , 'ogmrip'
    , 'vlc'
    , 'winff'
    , 'x264' ]:
      tag => [ 'tag_mediaplayer', 'tag_debian_desktop', ];

    [ 'audacity'
    , 'denemo'
    , 'fmit'
    , 'hydrogen'
    , 'lmms'
    , 'musescore'
    , 'musescore-soundfont-gm'
    , 'qsynth'
    , 'rosegarden'
    , 'solfege'
    , 'soundconverter'
    , 'tuxguitar'
    , 'tuxguitar-jsa' ]:
      tag => [ 'tag_music_making', 'tag_debian_desktop', ];

    [ 'amtterm'
    , 'hostapd'
    , 'vtun' ]:
      tag => [ 'tag_network', 'tag_debian_desktop', ];

    [ 'calibre'
    , 'gummi'
    , 'icedove'
    , 'libreoffice'
    , 'libreoffice-base'
    , 'scribus'
    , 'tellico'
    , 'vym' ]:
      tag => [ 'tag_office', 'tag_debian_desktop', ];

    [ 'eject'
    , 'sound-juicer' ]:
      tag => [ 'tag_optical_media', 'tag_debian_desktop', ];

    [ 'cups-browsed'
    , 'cups-daemon'
    , 'cups-pk-helper'
    , 'gtklp' ]:
      tag => [ 'tag_printing', 'tag_debian_desktop', ];

    [ 'avr-libc'
    # XXX 'basic256'		# XXX missing from Debian Jessie
    , 'eclipse'
    , 'emacs24'
    , 'eric'
    , 'eric-api-files'
    , 'fritzing'
    , 'gcc-avr'
    , 'geany'
    , 'idle'
    , 'idle-python2.7'
    , 'idle-python3.5'
    , 'kturtle'
    , 'lokalize'
    , 'meld'
    , 'pyqt4-dev-tools'
    , 'python-doc'
    , 'python-jsonpickle' # a dependency for
                          # http://meetedison.com/robot-programming-software/
    , 'python-pygame'
    , 'pythontracer'
    , 'qt4-designer'
    , 'qt4-doc'
    , 'racket'
    , 'renpy'
    , 'scite'
    , 'scratch'
    , 'sonic-pi'
    , 'spe' ]:
      tag => [ 'tag_programming', 'tag_debian_desktop', ];

    [ 'gftp'
    , 'lftp'
    , 'remmina'
    , 'smbclient'
    , 'wget'
    , 'xtightvncviewer']:
      tag => [ 'tag_remote_access', 'tag_debian_desktop', ];

    [ 'avogadro'
    , 'celestia'
    , 'celestia-gnome'
    # , 'drgeo'		# XXX missing from Debian
    # , 'ghemical'	# XXX missing from Debian
    , 'gnucap'
    , 'gnuplot'
    , 'gnuplot-x11'
    , 'kalzium'
    , 'kbruch'
    , 'kgeography'
    , 'kmplot'
    , 'kstars'
    , 'mandelbulber'
    , 'marble-qt'
    , 'qgis'
    , 'stellarium'
    , 'step'
    , 'texlive-fonts-extra'
    , 'texlive-fonts-recommended'
    , 'texlive-latex-extra'
    , 'texlive-latex-recommended'
    , 'wxmaxima' ]:
      tag => [ 'tag_science', 'tag_debian_desktop', ];

    # 'breathe-icon-theme'		# XXX missing from Debian
    [ 'gnome-icon-theme'
    , 'gnome-themes-extras'
    , 'gtk2-engines'
    , 'gtk2-engines-pixbuf'
    # , 'human-theme'			# XXX missing from Debian
    # , 'light-themes'			# XXX missing from Debian
    , 'openclipart'
    , 'oxygen-icon-theme'
    , 'xscreensaver-data'
    , 'xscreensaver-data-extra' ]:
      tag => [ 'tag_themes', 'tag_debian_desktop', ];

    # the dependencies (and recommends) of ubuntu-gnome-desktop package
    # without a few packages that we do not want
    [ 'acpi-support'
    , 'alsa-base'
    , 'alsa-utils'
    , 'anacron'
    , 'at-spi2-core'
    , 'avahi-autoipd'
    , 'avahi-daemon'
    , 'baobab'
    , 'bc'
    , 'bluez'
    , 'bluez-cups'
    , 'brasero'
    , 'ca-certificates'
    , 'cheese'
    , 'cups'
    , 'cups-bsd'
    , 'cups-client'
    , 'cups-filters'
    , 'dconf-editor'
    # , 'deja-dup'				# not needed
    # , 'deja-dup-backend-cloudfiles'
    # , 'deja-dup-backend-gvfs'
    # , 'deja-dup-backend-s3'
    , 'empathy'
    , 'eog'
    , 'evince'
    , 'evolution'
    , 'file-roller'
    , 'fonts-cantarell'
    , 'fonts-dejavu-core'
    , 'fonts-freefont-ttf'
    , 'foomatic-db-compressed-ppds'
    , 'gcc'
    , 'gcr'
    , 'gedit'
    , 'genisoimage'
    , 'ghostscript-x'
    , 'gjs'
    , 'gnome-accessibility-themes'
    , 'gnome-backgrounds'
    , 'gnome-bluetooth'
    , 'gnome-calculator'
    , 'gnome-color-manager'
    , 'gnome-clocks'
    , 'gnome-contacts'
    , 'gnome-control-center'
    , 'gnome-disk-utility'
    # , 'gnome-documents'	# forces tracker to be installed
				# (tracker is purged elsewhere)
    , 'gnome-icon-theme-extras'
    , 'gnome-icon-theme-symbolic'
    , 'gnome-keyring'
    , 'gnome-menus'
    , 'gnome-online-accounts'
    , 'gnome-screenshot'
    , 'gnome-session'
    , 'gnome-settings-daemon'
    , 'gnome-shell'
    , 'gnome-shell-extensions'
    , 'gnome-sushi'
    , 'gnome-system-log'
    , 'gnome-system-monitor'
    , 'gnome-terminal'
    , 'gnome-themes-standard'
    , 'gnome-tweak-tool'
    , 'gnome-user-share'
    , 'gnome-video-effects'
    , 'gsettings-desktop-schemas'
    , 'gstreamer1.0-alsa'
    , 'gstreamer1.0-pulseaudio'
    , 'gucharmap'
    , 'gvfs-bin'
    , 'gvfs-fuse'
    , 'hplip'
    , 'i3'
    , 'ibus'
    , 'ibus-anthy'
    , 'ibus-gtk3'
    , 'ibus-pinyin'
    , 'ibus-table'
    , 'inputattach'
    , 'itstool'
    , 'laptop-detect'
    , 'libatk-adaptor'
    , 'libgail-common'
    , 'libnotify-bin'
    , 'libnss-extrausers'
    , 'libnss-mdns'
    , 'libnss-myhostname'
    , 'libpam-gnome-keyring'
    , 'libpam-systemd'
    , 'libproxy1-plugin-gsettings'
    , 'libproxy1-plugin-networkmanager'
    , 'libreoffice-calc'
    , 'libreoffice-gnome'
    , 'libreoffice-impress'
    , 'libreoffice-math'
    , 'libreoffice-ogltrans'
    , 'libreoffice-pdfimport'
    , 'libreoffice-style-tango'
    , 'libreoffice-writer'
    , 'libsasl2-modules'
    , 'make'
    , 'memtest86+'
    , 'mousetweaks'
    , 'mutter'
    , 'nautilus'
    , 'nautilus-sendto'
    # , 'nautilus-share' # forces software-properties-gtk to be installed
    , 'network-manager'
    , 'network-manager-pptp'
    , 'network-manager-pptp-gnome'
    , 'nodm'            # for infotv
    , 'openbox'         # for infotv
    , 'openprinting-ppds'
    , 'pcmciautils'
    , 'plymouth'
    , 'plymouth-themes'
    , 'printer-driver-c2esp'
    , 'printer-driver-foo2zjs'
    , 'printer-driver-min12xxw'
    , 'printer-driver-pnm2ppa'
    , 'printer-driver-ptouch'
    , 'printer-driver-pxljr'
    , 'printer-driver-sag-gdi'
    , 'printer-driver-splix'
    , 'pulseaudio'
    , 'pulseaudio-module-bluetooth'
    , 'rfkill'
    , 'rtmpdump'
    , 'rxvt-unicode'
    , 'seahorse'
    , 'shotwell'
    , 'simple-scan'
    # , 'software-properties-gtk'		# (purged elsewhere)
    , 'speech-dispatcher'
    , 'ssh-askpass-gnome'
    , 'telepathy-idle'
    , 'totem'
    # , 'tracker'				# (purged elsewhere)
    , 'transmission-gtk'
    , 'unzip'
    # , 'update-manager'			# (purged elsewhere)
    # , 'update-notifier'			# (purged elsewhere)
    # , 'usb-creator-gtk'			# XXX missing from Debian
    , 'vino'
    , 'wireless-tools'
    , 'wpasupplicant'
    , 'xdg-user-dirs'
    , 'xdg-user-dirs-gtk'
    , 'xdg-utils'
    , 'xkb-data'
    , 'xorg'
    , 'xterm'
    , 'yelp'
    , 'yelp-tools'
    , 'yelp-xsl'
    , 'youtube-dl'
    , 'zenity'
    , 'zip' ]:
      tag => [ 'tag_ubuntu-gnome-desktop', 'tag_debian_desktop', ];

    [ 'anki'
    , 'bindfs'
    , 'blueman'
    , 'desktop-file-utils'
    , 'detox'
    , 'devilspie2'
    , 'duplicity'
    , 'exfat-fuse'
    , 'exfat-utils'
    , 'fuse'
    , 'gconf-editor'
    , 'kamerka'
    , 'pass'
    , 'password-gorilla'
    , 'system-config-printer'
    , 'tlp'
    , 'unace'
    , 'unionfs-fuse' ]: # Ekapeli might need this.
      tag => [ 'tag_utils', 'tag_debian_desktop', ];

    [ 'qemu-kvm' ]:
      tag => [ 'tag_virtualization', 'tag_debian_desktop', ];

    [ 'bluefish'
    , 'browser-plugin-vlc'
    , 'chromium'
    , 'epiphany-browser'
    , 'liferea'
    , 'openjdk-8-jdk'
    , 'openjdk-8-jre'
    , 'php-cli'
    , 'php-sqlite3'
    , 'sqlite3' ]:
      tag => [ 'tag_web', 'tag_debian_desktop', ];
  }

  #
  # packages from the Debian backports
  #

  # These modify apt preferences so that these packages will be picked up
  # from backports instead of the usual channels.  The inclusion of a package
  # on this list does not trigger the installation of a package, that has
  # to be defined elsewhere.
  $packages_from_backports = $debianversioncodename ? {
                               'stretch' => [ 'remmina' ],
                               default   => [],
                             }

  #
  # packages from the Ubuntu repository
  #

  @package {
    [ 'firefox:i386'
    , 'firefox-locale-de:i386'
    , 'firefox-locale-en:i386'
    , 'firefox-locale-fi:i386'
    , 'firefox-locale-fr:i386'
    , 'firefox-locale-sv:i386' ]:
      tag => [ 'tag_web', 'tag_ubuntu', ];

    [ 'ttf-ubuntu-font-family' ]:
      tag => [ 'tag_fonts', 'tag_ubuntu_desktop', ];

    [ 'edubuntu-wallpapers'
    , 'ubuntu-wallpapers-lucid'
    , 'ubuntu-wallpapers-precise'
    , 'ubuntu-wallpapers-quantal'
    , 'ubuntu-wallpapers-raring'
    , 'ubuntu-wallpapers-saucy'
    , 'ubuntu-wallpapers-trusty'
    , 'ubuntu-wallpapers-utopic'
    , 'ubuntu-wallpapers-vivid'
    , 'ubuntu-wallpapers-wily'
    , 'ubuntu-wallpapers-xenial' ]:
      tag => [ 'tag_wallpapers', 'tag_ubuntu_desktop', ];
  }

  #
  # packages from the (Opinsys) puavo repository
  #

  @package {
    'autopoweroff':
      tag => [ 'tag_misc', 'tag_puavo', ];

    # [ 'fluent-plugin-puavo'   # XXX not yet packaged for Debian
    # , 'puavo-load-reporter'   # XXX not yet packaged for Debian

    # XXX not yet packaged for Debian
    # [ 'dymo-cups-drivers' ]:
    #   tag => [ 'tag_printing', 'tag_puavo', ];

    # XXX not yet packaged for Debian
    # [ 'bluegriffon'
    # , 'enchanting'
    # , 'pycharm'
    # , 'snap4arduino' ]:
    #   tag => [ 'tag_programming', 'tag_puavo', ];

    'nwjs':
      tag => [ 'tag_web', 'tag_puavo', ];

    [ 'faenza-icon-theme' ]:
      tag => [ 'tag_themes', 'tag_puavo', ];

    'openboard':
      tag => [ 'tag_whiteboard', 'tag_puavo', ];
  }

  $broadcom_sta_dkms_module = 'broadcom-sta/6.30.223.271'
  $nvidia_dkms_304_module   = 'nvidia-legacy-304xx/304.137'
  $nvidia_dkms_340_module   = 'nvidia-legacy-340xx/340.106'
  $nvidia_dkms_384_module   = 'nvidia-current/384.130'
  $virtualbox_module        = 'virtualbox/5.2.18'
  # XXX $r8168_dkms_module  = 'r8168/8.040.00'

  $all_dkms_modules = [ $broadcom_sta_dkms_module
		      , $nvidia_dkms_304_module
		      , $nvidia_dkms_340_module
		      , $nvidia_dkms_384_module
		      , $virtualbox_module ]
                      # XXX $r8168_dkms_module  # XXX missing from Debian

  packages::kernels::kernel_package {
    '3.16.0-4-amd64':
      dkms_modules => $all_dkms_modules,
      package_name => 'linux-image-3.16.0-4-amd64';

    '4.9.0-8-amd64':
      dkms_modules => $all_dkms_modules,
      package_name => 'linux-image-4.9.0-8-amd64';

    '4.17.0-0.bpo.1-amd64':
      dkms_modules => [ $virtualbox_module ],
      package_name => 'linux-image-4.17.0-0.bpo.1-amd64';
  }

  # XXX missing from Debian
  # @package {
  #   XXX missing from Debian
  #   [ 'vmware-view-client' ]:
  #     tag => [ 'tag_remote_access', 'tag_partner', 'tag_restricted' ];
  # }

  # Packages which are not restricted per se, but which are required by
  # restricted packages. These need to be installed and distributed in
  # the image to minimize the effort of installing restricted packages
  # "during runtime".
  @package {
    [ 'libnspr4-0d'    # spotify
    , 'libssl1.0.0'    # spotify
    , 'libudev0:amd64' # vmware-horizon-client
    , 'lsb-core' ]:    # google-earth
      tag => [ 'tag_debian_desktop', 'tag_required-by-restricted' ];
  }

  # various contrib/non-free stuff, firmwares and such
  @package {
    'nautilus-dropbox':
      tag => [ 'tag_desktop', 'tag_debian_desktop_nonfree', ];

    [ 'broadcom-sta-dkms'
    , 'libgl1-nvidia-glx'
    , 'libgl1-nvidia-legacy-304xx-glx'
    , 'libgl1-nvidia-legacy-340xx-glx'
    , 'nvidia-kernel-dkms'
    , 'nvidia-legacy-304xx-kernel-dkms'
    , 'nvidia-legacy-340xx-kernel-dkms'
    , 'xserver-xorg-video-nvidia'
    , 'xserver-xorg-video-nvidia-legacy-304xx'
    , 'xserver-xorg-video-nvidia-legacy-340xx' ]:
      tag => [ 'tag_drivers', 'tag_debian_desktop_nonfree', ];

    [ 'amd64-microcode'
    , 'b43-fwcutter'
    , 'firmware-amd-graphics'
    , 'firmware-atheros'
    , 'firmware-b43-installer'
    , 'firmware-b43legacy-installer'
    , 'firmware-bnx2'
    , 'firmware-bnx2x'
    , 'firmware-brcm80211'
    , 'firmware-cavium'
    , 'firmware-crystalhd'
    , 'firmware-intel-sound'
    , 'firmware-intelwimax'
    , 'firmware-ipw2x00'
    , 'firmware-ivtv'
    , 'firmware-iwlwifi'
    , 'firmware-libertas'
    , 'firmware-linux'
    , 'firmware-linux-nonfree'
    , 'firmware-misc-nonfree'
    , 'firmware-myricom'
    , 'firmware-netxen'
    , 'firmware-qlogic'
    , 'firmware-realtek'
    , 'firmware-samsung'
    , 'firmware-siano'
    , 'firmware-ti-connectivity'
    , 'firmware-zd1211'
    , 'intel-microcode'
    , 'iucode-tool' ]:
      ensure => present,
      tag    => [ 'tag_firmware', 'tag_debian_desktop_nonfree', ];

    'steam':
      tag => [ 'tag_games', 'tag_debian_desktop_nonfree', ];

    'scribus-doc':
      tag => [ 'tag_office', 'tag_debian_desktop_nonfree', ];

    'celestia-common-nonfree':
      ensure => present,
      tag    => [ 'tag_science', 'tag_debian_desktop_nonfree', ];

    'unrar':
      tag => [ 'tag_utils', 'tag_debian_nonfree', ];
  }
}
