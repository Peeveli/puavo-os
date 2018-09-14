class image::opinsys {
  include ::abitti,
          ::art::kemi,
          ::art::opinsys,
          ::image::allinone,
          ::install_hp_plugins,
          ::opinsys_dput,
          ::oracle_java,
          ::primus,
          ::puavo_pkg::packages,
          ::ssh_server

  # Realize all available puavo-pkg packages
  Puavo_pkg::Install <| |>

  Package <| tag == 'tag_debian_nonfree' |>
}