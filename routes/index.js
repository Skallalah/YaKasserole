var express = require('express');
var router = express.Router();
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

/* GET home page. */
router.get('/', function(req, res, next) {
  pool.query("SELECT * FROM compte", function(err, result) {
  console.log(result.rows); // output: foo
});
  res.render('index.html', { title: 'YaKasserole' });
});

router.get('/recettes', function(req, res, next) {
  res.render('recette.html', { title: 'Recettes' });
});

module.exports = router;
