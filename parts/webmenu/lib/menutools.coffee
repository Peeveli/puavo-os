
# Inject .desktop to menu structure

path = require "path"
dotdesktop = require "./dotdesktop"

injectDesktopData = (menu, desktopDir, locale) ->

  if menu.type is "desktop" and menu.id
    filePath = desktopDir + "/#{ menu.id }.desktop"
    desktopEntry = dotdesktop.parseFileSync(filePath, locale)
    menu.name ?= desktopEntry.name
    menu.description ?= desktopEntry.description
    menu.command ?= desktopEntry.command
  else if menu.type is "menu"
    for menu_ in menu.items
      injectDesktopData(menu_, desktopDir, locale)


module.exports =
  injectDesktopData: injectDesktopData
  pickTranslations: pickTranslations
