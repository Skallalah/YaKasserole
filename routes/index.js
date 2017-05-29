module.exports = function(app, passport, pool) {
  /* GET home page. */
  var nodemailer = require('nodemailer');

  let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'serviceyakasserole@gmail.com',
        pass: 'yakasserole2017'
    }
  });

  app.get('/', function(req, res, next) {
    if (req.isAuthenticated()) {
      res.render('index.html', { title: 'YaKasserole', user : req.user });
    }
    else {
      res.render('index.html', { title: 'YaKasserole'});
    }
  });

  function sendmail(prenom, nom, from_, to_, subject_, text_) {
    let mailOptions = {
      from: '\"' + prenom + ' ' + nom + '\"? <' + from_ +'>', // sender address
      to: to_, // list of receivers
      subject: subject_, // Subject line
      text: text_ // plain text body
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log(error);
        return 0;
      }
      console.log('Message %s envoyé: %s', info.messageId, info.response);
      return 1;
    });
  }

  app.get('/recettes', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT id, nom, url_img, tmp_prep, count(*) AS nb_aime FROM recette " +
    "LEFT JOIN aimer ON aimer.id_recette = recette.id " +
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

  app.get('/ateliers', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT id," +
	              "nom,"+
	              "to_char(date, 'DD-MM-YYYY') as date,"+
	              "to_char(date, 'HH24hMI') as debut,"+
	              "to_char((date + duree), 'HH24hMI') as fin,"+
	              "url_img,"+
	              "informations,"+
	              "ville,"+
	              "adresse, prix from atelier "+
    "ORDER BY id DESC")
    .then((result)=>{
      console.log(result);
      res.render('ateliers.html', { title: 'Ateliers', user: req.user, ateliers: result });
    })
    .catch((err)=>{
      console.log(err);
      res.redirect("/");
      //done(new Error(`User with the id ${id} does not exist`));
    })

  });

  app.get('/mesateliers', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT id," +
	              "nom,"+
	              "to_char(date, 'DD-MM-YYYY') as date,"+
	              "to_char(date, 'HH24hMI') as debut,"+
	              "to_char((date + duree), 'HH24hMI') as fin,"+
	              "url_img,"+
	              "informations,"+
	              "ville,"+
	              "adresse, prix from atelier "+
                "where id_compte = $1 "+
    "ORDER BY id DESC", [req.user.id])
    .then((result)=>{
      console.log(result);
      res.render('mesateliers.html', { title: 'Mes Ateliers', user: req.user, ateliers: result });
    })
    .catch((err)=>{
      console.log(err);
      res.redirect("/");
      //done(new Error(`User with the id ${id} does not exist`));
    })

  });

  app.post('/recherchemesateliers', function(req, res, next) {
    console.log("recherche mes atelier...");
    var comp = "";
    var word = "%" + req.body.text + "%";
    if (req.body.ordre == "Prix") {
      comp = "prix";
    } else if (req.body.ordre == "Temps") {
      comp = "duree";
    } else {
      comp = "nom";
    }
    console.log(comp);
    pool.query("SELECT id," +
	              "nom,"+
	              "to_char(date, 'DD-MM-YYYY') as date,"+
	              "to_char(date, 'HH24hMI') as debut,"+
	              "to_char((date + duree), 'HH24hMI') as fin,"+
	              "url_img,"+
	              "informations,"+
	              "ville,"+
	              "adresse, prix from atelier "+
                "WHERE lower(nom) LIKE $1 AND id_compte = $2 " +
                "ORDER BY " + comp + " DESC", [word, req.user.id])
    .then((result)=>{
      console.log(result);
      res.send(result);
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/rechercheatelier', function(req, res, next) {
    console.log("recherche atelier...");
    var comp = "";
    var word = "%" + req.body.text + "%";
    if (req.body.ordre == "Prix") {
      comp = "prix";
    } else if (req.body.ordre == "Temps") {
      comp = "duree";
    } else {
      comp = "nom";
    }
    console.log(comp);
    pool.query("SELECT id," +
	              "nom,"+
	              "to_char(date, 'DD-MM-YYYY') as date,"+
	              "to_char(date, 'HH24hMI') as debut,"+
	              "to_char((date + duree), 'HH24hMI') as fin,"+
	              "url_img,"+
	              "informations,"+
	              "ville,"+
	              "adresse, prix from atelier "+
                "WHERE lower(nom) LIKE $1 " +
                "ORDER BY " + comp + " DESC", [word])
    .then((result)=>{
      console.log(result);
      res.send(result);
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/rechercherecette', function(req, res, next) {
    console.log("recherche recette...");
    var comp = "";
    var word = "%" + req.body.text + "%";
    if (req.body.ordre == "Approbation") {
      comp = "nb_aime";
    } else if (req.body.ordre == "Temps") {
      comp = "tmp_prep";
    } else {
      comp = "nom";
    }
    console.log(comp);
    pool.query("SELECT id, nom, url_img, tmp_prep, count(*) AS nb_aime FROM recette " +
    "LEFT JOIN aimer ON aimer.id_recette = recette.id " +
    "WHERE lower(nom) LIKE $1 " +
    "GROUP BY id, nom, url_img, tmp_prep " +
    "ORDER BY " + comp + " DESC", [word])
    .then((result)=>{
      console.log(result);
      res.send(result);
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });



  app.get('/mesrecettes', isLoggedIn, function(req, res, next) {
    console.log("mdr");
    pool.query("SELECT id, nom, url_img, tmp_prep, count(*) AS nb_aime FROM recette " +
    "LEFT JOIN aimer ON aimer.id_recette = recette.id WHERE recette.id_compte = $1 " +
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

  app.get('/editeatelier', isLoggedIn, function(req, res, next) {
    res.render('editeatelier.html', { title: 'Création d\'Ateliers', user: req.user });
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

  app.post('/ajoutrecette', function(req, res, next) {
    console.log("signup...");
    console.log(req.body.json);
    var text = req.body.json;
    var recette = JSON.parse(text);
    var url;
    if (recette.url_img == "") {
      url = null;
    } else {
      url = recette.url_img;
    }
    var time = recette.heure + ":" + recette.minutes + ":00";
    pool.query("SELECT ADD_RECETTE($1, $2, $3, $4, $5)",
      [recette.nom, req.user.id, url, time, recette.nb_personnes])
    .then((result)=>{
      console.log(result);
      var id = result.rows[0].add_recette;
      console.log("EXAMPLE : " + recette.etapes[0] + " id : " + id);
      pool.query("SELECT ADD_RECETTE_ETAPE(0, $1, $2)",
        [id, recette.etapes[0]])
        .catch((err)=>{
          res.send("error");
        });

        for (var tmp = 1; tmp < recette.etapes.length; tmp++) {
          pool.query("SELECT ADD_RECETTE_ETAPE($1, $2, $3)",
            [tmp, id, recette.etapes[tmp]])
            .catch((err)=>{
              res.send("error");
            });
        }
        res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/ajoutatelier', function(req, res, next) {
    console.log("signup...");
    console.log(req.body.json);
    var text = req.body.json;
    var atelier = JSON.parse(text);
    var url;
    if (atelier.url_img == "") {
      url = null;
    } else {
      url = atelier.url_img;
    }
    console.log(atelier.nom);
    console.log(atelier.date);
    console.log(atelier.duree);
    console.log(atelier.nb_personnes);
    console.log(atelier.informations);
    console.log(atelier.ville);
    console.log(atelier.adresse);
    console.log(atelier.pays);
    console.log(atelier.code_postal);
    console.log(atelier.prix);
    pool.query("SELECT ADD_ATELIER($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)",
      [req.user.id,
      atelier.nom,
      atelier.date,
      atelier.duree,
      url,
      atelier.nb_personnes,
      atelier.informations,
      atelier.ville,
      atelier.adresse,
      atelier.pays,
      atelier.code_postal,
      atelier.prix])
    .then((result)=>{
      res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.get('/recettes/:id_recette', isLoggedIn, function(req, res, next) {
    pool.query("SELECT * FROM recette WHERE id = $1",
      [req.params.id_recette])
    .then((recette)=>{
      if (recette.rowCount == 0) {
        var err = new Error('Not Found');
        err.status = 404;
        next(err);
      }
      console.log(recette);
      pool.query("SELECT * FROM etape_recette WHERE id_recette = $1 ORDER BY n_etape ASC",
        [req.params.id_recette])
      .then((etapes)=>{
        console.log(etapes);
        pool.query("select commentaire.id, prenom, nom, id_compte, url_img, contenu from commentaire " +
                  "join compte on id_compte = compte.id " +
                  "where id_recette = $1 " +
                  "order by commentaire.id ASC",
          [req.params.id_recette])
          .then((commentaire)=>{
            console.log(commentaire);
            pool.query("select * from aimer where id_recette = $1 and id_compte = $2",
              [req.params.id_recette, req.user.id])
            .then((aime)=>{
              res.render('recettedetail.html', { title: 'Création de Recettes', user: req.user, recette_info: recette, recette_etapes: etapes, commentaires: commentaire, aimer: aime.rowCount });
            })
          })
      })
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/supprimecommentaire', function(req, res, next) {
    console.log("Supprimer commentaire...");
    pool.query("SELECT REMOVE_COMMENT($1, $2)",
      [req.body.idcomment, req.user.id])
    .then((result)=>{
      res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/creercommentaire', function(req, res, next) {
    console.log("Ajouter commentaire...");
    pool.query("SELECT ADD_COMMENT($1, $2, $3)",
      [req.body.idrecette, req.user.id, req.body.text])
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

  app.post('/editecommentaire', function(req, res, next) {
    console.log("Modifier commentaire...");
    pool.query("SELECT UPDATE_COMMENT($1, $2, $3)",
      [req.body.idcomment, req.user.id, req.body.text])
    .then((result)=>{
      res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/aimerrecette', function(req, res, next) {
    console.log("Ajouter un j'aime...");
    pool.query("SELECT ADD_AIME($1, $2)",
      [req.user.id, req.body.idrecette])
    .then((result)=>{
      res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.post('/plusaimerrecette', function(req, res, next) {
    console.log("Enlever l'aime...");
    pool.query("SELECT REMOVE_AIME($1, $2)",
      [req.user.id, req.body.idrecette])
    .then((result)=>{
      res.send("success");
    })
    .catch((err)=>{
      console.log(err);
      res.send("error");
      //done(new Error(`User with the id ${id} does not exist`));
    })
  });

  app.get('/nouscontacter', function(req, res, next) {
    res.render('nouscontacter.html', { title: 'Nous Contacter', user : req.user });
  });

  app.post('/contacter', function(req, res, next) {
    console.log("Contact...");
    if (sendmail(req.body.prenom, req.body.nom, req.body.email, 'serviceyakasserole@gmail.com', req.body.objet, req.body.message) == 1) {
      res.send("success");
    }
    else {
      res.send("success")
    }
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
