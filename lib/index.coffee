configFn = require 'a-http-server-config-fn'

module.exports = (next) ->

  configFn @config, "#{__dirname}/config"

  @app.set 'shutdown', false

  @app.use (req, res, done) =>

    if @app.settings.shutdown is true

      req.connection.setTimeout 1

    done()

  process.on "a-http-server:shutdown:attach", (plugin) =>

    @config.plugins[plugin].status = 1

  process.on "a-http-server:shutdown:dettached", (plugin) =>

    @config.plugins[plugin].status = 0

    done = !!!Object.keys(@config.plugins).reduce (sum, plugin) =>

      sum += @config.plugins[plugin].status

    , 0

    if done then process.emit "a-http-server:shutdown"

  process.on "a-http-server:shutdown:dettach", () ->

    process.emit "a-http-server:shutdown:dettached", "shutdown"

  process.on "a-http-server:shutdown", =>

    @http.close =>

      @console.info "shutdown"

      setTimeout () =>

        @console.error "forcefull shutdown"

        process.exit 1

      , @config?.plugins?.shutdown?.timeout or 120000

      process.exit 0

  Object.defineProperty @, "shutdown", value: =>

    process.emit "a-http-server:shutdown:dettach"

  process.emit "a-http-server:shutdown:attach", "shutdown"

  next null
