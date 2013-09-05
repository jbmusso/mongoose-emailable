mongoose-emailable
==================

Mongoose plugin for email address confirmation and express route: automatically sends an email with a "click to confirm address" link to a just-registered user, or to a user that changes its email address.

Clicking the link will flag the email address as "confirmed", thus allowing mails to be sent to this address. No other mails beside the "confirm your address" will be sent to an unconfirmed address.

This module internally uses [nodemailer](https://github.com/andris9/Nodemailer) module with Amazon SES transport.


## Installation

    npm install mongoose-emailable
    
## Usage

Setting up mongoose-emailable is pretty straightfoward:

1. attach plugin to the Mongoose model of your choice (typically, a User-like model)
2. add route to your express application

### Configure mongoose model

```coffeescript
# User model file...
mongoose = require("mongoose")
emailablePlugin = require("mongoose-emailable").plugin

UserSchema = new mongoose.Schema(
  name:
    type: String
    required: true
)

UserSchema.plugin(emailablePlugin,
  from: "Example.com <no-reply@example.com>" # Any email address you own
  confirmRoute: "https://example.com/account/email/confirm" # Query string will be automatically added
  amazonSES:
    AWSAccessKeyID: "..."
    AWSSecretKey: "..."
)
```


### Configure express app

```coffeescript

express = require("express")
emailableRoutes = require("mongoose-emailable").routes
UserModel = require("./path/to/your/mongoose/usermodel")

app = express()

emailableRoutes.use(app,
  model: UserModel # mandatory
)
```

And you're set! Users will receive an email asking for confirmation when registering.

## Settings and options

### Mongoose plugin

* Settings
  * `from`: the sender email address, typically your address
  * `confirmRoute`: path to your server address route (ie. http://example.com/account/email/confirm)
  * `amazonSES`: an object with `AWSAccessKeyID` and `AWSSecretKey` keys

* Options
  * `subject`: a `string` used to populate the email subject (defaults to "Confirm your account registration")
  * `html`: a `function` or `string` used to populate the email body (defaults: see source code)

### Express route

* Settings
  * `model`: any mongoose model class, most likely a User model kind.
  
* Options
  * `path`: path to email confirmation page (default: /account/email/confirm)
  * `template`: template to use when rendering the email confirmation page (defaults to a simple text page)
  * `reqHttpFields`: any fields in express `req` object that you wish to automatically pass to `res.locals`. Simply pass an object where keys are `req` fields and values are `res.locals` fields (for example, passing `{ user: loggedUser }` will set the value of `req.user` to `res.locals.loggedUser`.
  * `middlewares`: array of express middlewares you wish to pass to the route.


## Mongoose plugin methods and statics

### Methods

#### sendEmail(message, callback)
Asynchronously sends an email to any confirmed email address.

See nodemailer documentation for a full description of message object.

### Statics

#### sendConfirmationEmail(callback)

#### confirmEmailAddress(callback)


# TODO
- [ ] add the ability to resend the confirmation message (generate new token ?)
- [ ] allow option for setting custom field names, and remove dependency to `name` field
- [ ] remove nodemailer dependency / allow for alternate libraries ?
- [ ] tests
- [ ] examples
