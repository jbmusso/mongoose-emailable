plugin = require("./lib/plugin")


module.exports =
  routes: (app, options) ->
    require("./lib/routes")(app, options)

  plugin: plugin
