
nodejs = window.nodejs

{user, config, initialFaves, menu, logger} = nodejs

window.onerror = (message, file, line, column, errorObj) ->
    logger.emit(
        msg: "unhandled exception"
        capturedFrom: "window.onerror"
        error:
            message: message
            file: file
            line: line
    )


$ = require "./vendor/jquery.shim"
Backbone = require "backbone"
Backbone.$ = $
Q = require "q"

Application = require "./Application.coffee"
MenuLayout = require "./views/MenuLayout.coffee"
AllItems = require "./models/AllItems.coffee"
MenuModel = require "./models/MenuModel.coffee"



user = new Backbone.Model user
allItems = new AllItems
menuModel = new MenuModel menu, allItems

# Get the initial click counts for all items
# (this replaces the localStorage)
for i in [0..allItems.length-1] by 1
    j = allItems.at(i)
    id = j.get("id")

    if clicks = initialFaves[id]
        console.log "main.coffee: have initial clicks (#{clicks}) for id '#{id}'"
        j.set("clicks", parseInt(clicks, 10))

layout = new MenuLayout
    user: user
    feeds: nodejs.feeds
    config: config
    initialMenu: menuModel
    allItems: allItems


# Convert selected menu item models to CMD Events
# https://github.com/opinsys/webmenu/blob/master/docs/menujson.md
hideTimer = null
layout.on "open-app", (model) ->
    nodejs.open(model)

    # Hide window after animation as played for few seconds or when the
    # opening app steals focus
    hideTimer = setTimeout ->
        nodejs.hideWindow()
    , Application.animationDuration

# just a wrapper, see native.coffee for the real function
layout.on "resetClicks", (model) ->
    nodejs.resetClicks(model)

$(window).keydown (e) ->
    if e.which is 27 # Esc
        nodejs.hideWindow()

# Hide window when focus is lost
$(window).blur ->
    # Clear hideTimer on blur to avoid unwanted hiding if user immediately
    # spawns menu again
    clearTimeout(hideTimer)
    nodejs.hideWindow()
    layout.broadcast("hide-window")

layout.render()
$ -> $("body").html layout.el

nodejs.on "open-view", (viewName) ->
    layout.broadcast("reset")
    if viewName
        layout.broadcast("open-#{ viewName }-view")

layout.on "logout-action", (actionView) ->
    # Send possible feedback before logging out
    actionView.model.send().finally ->
        layout.broadcast("reset") # required when devtools is active
        nodejs.hideWindow()
        nodejs.executeAction(actionView.action)

layout.on "lock-screen", () ->
    nodejs.executeAction("lock")

nodejs.logReady()
