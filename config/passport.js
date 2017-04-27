var LocalStrategy = require('passport-local').Strategy;

module.exports = function(passport, pool) {

  passport.serializeUser((user, done)=>{
      console.log("serialize ", user.id);
      done(null, user.id);
    });

    passport.deserializeUser((id, done)=>{
      console.log("deserialize ", id);
      pool.query("SELECT * FROM compte " +
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
    return pool.query("SELECT * " +
    "FROM compte " +
    "WHERE email=$1 AND pwd=$2", [username, password])
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
}
