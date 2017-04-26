

module.exports = function(app, passport) {
/* GET home page. */
app.get('/', function(req, res, next) {
  pool.query("SELECT * FROM compte", function(err, result) {
  console.log(result.rows); // output: foo
});
  res.render('index.html', { title: 'YaKasserole' });
});

app.get('/recettes', function(req, res, next) {
  res.render('recette.html', { title: 'Recettes' });
});

}
