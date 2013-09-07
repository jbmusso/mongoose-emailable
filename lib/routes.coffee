module.exports = (app, options) ->
  if not options.model?
    throw "You must provide a Mongoose model"

  model = options.model
  path = options.confirm.path or "/account/email/confirm"
  template = options.confirm.template
  middlewares = options.middlewares or []


  app.get(path, middlewares, (req, res, next) ->
    res.format(
      json: ->
        res.status(406) # Not Acceptable
        res.json(options.confirm.messages.json)
      html: ->
        model.confirmEmailAddress(req.query, (err, user) ->
          # Set http response status according to confirmation attempt result
          if err
            res.status(500)
            err = options.confirm.messages.error500

          if not user
            res.status(403) # Forbidden
            err = options.confirm.messages.invalidCombination
          else if user.email.confirmed
            res.status(403) # Forbidden
            err = options.confirm.messages.alreadyConfirmed(user)

          # Send response
          if template?
            locals =
              err: err
              user: user

            if options.httpReqFields?
              for key, value of options.httpReqFields
                locals[value] = req[key]

            return res.render(template, locals)

          if err
            return res.send(err)

          return res.send(result)
        )
    )
  )
