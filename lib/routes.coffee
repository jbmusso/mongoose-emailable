module.exports =
  use: (app, options) ->
    if not options.model?
      throw "You must provide a Mongoose model"

    model = options.model
    path = options.path or "/account/email/confirm"
    template = options.template
    middlewares = options.middlewares or []


    app.get(path, middlewares, (req, res, next) ->
      res.format(
        json: ->
          res.status(406) # Not Acceptable
          res.json("Cannot confirm email address with JSON GET.")
        html: ->
          model.confirmEmailAddress(req.query, (err, user) ->
            # Set http response status according to confirmation attempt result
            if err
              res.status(500)
              err = "An error occured on our side while validating this email address. Please, try refreshing this page or try again later!"
  
            if not user
              res.status(403) # Forbidden
              err = "Invalid email/token combination"
            else if user.email.confirmed
              res.status(403) # Forbidden
              err = "#{user.email.address} has already been confirmed"

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
