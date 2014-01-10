express = require("express")
exphbs  = require('express3-handlebars')
passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy
LinkedinStrategy = require('passport-linkedin').Strategy

# init app

app = express()
app.use(express.logger())
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.session({ secret: 'keyboard cat' }))
app.use(passport.initialize())
app.use(passport.session())
app.use(app.router)

# handlebars config

hbs = exphbs.create
  defaultLayout: 'main'
app.engine 'handlebars', hbs.engine
app.set 'view engine', 'handlebars'

# passport config

passport.use new FacebookStrategy((
    clientID: process.env.FACEBOOK_KEY
    clientSecret: process.env.FACEBOOK_SECRET
    callbackURL: "/auth/facebook/callback"
  ), (accessToken, refreshToken, profile, done) ->
    profile.access_token = accessToken
    profile.is_facebook = true
    done(null, profile)
)

passport.use new LinkedinStrategy((
    consumerKey: process.env.LINKEDIN_KEY
    consumerSecret: process.env.LINKEDIN_SECRET
    callbackURL: "/auth/linkedin/callback"
  ), (token, tokenSecret, profile, done) ->
    profile.token = token
    profile.token_secret = tokenSecret
    profile.is_linkedin = true
    done(null, profile)
)

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)

# index

app.get "/", (request, response) ->
  if request.session.passport_auth
    response.render 'index',
      user: request.session.passport_auth
  response.render 'index'

# authentication routes

app.get "/auth/facebook", passport.authenticate('facebook',
  scope: ['user_about_me', 'friends_about_me', 'user_birthday', 'friends_birthday', 'user_location', 'friends_location', 'read_stream', 'user_work_history', 'friends_work_history', 'user_education_history', 'friends_education_history', 'xmpp_login']
)

app.get "/auth/facebook/callback", (request, response) ->
  passport.authenticate('facebook', (error, user, info) ->
    request.session.passport_auth = user
    response.redirect('/')
  )(request, response)

app.get "/auth/linkedin", passport.authenticate('linkedin',
  scope: ['r_fullprofile', 'r_emailaddress', 'r_network', 'w_messages']
)

app.get "/auth/linkedin/callback", (request, response) ->
  passport.authenticate('linkedin', (error, user, info) ->
    request.session.passport_auth = user
    response.redirect('/')
  )(request, response)

# listen up!

app.listen 8888
