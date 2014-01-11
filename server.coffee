express = require("express")
exphbs  = require('express3-handlebars')
passport = require('./passport-config.coffee').passport
request = require('request')
fs = require('fs')

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

# index

app.get "/", (req, res) ->
  if req.session.passport_auth
    res.render 'index',
      user: req.session.passport_auth

    if req.session.passport_auth.is_facebook
      request.get 'https://graph.facebook.com/me/friends', (
        qs: 
          access_token: req.session.passport_auth.access_token
          fields: 'id,age_range,bio,birthday,education,email,favorite_athletes,favorite_teams,first_name,gender,hometown,inspirational_people,languages,last_name,name,link,location,political,quotes,relationship_status,religion,significant_other,username'
      ), (error, response, body) ->
        parsed_body = JSON.parse(body)
        num_friends = parsed_body.data.length
        fs.writeFile 'tmp/facebook_connections', body

    if req.session.passport_auth.is_linkedin
      request.get 'https://api.linkedin.com/v1/people/~/connections', (
        qs:
          oauth2_access_token: req.session.passport_auth.access_token
          format: 'json'
      ), (error, response, body) ->
        parsed_body = JSON.parse(body)
        num_friends = parsed_body.values.length
        fs.writeFile 'tmp/linkedin_connections', body

  res.render 'index'

# authentication routes

app.get "/auth/facebook", passport.authenticate('facebook',
  scope: ['user_about_me', 'friends_about_me', 'user_birthday', 'friends_birthday', 'user_location', 'friends_location', 'read_stream', 'user_work_history', 'friends_work_history', 'user_education_history', 'friends_education_history', 'xmpp_login']
)

app.get "/auth/facebook/callback", (req, res) ->
  passport.authenticate('facebook', (error, user, info) ->
    req.session.passport_auth = user
    res.redirect('/')
  )(req, res)

app.get "/auth/linkedin", passport.authenticate('linkedin', {state: 'SOME STATE'})

app.get "/auth/linkedin/callback", (req, res) ->
  passport.authenticate('linkedin', (error, user, info) ->
    req.session.passport_auth = user
    res.redirect('/')
  )(req, res)


# listen up!

app.listen 8888
