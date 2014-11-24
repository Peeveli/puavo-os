class webmenu {
  include dpkg,
          packages

  dpkg::simpledivert {
    '/opt/webmenu/menu.json':
      before => File['/opt/webmenu/menu.json'];
  }

  File { require => Package['webmenu'], }
  file {
    '/etc/puavo-external-files-actions.d/webmenu':
      require => Package['puavo-ltsp-client'],
      content => template('webmenu/puavo-external-files-actions.d/webmenu'),
      mode    => 755;

    [ '/etc/webmenu'
    , '/etc/webmenu/personally-administered-device' ]:
      ensure => directory;

    '/etc/webmenu/config.json':
      content => template('webmenu/config.json');

    '/etc/webmenu/personally-administered-device/menu.json':
      content => template('webmenu/personally-administered-device-menu.json');

    '/etc/xdg/autostart/webmenu.desktop':
      content => template('webmenu/webmenu.desktop'),
      require => File['/usr/local/bin/puavo-webmenu'];

    '/opt/webmenu/menu.json':
      content => template('webmenu/menu.json');

    '/usr/local/bin/puavo-webmenu':
      content => template('webmenu/puavo-webmenu'),
      mode    => 755;
  }

  Package <| title == webmenu |>
}
