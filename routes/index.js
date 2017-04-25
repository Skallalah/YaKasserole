var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index.html', { title: 'Recettes' });
});

router.get('/recettes', function(req, res, next) {
  res.render('recette.html', { title: 'Recettes' });
});

module.exports = router;
