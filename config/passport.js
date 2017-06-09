var LocalStrategy = require('passport-local').Strategy;
var FacebookStrategy = require('passport-facebook').Strategy;
var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

var configAuth = require('./auth');

module.exports = function(passport, pool) {

  passport.serializeUser((user, done)=>{
      console.log("serialize ", user.id);
      done(null, user.id);
    });

    passport.deserializeUser((id, done)=>{
      console.log("deserialize ", id);
      pool.query("SELECT id, url_img, email, prenom, nom, adresse, pays, ville, code_postal, telephone, pwd, token, status, is_premium(id) as premium FROM compte " +
              "WHERE id = $1", [id])
      .then((user)=>{
        if (user.rowCount != 1)
        {
          done(new Error(`User with the id ${id} does not exist`));
        }
        else {
          console.log("deserialize success :", user.rows[0]);
          //log.debug("deserializeUser ", user);
          done(null, user.rows[0]);
        }
      })
      .catch((err)=>{
        done(new Error(`User with the id ${id} does not exist`));
      })
    });

  passport.use('local', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'pass'
  },
  (username, password, done) => {
    console.log("Login process:", username, password);
    return pool.query("SELECT id, url_img, email, prenom, nom, adresse, pays, ville, code_postal, telephone, pwd, token, status, is_premium(id) as premium " +
    "FROM compte " +
    "WHERE email=$1 AND pwd=$2 AND token=0", [username, password])
    .then((result)=> {
      console.log(result);
      console.log(result.rowCount);
      if (result.rowCount != 1)
      {
        console.log("/login: Non trouvé !");
        return done(null, false, {message:'Mauvais mot de passe ou nom d\'utilisateur.'});
      }
      else {
        console.log("Success !", result.rows[0]);
        return done(null, result.rows[0]);
      }
    })
    .catch((err) => {
      console.log("/login: " + err);
      console.log(result)
      return done(null, false, {message:'Erreur dans la base de données.'});
    });
  }));


  //============================================================================
  // FACEBOOK AUTHENTIFICATION =================================================
  //============================================================================

  passport.use(new FacebookStrategy({
       // pull in our app id and secret from our auth.js file
       clientID        : configAuth.facebookAuth.clientID,
       clientSecret    : configAuth.facebookAuth.clientSecret,
       callbackURL     : configAuth.facebookAuth.callbackURL,
       profileFields: ['id', 'emails', 'name', 'photos']
   },
   // facebook will send back the token and profile
   function(token, refreshToken, profile, done) {
     console.log("Test Facebook");
     console.log(profile);
     console.log(profile.emails[0].value);
     console.log(token);
     return pool.query("SELECT add_membre($1, NULL, $2, $3, $4, NULL, NULL, NULL, NULL, NULL, \'Membre\', 1)",
     [profile.emails[0].value,
     profile.photos[0].value,
     profile.name.familyName,
     profile.name.givenName])
     .then((result)=>{
       console.log(result);
       return pool.query("SELECT id, url_img, email, prenom, nom, adresse, pays, ville, code_postal, telephone, pwd, token, status, is_premium(id) as premium FROM compte WHERE email=$1 AND token=1", [profile.emails[0].value])
       .then((result)=> {
         console.log(result);
         console.log(result.rowCount);
         if (result.rowCount != 1)
         {
           console.log("/login: Non trouvé !");
           return done(null, false, {message:'Mauvais mot de passe ou nom d\'utilisateur.'});
         }
         else {
           console.log("Success !", result.rows[0]);
           return done(null, result.rows[0]);
         }
       })
       if (result.rows[0].add_membre != 0) {
         res.send("success");
       }
       else {
         res.send("fail");
       }
     })
     .catch((err)=>{
       console.log("/login: " + err);
       console.log(result)
       return done(null, false, {message:'Erreur dans la base de données.'});
     })

   }));

   //===========================================================================
   // GOOGLE AUTHENTIFICATION ==================================================
   //===========================================================================

   passport.use(new GoogleStrategy({
        // pull in our app id and secret from our auth.js file
        clientID        : configAuth.googleAuth.clientID,
        clientSecret    : configAuth.googleAuth.clientSecret,
        callbackURL     : configAuth.googleAuth.callbackURL,
        profileFields: ['id', 'emails', 'name']
    },
    // facebook will send back the token and profile
    function(token, refreshToken, profile, done) {
      console.log("Test Google");
      console.log(profile);
      console.log(profile.emails[0].value);
      console.log(token);
      return pool.query("SELECT add_membre($1, NULL, $2, $3, $4, NULL, NULL, NULL, NULL, NULL, \'Membre\', 2)",
      [profile.emails[0].value,
      profile.photos[0].value,
      profile.name.familyName,
      profile.name.givenName])
      .then((result)=>{
        console.log(result);
        return pool.query("SELECT id, url_img, email, prenom, nom, adresse, pays, ville, code_postal, telephone, pwd, token, status, is_premium(id) as premium FROM compte WHERE email=$1 AND token=2", [profile.emails[0].value])
        .then((result)=> {
          console.log(result);
          console.log(result.rowCount);
          if (result.rowCount != 1)
          {
            console.log("/login: Non trouvé !");
            return done(null, false, {message:'Mauvais mot de passe ou nom d\'utilisateur.'});
          }
          else {
            console.log("Success !", result.rows[0]);
            return done(null, result.rows[0]);
          }
        })
        if (result.rows[0].add_membre != 0) {
          res.send("success");
        }
        else {
          res.send("fail");
        }
      })
      .catch((err)=>{
        console.log("/login: " + err);
        console.log(result)
        return done(null, false, {message:'Erreur dans la base de données.'});
      })

    }));
}
