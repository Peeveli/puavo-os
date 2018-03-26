class homedir_management {
  include ::puavo_conf

  file {
    '/etc/X11/Xsession.d/49puavo-touch-homedir':
      source => 'puppet:///modules/homedir_management/49puavo-touch-homedir';

    '/etc/xdg/autostart/puavo-report-about-homedir-cleanups.desktop':
      require => File['/usr/local/bin/puavo-report-about-homedir-cleanups'],
      source  => 'puppet:///modules/homedir_management/puavo-report-about-homedir-cleanups.desktop';

    '/usr/local/bin/puavo-report-about-homedir-cleanups':
      mode   => '0755',
      source => 'puppet:///modules/homedir_management/puavo-report-about-homedir-cleanups';

    '/usr/local/sbin/puavo-cleanup-homedirs-to-ensure-free-space':
      mode    => '0755',
      require => Puavo_conf::Definition['puavo-admin-cleanup.json'],
      source  => 'puppet:///modules/homedir_management/puavo-cleanup-homedirs-to-ensure-free-space';
  }

  ::puavo_conf::definition {
    'puavo-admin-cleanup.json':
      source => 'puppet:///modules/homedir_management/puavo-admin-cleanup.json';
  }
}
