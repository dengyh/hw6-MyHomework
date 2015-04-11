require! ['express']
router = express.Router! 

module.exports = (passport)->

  router.get '/login', (req, res)!-> res.render 'login', message: req.flash 'message'

  router.post '/login', passport.authenticate 'login', {
    success-redirect: '/', failure-redirect: '/login', failure-flash: true
  }

  router.get '/signup', (req, res)!-> res.render 'register', message: req.flash 'message'

  router.post '/signup', passport.authenticate 'signup', {
    success-redirect: '/', failure-redirect: '/signup', failure-flash: true
  }

  router.get '/logout', (req, res)!-> 
    req.logout!
    res.redirect '/login'

