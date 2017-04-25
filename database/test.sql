select ADD_MEMBRE('zi@ned.fr', 'password', 'rebiai', 'zined', 'une rue', 94270, 0593193910, 'France', 'membre');

select ADD_MEMBRE('zi@ned.fr', 'password', 'rebiai', 'zined', 'une rue', 94270, 0593193910, 'France', 'membre');
--Normalement erreur, car l'adresse email existe.

select ADD_ATELIER(2, 'http://test.fr/image.png', 13.37, 20);
--Erreur car l'id du createur n'existe pas

select ADD_ATELIER(1, 'http://test.fr/image.png', 13.37, 20);

select ADD_INSCRIT(2, 3);
--Erreur car ni l'id de l'aletelier, ni celui du compte existe

select ADD_INSCRIT(1, 3);
--Erreur l'id du compte n'existe pas

select ADD_INSCRIT(2, 1);
--Erreur l'id de l'atelier n'existe pas

select ADD_INSCRIT(1, 1);

select ADD_MEMBRE('le@ny.fr', 'password', 'lenny', 'colin', 'a Epita on connait', 94270, 0593193910, 'France', 'MJ');

select ADD_RECETTE('KFC', 'http://test.fr/image.png', '2001-09-28 01:00:00', 3, 0);
--Erreur le membre 3 n'existe pas

select ADD_RECETTE('KFC', 'http://test.fr/image.png', '2001-09-28 01:00:00', 2, 0);

select ADD_RECETTE('Kebab', 'http://test.fr/image.png', '2016-09-28 01:00:00', 1, 0);

select ADD_COMMENT(9, 4, 'je provoque une erreur');
--Ni l'id de la recette, ni l'id du membre n'existe

select ADD_COMMENT(2, 38, 'je provoque une erreur');
--l'id du membre n'existe pas

select ADD_COMMENT(9, 1, 'je provoque une erreur');
--l'id de la recette n'existe pas

select ADD_COMMENT(2, 2, 'je provoque aucune erreur mais ta recette pue...');

select ADD_TRANSACTION(3,'2016-09-28 01:00:00' , 15.00, 3);
--Ni le membre ni l'atelier n'existe

select ADD_TRANSACTION(3,'2016-09-28 01:00:00' , 15.00, 3);
--Ni le membre ni l'atelier n'existe

select ADD_TRANSACTION(1,'2016-09-28 01:00:00' , 15.00, 3);
--L'atelier n'existe pas

select ADD_TRANSACTION(3,'2016-09-28 01:00:00' , 15.00, 2);
--Le membre n'existe pas

select ADD_MEMBRE('troi@sieme', 'password', 'john', 'doe', 'dans la rue', 94270, 0000000, 'France', 'Admin');

select ADD_ATELIER(3, 'http://test.fr/image.png', 13.37, 20);

select ADD_TRANSACTION(3,'2016-09-28 01:00:00' , 15.00, 2);

select GET_STATUS(4);
--Le membre n'existe pas

select GET_STATUS(3);
