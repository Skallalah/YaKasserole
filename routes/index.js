module.exports = function(app, passport, pool) {
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
    res.render('recette.html', { title: 'Recettes', user: req.user });
  });

  app.get('/moncompte', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    res.render('moncompte.html', { title: 'Mon Compte', user: req.user });
  });

  app.post('/login', passport.authenticate('local', {
    successRedirect : '/recettes', // redirect to the secure profile section
    failureRedirect : '/', // redirect back to the signup page if there is an error
    failureFlash : true // allow flash messages
  }));

  app.get('/logout', function(req, res) {
    req.logout();
    res.redirect('/');
  });

   app.get('/auth/facebook', passport.authenticate('facebook', { scope : [ 'email', 'public_profile' ] }));

   app.get('/auth/facebook/callback',
      passport.authenticate('facebook', {
        successRedirect : '/',
        failureRedirect : '/'
    }));

    app.get('/auth/google', passport.authenticate('google', { scope : ['profile', 'email'] }));

    app.get('/auth/google/callback',
      passport.authenticate('google', {
        successRedirect : '/',
        failureRedirect : '/'
    }));

  app.post('/signup', function(req, res, next) {
    console.log("signup...");
    console.log(req.body.email);
    console.log(req.body.pass);
    console.log(req.body.nom);
    console.log(req.body.prenom);
    console.log(req.body.adresse);
    console.log(req.body.code);
    console.log(req.body.pays);
    console.log(req.body.ville);
    pool.query("SELECT add_membre($1, $2, NULL, $3, $4, $5, $6, \'000000\', $7, $8, \'Membre\', 0)",
      [req.body.email,
      req.body.pass,
      req.body.nom,
      req.body.prenom,
      req.body.adresse,
      req.body.code,
      req.body.pays,
      req.body.ville])
    .then((result)=>{
      console.log(result);
      if (result.rows[0].add_membre == 1) {
        res.send("success");
      }
      else {
        res.send("fail");
      }
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

// IO SOCKET EXCHANGE ==========================================================

/*io.on('connection', function(socket) {
  console.log("Client connected !");
});*/

//==============================================================================
}

// Vérification de la connection

function isLoggedIn(req, res, next) {

  // if user is authenticated in the session, carry on
  if (req.isAuthenticated())
  return next();

  // if they aren't redirect them to the home page
  res.redirect('/');
}
