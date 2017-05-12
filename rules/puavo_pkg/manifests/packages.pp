class puavo_pkg::packages {
  include ::puavo_pkg

  $available_packages = [ 'adobe-flashplugin'
			, 'adobe-pepperflashplugin'
			, 'adobe-reader'
			, 'cmaptools'
			, 'dropbox'
			, 'ekapeli-alku'
			, 'geogebra'
			, 'google-chrome'
			, 'google-earth'
			, 'msttcorefonts'
			, 'oracle-java'
			, 'skype'
			, 'smartboard'
			, 'spotify-client'
			, 't-lasku'
			, 'vstloggerpro' ]

  @puavo_pkg::install { $available_packages: ; }
}
