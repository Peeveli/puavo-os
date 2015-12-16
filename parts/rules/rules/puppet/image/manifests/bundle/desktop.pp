class image::bundle::desktop {
  include acroread,
          ::desktop,
          disable_accounts_service,
          disable_geoclue,
          # firefox,	# XXX iceweasel in Debian
          fontconfig,
          gnome_terminal,
          graphics_drivers,
          image::bundle::basic,
          kaffeine,
          keyutils,
          ktouch,
          laptop_mode_tools,
          libreoffice,
          network_manager,
          puavo_wlan,
          pycharm,
          tuxpaint,
          wacom,
          workaround_firefox_local_swf_bug
          # xexit	# XXX requires puavo-ltsp-client
}
