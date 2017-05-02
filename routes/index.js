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
    pool.query("SELECT id, nom, url_img, tmp_prep, count(*) AS nb_aime FROM recette " +
    "JOIN aimer ON aimer.id_recette = recette.id " +
    "GROUP BY id, nom, url_img, tmp_prep " +
    "ORDER BY nb_aime DESC")
    .then((result)=>{
      console.log(result);
      res.render('recette.html', { title: 'Recettes', user: req.user, recettes: result });
    })
    .catch((err)=>{
      console.log(err);
      res.redirect("/");
      //done(new Error(`User with the id ${id} does not exist`));
    })

  });

  app.get('/mesrecettes', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT id, nom, url_img, tmp_prep, count(*) AS nb_aime FROM recette " +
    "JOIN aimer ON aimer.id_recette = recette.id WHERE recette.id_compte = $1 " +
    "GROUP BY id, nom, url_img, tmp_prep " +
    "ORDER BY nb_aime DESC", [req.user.id])
    .then((result)=>{
      console.log(result);
      res.render('mesrecettes.html', { title: 'Recettes', user: req.user, recettes: result });
    })
    .catch((err)=>{
      console.log(err);
      res.redirect("/");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.get('/editerecette', isLoggedIn, function(req, res, next) {
    res.render('editerecette.html', { title: 'Création de Recettes', user: req.user });
  });

  app.get('/moncompte', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT to_char(transaction.date, 'YYYY-MM-DD') AS date, CASE WHEN id_atelier ISNULL THEN 'Abonnement Premium' ELSE nom END, somme FROM transaction " +
              "LEFT JOIN atelier ON atelier.id = transaction.id_atelier " +
              "WHERE transaction.id_compte = $1",
      [req.user.id])
    .then((result)=>{
      console.log(result);
      res.render('moncompte.html', { title: 'Mon Compte', user: req.user, transaction: result });
    })
    .catch((err)=>{
      console.log(err);
      res.redirect("/");
      //done(new Error(`User with the id ${id} does not exist`));
    })
    //res.render('moncompte.html', { title: 'Mon Compte', user: req.user });
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

  app.post('/modification', function(req, res, next) {
    console.log("signup...");
    console.log(req.user.id);
    if (req.body.adresse == "") { req.body.adresse = null; }
    if (req.body.pays == "") { req.body.pays = null; }
    if (req.body.ville == "") { req.body.ville = null; }
    if (req.body.code == "") { req.body.code = null; }
    if (req.body.numero == "") { req.body.numero = null; }
    if (req.body.urlimg == "") { req.body.urlimg = null; }
    console.log(req.body.prenom);
    console.log(req.body.nom);
    console.log(req.body.adresse);
    console.log(req.body.pays);
    console.log(req.body.ville);
    console.log(req.body.code);
    console.log(req.body.numero);
    console.log(req.body.urlimg);
    pool.query("UPDATE compte SET prenom = $1, nom = $2, adresse = $3, pays = $4, ville = $5, code_postal = $6, telephone = $7, url_img = $8 " +
    "WHERE id = $9",
      [req.body.prenom,
      req.body.nom,
      req.body.adresse,
      req.body.pays,
      req.body.ville,
      req.body.code,
      req.body.numero,
      req.body.urlimg,
      req.user.id])
    .then((result)=>{
      console.log(result);
      res.send("success");
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
