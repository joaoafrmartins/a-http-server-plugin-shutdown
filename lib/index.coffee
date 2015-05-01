merge = require 'lodash.merge'

module.exports = (next) ->

  @config.shutdown = merge require('./config'), @config?.shutdown or {}

  @app.set 'shutdown', false

  @app.use (req, res, done) =>

    if @app.settings.shutdown is true

      req.connection.setTimeout 1

    done()

  Object.defineProperty @, "shutdown", value: () =>

    @app.set "shutdown", true

    ###

    send events on process shutdown-pre-up, shutdown-pre-down and shutdown-completed

    if @sockets then @sockets?.clients()?.map (socket) =>

      @console.info "closing", "socket", socket?.id or ''

      socket.disconnect()

    ###

    @http.close () =>

      @console.info "shutdown"

      process.exit 0

    setTimeout () =>

      @console.error "forcefull shutdown"

      process.exit 1

    , @config.shutdown.timeout

  next null
