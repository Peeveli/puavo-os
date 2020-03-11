class puavo_pkg::packages {
  include ::puavo_pkg
  include ::trusty_libs

  # NOTE! adobe-flashplugin and adobe-pepperflashplugin contain both
  # 32-bit and 64-bit versions
  # ("adobe-flashplugin" vs "adobe-flashplugin-32bit",
  # and "adobe-pepperflashplugin" vs. "adobe-pepperflashplugin-32bit").
  # The 32-bit and 64-bit versions can NOT currently co-exist in the same
  # system (silently problems will ensue), so pick the required ones here.
  $available_packages = [ 'abitti-naksu'
                        , 'adobe-flashplugin'           # for 64-bit Firefox
			, 'adobe-pepperflashplugin'     # for 64-bit Chromium
			, 'adobe-reader'
			, 'airtame'
			, 'appinventor'
			, 'arduino-ide'
			, 'arduino-radiohead'
			, 'arduino-tm1637'
			, 'bluegriffon'
			, 'celestia'
			, 'cmaptools'
			, 'cnijfilter2'
			, 'cura-appimage'
			, 'dropbox'
			, 'eclipse'
			, 'ekapeli-alku'
			, 'enchanting'
			, 'extra-xkb-symbols'
			, 'firefox'
			, 'flashforge-flashprint'
			, 'geogebra'
			, 'geogebra6'
			, 'globilab'
			, 'google-chrome'
			, 'google-earth'
			, 'idid'
			, 'kojo'
			, 'launcherone'
			, 'mafynetti'
			, 'marvinsketch'
			, 'mattermost-desktop'
			, 'msttcorefonts'
			, 'netbeans'
			, 'nightcode'
			, 'ohjelmointi-opetuksessa'
			, 'openscad-nightly'
			, 'processing'
			, 'pycharm'
			, 'robboscratch2'
			, 'robotmeshconnect'
			, 'scratux'
			, 'shotcut'
			, 'skype'
			, 'smartboard'
			, 'spotify-client'
			, 'tilitin'
			, 't-lasku'
			, 'ubuntu-wallpapers'
			, 'unityhub-appimage'
			, 'veracrypt'
			, 'vidyo-client'
			, 'zoom' ]

  # Not all puavo-pkg packages have been tested with all distribution
  # release versions, so keep track of which packages are intended for
  # which versions (all others should be compatible with all supported
  # versions).
  $stretch_specific_packages = [ 'aseba'
                               , 'musescore-appimage'
                               , 'obsidian-icons' ]
  $buster_specific_packages  = [ 'celestia'
                               , 'eclipse'
                               , 'netbeans'
                               , 'ubuntu-wallpapers' ]
  case $debianversioncodename {
    'stretch': { $available_packages += $stretch_specific_packages }
    'buster':  { $available_packages += $buster_specific_packages  }
  }

  @puavo_pkg::install { $available_packages: ; }

  # "arduino-tm1637", "arduino-radiohead" and "ohjelmointi-opetuksessa"
  # require "arduino-ide" to be installed first.
  Puavo_pkg::Install['arduino-ide'] {
    before +> [ Puavo_pkg::Install['arduino-radiohead']
              , Puavo_pkg::Install['arduino-tm1637']
              , Puavo_pkg::Install['ohjelmointi-opetuksessa'] ],
  }
}
