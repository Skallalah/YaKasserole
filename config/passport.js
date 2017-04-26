var LocalStrategy = require('passport-local').Strategy;

module.exports = function(passport, pool) {

  passport.use('local', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'pass'
  },
  (username, password, done) => {
    console.log("Login process:", username);
    return pool.query("SELECT * " +
    "FROM users " +
    "WHERE email=$1 AND pwd=$2", [username, password])
    .then((result)=> {
      return done(null, result);
    })
    .catch((err) => {
      log.error("/login: " + err);
      return done(null, false, {message:'Wrong user name or password'});
    });
  }));
}
