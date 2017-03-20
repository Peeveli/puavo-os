class gdm {
  include ::packages
  include ::puavo_conf

  exec {
    '/usr/sbin/dpkg-reconfigure gdm3':
      refreshonly => true;
  }

  file {
    '/etc/gdm3/daemon.conf':
      notify  => Exec['/usr/sbin/dpkg-reconfigure gdm3'],
      require => Package['gdm3'],
      source  => 'puppet:///modules/gdm/daemon.conf';

    '/etc/gdm3/greeter.dconf-defaults':
      notify  => Exec['/usr/sbin/dpkg-reconfigure gdm3'],
      require => [ File['/usr/share/backgrounds/puavo-art']
                 , Package['gdm3'] ],
      source  => 'puppet:///modules/gdm/greeter.dconf-defaults';

    '/usr/share/gdm/greeter/autostart/puavo-remote-assistance-applet.desktop':
      ensure  => link,
      require => [ Package['gdm3'], Package['puavo-ltsp-client'], ],
      target  => '/etc/xdg/autostart/puavo-remote-assistance-applet.desktop';
  }

  ::puavo_conf::script {
    'setup_xsessions':
      require => Package['puavo-ltsp-client'],
      source  => 'puppet:///modules/gdm/setup_xsessions';
  }

  Package <|
       title == gdm3
    or title == puavo-ltsp-client
  |>
}
