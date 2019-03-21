class firefox {
  include ::packages

  # Firefox configuration system is still a mess... if there really is a more
  # straightforward way, I would like to hear about it.
  file {
    '/etc/apt/preferences.d/70-firefox.pref':
      before  => Package['firefox-esr'],
      content => template('firefox/70-firefox.pref');

    '/etc/firefox-esr/puavodesktop.js':
      content => template('firefox/puavodesktop.js'),
      require => Package['firefox-esr'];

    '/etc/firefox-esr/syspref.js':
      content => template('firefox/syspref.js'),
      require => File['/usr/lib/firefox-esr/firefox-puavodesktop.js'];

    '/etc/X11/Xsession.d/48puavo-set-apiserver-envvar':
      content => template('firefox/48puavo-set-apiserver-envvar');

    '/usr/lib/firefox-esr/firefox-puavodesktop.js':
      content => template('firefox/firefox-puavodesktop.js'),
      require => File['/etc/firefox-esr/puavodesktop.js'];

    '/etc/puavo-external-files-actions.d/firefox':
      content => template('firefox/puavo-external-files-actions.d/firefox'),
      mode    => '0755',
      require => Package['puavo-ltsp-client'];
  }

  Package <| title == "firefox-esr"
          or title == puavo-ltsp-client |>
}
