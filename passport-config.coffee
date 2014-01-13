passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy
LinkedInStrategy = require('passport-linkedin-oauth2').Strategy

passport.use new FacebookStrategy((
    clientID: process.env.FACEBOOK_KEY
    clientSecret: process.env.FACEBOOK_SECRET
    callbackURL: "/auth/facebook/callback"
  ), (accessToken, refreshToken, profile, done) ->
    profile.access_token = accessToken
    profile.is_facebook = true
    done(null, profile)
)

passport.use new LinkedInStrategy((
    clientID: process.env.LINKEDIN_KEY
    clientSecret: process.env.LINKEDIN_SECRET
    callbackURL: "/auth/linkedin/callback"
  ), (accessToken, refreshToken, profile, done) ->
    profile.access_token = accessToken
    profile.is_linkedin = true
    done(null, profile)
)

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)

exports.passport = passport
