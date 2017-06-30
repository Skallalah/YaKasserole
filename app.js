var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var passport = require('passport');
var session = require('express-session');
var flash    = require('connect-flash');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(__dirname + '/ressources'));

app.use('/bootstrap', express.static(__dirname + '/node_modules/bootstrap/dist/'));
app.use('/bootstrapJS', express.static(__dirname + '/node_modules/bootstrap/js'));
app.use('/jquery', express.static(__dirname + '/node_modules/jquery/dist/'));
app.use('/datatable', express.static(__dirname + '/node_modules/datatables.net/js/'));
app.use('/datatable-net', express.static(__dirname + '/node_modules/datatables.net-bs/'));
app.use('/shuffle', express.static(__dirname + '/node_modules/shufflejs/dist'));
app.use('/chart.js', express.static(__dirname + '/node_modules/chart.js/dist'));

// Favicon utilisée
app.use(favicon(path.join(__dirname,'ressources', 'logo_fav.ico')));

// Lancement de base de données
var pg = require('pg');

var Pool = require('pg').Pool;
var pool = new Pool({
  user: 'skallalah',
  password: 'Empereur10',
  host: 'localhost',
  database: 'yakasserole',
  max: 100, // max number of clients in pool
  idleTimeoutMillis: 1000, // close & remove clients which have been idle > 1 second
});

pool.on('error', function(e, client) {
  // if a client is idle in the pool
  // and receives an error - for example when your PostgreSQL server restarts
  // the pool will catch the error & let you handle it here
});

// Lancement de passport !
app.use(session({ secret: 'mamenempereurdusale' })); // session secret
app.use(passport.initialize());
app.use(passport.session()); // persistent login sessions
app.use(flash());

// Déclaration de socket pour les requêtes basiques sans POST.

require('./routes/index')(app, passport, pool);
require('./config/passport')(passport, pool);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

var server = app.listen(8080, function() {
  console.log("Listening on port %s...", server.address().port);
});

//require('./public/sql')(pg);

module.exports = app;
