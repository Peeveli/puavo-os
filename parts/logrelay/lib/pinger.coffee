
{EventEmitter} = require "events"

class Pinger extends EventEmitter

    constructor: (@tcpStream, @jsonStream, @interval, @timeout) ->
        @timeoutTimer = null
        @pingTimer = null

        @_reply = @_reply.bind(this)
        @jsonStream.on "data", @_reply

    _reply: (data) ->
        if data.type is "internal" and data.event is "pong"
            clearTimeout @timeoutTimer
            @pingTimer = setTimeout =>
                @ping()
            , @interval

    ping: ->
        @timeoutTimer = setTimeout =>
            @emit "timeout"
        , @timeout
        @send("ping")

    stop: ->
        @ping = ->
        @jsonStream.removeListener "data", @_reply
        clearTimeout @timeoutTimer
        clearTimeout @pingTimer

    send: (msg) ->
        packet = {
            type: "internal"
            event: "ping"
        }
        @tcpStream.write(JSON.stringify(packet) + "\n")

module.exports = Pinger
