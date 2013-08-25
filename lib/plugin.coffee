crypto = require("crypto")

nodemailer = require("nodemailer")
validate = require("mongoose-validator").validate


module.exports = (schema, options) ->
  # Validating options
  if not options.confirmRoute?
    throw "You must supply a confirmation route"

  options.subject = options.subject or "Confirm your account registration"

  transport = nodemailer.createTransport("SES",
    options.amazonSES
  )


  schema.add(
    email:
      address:
        type: String
        trim: true
        required: true
        unique: true
        validate: [validate("isEmail")]
      confirmed:
        type: Boolean
        default: false
      token:
        type: String
  )


  schema.pre("save", (next) ->
    if @isModified("email")
      @_emailWasUpdated = true
      @email.confirmed = false
      @email.token = crypto.randomBytes(48).toString("hex")
    next()
  )


  schema.post("save", ->
    if @_emailWasUpdated
      @sendConfirmationEmail()
  )


  schema.method("sendConfirmationEmail", (callback) ->
    if not options.html?
      confirmLink = "#{options.confirmRoute}?address=#{@email.address}&token=#{@email.token}"

      html = "Thanks for <b>registering</b> an account <p><a href=\"#{confirmLink}\">Confirm your email address now</a></p> <p>or copy/paste this link in your browser:</p>    <p>#{confirmLink}</p>"
    else
      html = options.html.call(this, options)

    message =
      from: options.from
      to: "<#{@email.address}>"
      subject: options.subject
      text: "Thanks for registering an account!"
      html: html

    transport.sendMail(message, (err, responseStatus) ->
      if callback
        callback(err, responseStatus)
    )
  )


  schema.method("sendEmail", (message, callback) ->
    if @email.confirmed
      transport.sendMail(message, (err, responseStatus) ->
        return callback(err, responseStatus)
      )
    else
      return callback("Could not send email: #{@email.address} address is not confirmed")
  )


  schema.static("confirmEmailAddress", (data, callback) ->
    query =
      "email.address": data.address
      "email.token": data.token
    
    @findOneAndUpdate(query, {"email.confirmed": true}, {"new": false}, (err, user) ->
      if err
        return callback(err)

      if not user
        return callback(null, null)

      return callback(null, user)
    )
  )
