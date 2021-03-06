class run_once_on_desktop_session {
  include ::puavo_conf

  $source_dir = '/usr/local/share/puavo-run-once-on-desktop-session'

  ::puavo_conf::definition {
    'puavo-run-once.json':
      source => 'puppet:///modules/run_once_on_desktop_session/puavo-run-once.json';
  }

  define script ($source) {
    $scriptname = $title

    file {
      "${run_once_on_desktop_session::source_dir}/${scriptname}":
        mode   => '0755',
        source => $source;
    }
  }

  file {
    '/etc/xdg/autostart/puavo-run-once-on-desktop-session.desktop':
      source => 'puppet:///modules/run_once_on_desktop_session/puavo-run-once-on-desktop-session.desktop';

    '/usr/local/bin/puavo-run-once-on-desktop-session':
      mode   => '0755',
      source => 'puppet:///modules/run_once_on_desktop_session/puavo-run-once-on-desktop-session';

    $source_dir:
      ensure => directory;
  }
}
