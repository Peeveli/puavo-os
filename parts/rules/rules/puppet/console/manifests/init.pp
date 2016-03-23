class console {
  include packages

  file {
    '/etc/default/console-setup':
      content => template('console/console-setup.default'),
      require => Package['console-setup'];

    '/etc/init/ttyS0.conf':
      content => template('console/ttyS0.conf');

    '/usr/share/puavo-conf/parameters/puavo-rules-console.json':
      content => template('console/puavo-conf-parameters.json'),
      require => Package['puavo-conf'];
  }

  Package <| title == console-setup |>
  Package <| title == puavo-conf |>
}
