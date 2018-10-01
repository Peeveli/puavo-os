class bootserver_wlan {
  include ::bootserver_config

  file {
    '/etc/puavo-wlangw/vtund.conf':
      content => template('bootserver_wlan/vtund.conf'),
      require => Package['puavo-wlangw'];

    '/usr/sbin/puavo-wlangw-vtun-up':
      mode    => '0755',
      content => template('bootserver_wlan/puavo-wlangw-vtun-up'),
      require => Package['puavo-wlangw'];
  }

  package {
    'puavo-wlangw':
      ensure => present;
  }
}
