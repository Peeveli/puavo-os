class graphics_drivers {
  require packages      # We use "require" here, because things here should be
                        # done only after all packages have been installed,
                        # because we run ldconfig and save its output for
                        # later use.

  if $architecture != 'i386' {
    fail('This class is written to work only with i386')
  }

  define driver_alternatives ($gl_conf_target) {
    $driver      = $title
    $ld_so_cache = "/etc/ld.so.cache-$driver"

    exec {
      "setup $driver alternatives":
        command => "/usr/bin/update-alternatives --set i386-linux-gnu_gl_conf \
                      $gl_conf_target \
                    && /sbin/ldconfig \
                    && /bin/cp /etc/ld.so.cache /etc/ld.so.cache-$driver",
        unless => "/usr/bin/test /etc/ld.so.cache-mesa -nt /etc/ld.so.cache";
    }
  }

  driver_alternatives {
    'fglrx':
      gl_conf_target => '/usr/lib/fglrx/ld.so.conf',
      notify         => Driver_alternatives['mesa'],
      require        => Package['fglrx'];

   'mesa':
      gl_conf_target => '/usr/lib/i386-linux-gnu/mesa/ld.so.conf',
      require        => [ Driver_alternatives['fglrx'],
                          Driver_alternatives['nvidia'],
                          Package['libgl1-mesa-glx'], ];

   'nvidia':
      gl_conf_target => '/usr/lib/nvidia-current/ld.so.conf',
      notify         => Driver_alternatives['mesa'],
      require        => [ Package['nvidia-current'],
			  Package['nvidia-settings'], ];
  }

  Package <| title == fglrx
          or title == libgl1-mesa-glx
          or title == nvidia-current
          or title == nvidia-settings |>
}
