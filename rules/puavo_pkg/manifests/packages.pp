class puavo_pkg::packages {
  include ::puavo_pkg
  include ::puavo_pkg::ekapeli

  # NOTE! adobe-flashplugin and adobe-pepperflashplugin contain both
  # 32-bit and 64-bit versions
  # ("adobe-flashplugin" vs "adobe-flashplugin-32bit",
  # and "adobe-pepperflashplugin" vs. "adobe-pepperflashplugin-32bit").
  # The 32-bit and 64-bit versions can NOT currently co-exist in the same
  # system (silently problems will ensue), so pick the required ones here.
  $available_packages = [ 'adobe-flashplugin-32bit'     # for 32-bit Firefox
			, 'adobe-pepperflashplugin'     # for 64-bit Chromium
			, 'adobe-reader'
			, 'appinventor'
			, 'bluegriffon'
			, 'cmaptools'
			, 'cnijfilter2'
			, 'dropbox'
			, 'ekapeli-alku'
			, 'enchanting'
			, 'geogebra'
			, 'geogebra6'
			, 'globilab'
			, 'google-chrome'
			, 'google-earth'
			, 'marvinsketch'
			, 'mattermost-desktop'
			, 'msttcorefonts'
			, 'obsidian-icons'
			, 'oracle-java'
			, 'processing'
			, 'pycharm'
			, 'robboscratch2'
			, 'skype'
			, 'smartboard'
			, 'spotify-client'
			, 'teddybear'
			, 'tilitin'
			, 'ti-nspire-cx-cas-ss'
			, 't-lasku'
			, 'vidyo-client'
			, 'vmware-horizon-client'
			, 'vstloggerpro' ]

  @puavo_pkg::install { $available_packages: ; }
}
