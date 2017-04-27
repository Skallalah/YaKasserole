module.exports = function(app, passport, io) {
  /* GET home page. */
  app.get('/', function(req, res, next) {
    if (req.isAuthenticated()) {
      res.render('index.html', { title: 'YaKasserole', user : req.user });
    }
    else {
      res.render('index.html', { title: 'YaKasserole'});
    }
  });

  app.get('/recettes', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    res.render('recette.html', { title: 'Recettes' });
  });

  app.post('/login', passport.authenticate('local', {
    successRedirect : '/recettes', // redirect to the secure profile section
    failureRedirect : '/', // redirect back to the signup page if there is an error
    failureFlash : true // allow flash messages
  }));

// IO SOCKET EXCHANGE ==========================================================

io.on('connection', function(socket) {
  console.log("Client connected !");
});

//==============================================================================
}

// Vérification de la connection

function isLoggedIn(req, res, next) {

  // if user is authenticated in the session, carry on
  if (req.isAuthenticated())
  return next();

  // if they aren't redirect them to the home page
  //res.redirect('/');
}
