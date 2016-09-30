class kernels {
  include kernels::dkms,
          kernels::grub_update
  require packages

  define kernel_link ($kernel, $linkname, $linksuffix) {
    file {
      "/boot/${linkname}${linksuffix}":
        ensure  => link,
        require => Packages::Kernels::Kernel_package[$kernel],
        target  => "${linkname}-${kernel}";
    }

    Packages::Kernels::Kernel_package <| title == $kernel |>
  }

  define all_kernel_links ($kernel='') {
    $subname = $title

    $linksuffix = $subname ? { 'default' => '', default => "-$subname", }

    ::kernels::kernel_link {
      "initrd.img-${kernel}-${subname}":
        kernel => $kernel, linkname => 'initrd.img', linksuffix => $linksuffix;

      "vmlinuz-${kernel}-${subname}":
        kernel => $kernel, linkname => 'vmlinuz', linksuffix => $linksuffix;
    }
  }

  $default_kernel = $lsbdistcodename ? {
    'jessie'  => '3.16.0-4-amd64',
    'stretch' => '4.7.0-1-amd64',
  }

  $edge_kernel = $lsbdistcodename ? {
    'jessie' => '4.7.0-0.bpo.1-amd64',
    default  => $default_kernel,
  }

  ::kernels::all_kernel_links {
    'default': kernel => $default_kernel;
    'edge':    kernel => $edge_kernel;
  }
}
