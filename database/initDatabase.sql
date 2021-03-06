-- foreign keys
ALTER TABLE aimer
    DROP CONSTRAINT aimer_compte;

ALTER TABLE aimer
    DROP CONSTRAINT aimer_recette;

ALTER TABLE commentaire
    DROP CONSTRAINT commentaire_compte;

ALTER TABLE commentaire
    DROP CONSTRAINT commentaire_recette;

ALTER TABLE etape_recette
    DROP CONSTRAINT etape_recette_recette;

ALTER TABLE inscrit
    DROP CONSTRAINT inscrit_atelier;

ALTER TABLE inscrit
    DROP CONSTRAINT inscrit_compte;

ALTER TABLE recette
    DROP CONSTRAINT recette_compte;

ALTER TABLE transaction
    DROP CONSTRAINT transaction_atelier;

ALTER TABLE transaction
    DROP CONSTRAINT transaction_compte;

-- tables
DROP TABLE aimer CASCADE;
DROP TABLE atelier CASCADE;
DROP TABLE commentaire CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE etape_recette CASCADE;
DROP TABLE inscrit CASCADE;
DROP TABLE recette CASCADE;
DROP TABLE transaction CASCADE;


-- tables
-- Table: aimer
CREATE TABLE aimer (
    id_compte int  NOT NULL,
    id_recette int  NOT NULL,
    CONSTRAINT aimer_pk PRIMARY KEY (id_compte,id_recette)
);

-- Table: atelier
CREATE TABLE atelier (
    id serial  NOT NULL,
    id_compte INT NOT NULL,
    nom varchar(255)  NOT NULL,
    date timestamp  NOT NULL,
    duree time  NOT NULL,
    url_img varchar(255)  NULL,
    nb_personne int  NOT NULL,
    informations text  NOT NULL,
    ville varchar(255)  NOT NULL,
    adresse varchar(255)  NOT NULL,
    pays varchar(255)  NOT NULL,
    code_postal int  NOT NULL,
    valide boolean  NOT NULL,
    prix money NOT NULL,
    CONSTRAINT atelier_pk PRIMARY KEY (id)
);

-- Table: commentaire
CREATE TABLE commentaire (
    id serial NOT NULL,
    id_compte int  NOT NULL,
    id_recette int  NOT NULL,
    contenu text  NOT NULL,
    CONSTRAINT commentaire_pk PRIMARY KEY (id)
);

-- Table: compte
CREATE TABLE compte (
    id serial  NOT NULL,
    url_img varchar(255)  NULL,
    email varchar(255)  NOT NULL,
    prenom varchar(255)  NOT NULL,
    nom varchar(255)  NOT NULL,
    adresse varchar(255)  NULL,
    pays varchar(255)  NULL,
    ville varchar(255)  NULL,
    code_postal int  NULL,
    telephone varchar(15)  NULL,
    pwd varchar(255)  NULL,
    token int  NOT NULL,
    status varchar(30)  NOT NULL,
    premium timestamp  NULL,
    CONSTRAINT compte_pk PRIMARY KEY (id)
);

-- Table: etape_recette
CREATE TABLE etape_recette (
    id_recette int  NOT NULL,
    n_etape int  NOT NULL,
    contenu text  NOT NULL,
    CONSTRAINT etape_recette_pk PRIMARY KEY (id_recette,n_etape)
);

-- Table: inscrit
CREATE TABLE inscrit (
    id_compte int  NOT NULL,
    id_atelier int  NOT NULL,
    nb int NOT NULL,
    CONSTRAINT inscrit_pk PRIMARY KEY (id_compte,id_atelier)
);

-- Table: recette
CREATE TABLE recette (
    id serial  NOT NULL,
    nom varchar(255) NOT NULL,
    id_compte int  NOT NULL,
    url_img varchar(255)  NULL,
    tmp_prep time  NOT NULL,
    nb_personne int  NOT NULL,
    date_creation date  NOT NULL,
    valide boolean  NOT NULL,
    CONSTRAINT recette_pk PRIMARY KEY (id)
);

-- Table: transaction
CREATE TABLE transaction (
    id_compte int  NOT NULL,
    id_atelier int  NULL,
    date timestamp  NOT NULL,
    somme money  NOT NULL
);

-- foreign keys
-- Reference: aimer_compte (table: aimer)
ALTER TABLE aimer ADD CONSTRAINT aimer_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: aimer_recette (table: aimer)
ALTER TABLE aimer ADD CONSTRAINT aimer_recette
    FOREIGN KEY (id_recette)
    REFERENCES recette (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: commentaire_compte (table: commentaire)
ALTER TABLE commentaire ADD CONSTRAINT commentaire_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: commentaire_recette (table: commentaire)
ALTER TABLE commentaire ADD CONSTRAINT commentaire_recette
    FOREIGN KEY (id_recette)
    REFERENCES recette (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: etape_recette_recette (table: etape_recette)
ALTER TABLE etape_recette ADD CONSTRAINT etape_recette_recette
    FOREIGN KEY (id_recette)
    REFERENCES recette (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: inscrit_atelier (table: inscrit)
ALTER TABLE inscrit ADD CONSTRAINT inscrit_atelier
    FOREIGN KEY (id_atelier)
    REFERENCES atelier (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: inscrit_compte (table: inscrit)
ALTER TABLE inscrit ADD CONSTRAINT inscrit_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: recette_compte (table: recette)
ALTER TABLE recette ADD CONSTRAINT recette_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: transaction_atelier (table: transaction)
ALTER TABLE transaction ADD CONSTRAINT transaction_atelier
    FOREIGN KEY (id_atelier)
    REFERENCES atelier (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: transaction_compte (table: transaction)
ALTER TABLE transaction ADD CONSTRAINT transaction_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE atelier ADD CONSTRAINT atelier_compte
    FOREIGN KEY (id_compte)
    REFERENCES compte (id)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

/*
                      GET STATUS
Cette fonction une string qui correspond aux rang de l'id du membre

On vérifie seulement si l'id n'existe pas dans ce cas on renvoie 0
Exception : 2
Sinon Admin || NULL (normalement jamais)
Rajouter : Chef | Premium | Membre
*/
CREATE OR REPLACE FUNCTION GET_STATUS(id_member_ INT)
       RETURNS TEXT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_member_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        PERFORM * from compte where compte.status = 'Admin' AND compte.id = id_member_;
        IF found = TRUE THEN
          RETURN 'Admin';
        END IF;
        RETURN 'NULL';
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

/*
                      ADD MEMBRE
Cette fonction ajoute donc un membre dans la base de donnée

On vérifie seulement si l'email existe, dans ce cas on renvoie 0
Exception : 2
Sinon 1
*/
CREATE OR REPLACE FUNCTION ADD_MEMBRE(email_ VARCHAR(255), pwd_ VARCHAR(30), img_url_ VARCHAR(255),
                                       nom_ VARCHAR(255), prenom_ VARCHAR(255),
                                       adresse_ VARCHAR(255), code_postal_ INT,
                                       telephone_ VARCHAR(15), pays_ VARCHAR(255),
                                       ville_ VARCHAR(255), status_ VARCHAR(30),
                                       token_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.email= email_ and compte.token = token_;
        IF found = TRUE THEN
           RETURN 0;
        END IF;
        INSERT INTO compte
        VALUES (DEFAULT, img_url_, email_, prenom_, nom_, adresse_, pays_, ville_, code_postal_, telephone_, pwd_, token_, status_, NULL);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

/*
                      ADD INSCRIT
Cette fonction ajoute des membres dans un atelier dans la base de donnée

On vérifie si l'id de l'atelier || du membre n'existe pas: 0
Exception : 2
Sinon 1
*/
CREATE OR REPLACE FUNCTION ADD_INSCRIT(id_atelier_ INT, id_member_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_member_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        PERFORM * from atelier where atelier.id = id_atelier_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO inscrit(id_atelier, id_member)
        VALUES (id_atelier_, id_member_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;


/*
                      ADD ATELIER
Cette fonction ajoute un atelier dans la base de donnée

On vérifie si l'id du creator n'existe pas : 0
(On pourrait aussi verifier le rang?)
Exception : 2
Sinon 1
*/
CREATE OR REPLACE FUNCTION ADD_ATELIER(id_creator_ INT, nom_ VARCHAR(255), date_ timestamp, duree_ time, url_img_ VARCHAR(255), nb_personne_ int, informations_ text, ville_ VARCHAR(255), adresse_ VARCHAR(255), pays_ VARCHAR(255), code_ int, prix_ money)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_creator_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO atelier
        VALUES (DEFAULT, id_creator_, nom_, date_, duree_, url_img_, nb_personne_, informations_, ville_, adresse_, pays_, code_, FALSE, prix_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

/*
                      ADD COMMENT
Cette fonction ajoute un commentaire sur une page de recette

On vérifie si l'id_recette || id_member n'existe pas, dans ce cas on renvoie 0
Exception : 2
Sinon 1
*/
CREATE OR REPLACE FUNCTION ADD_COMMENT(id_recette_ INT, id_member_ INT, content_ TEXT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_member_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        PERFORM * from recette where recette.id = id_recette_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO commentaire
        VALUES (DEFAULT, id_member_, id_recette_, content_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HAS_PLACE(id_atelier_ INT, nb_ INT)
       RETURNS boolean AS
$$
DECLARE nb_inscrit INT;
BEGIN
        PERFORM * from atelier where atelier.id = id_atelier_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        SELECT count(nb) INTO nb_inscrit FROM inscrit WHERE id_atelier = id_atelier_;
        PERFORM * from atelier where atelier.id = id_atelier_;
        RETURN ((SELECT nb_personne FROM atelier WHERE atelier.id = id_atelier_) >= (nb_inscrit + nb_));
        EXCEPTION
        WHEN OTHERS THEN RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GET_PRICE(id_atelier_ INT, id_member_ INT)
       RETURNS MONEY AS
$$
DECLARE price_ MONEY;
BEGIN
        SELECT prix INTO price_ FROM atelier WHERE atelier.id = id_atelier_;
        IF (SELECT premium from compte where id = id_member_) >= now() THEN
          RETURN (price_ - price_/10);
        ELSE
          RETURN price_;
        END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION INSCRIPTION(id_atelier_ INT, id_member_ INT, nb_ INT)
       RETURNS INT AS
$$
BEGIN
        IF (SELECT HAS_PLACE(id_atelier_, nb_)) = FALSE THEN
          RETURN 0;
        END IF;
        PERFORM * from atelier where atelier.id = id_atelier_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO transaction
        VALUES (id_member_, id_atelier_, now(), nb_ * (SELECT GET_PRICE(id_atelier_, id_member_)));
        INSERT INTO inscrit
        VALUES (id_member_, id_atelier_, nb_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION IS_PREMIUM(id_member_ INT)
       RETURNS varchar(255) AS
$$
DECLARE premium_ date;
BEGIN
        SELECT premium INTO premium_ FROM compte WHERE id = id_member_;
        IF (premium_ >= now()) THEN
          RETURN to_char(premium_, 'DD-MM-YYYY');
        ELSE
          RETURN NULL;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION PAY_PREMIUM(id_member_ INT)
       RETURNS void AS
$$
DECLARE premium_ date;
BEGIN
        UPDATE compte
        SET premium = now() + interval '30 days'
        WHERE id = id_member_;
        INSERT INTO transaction
        VALUES (id_member_, NULL, now(), 12);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION REMOVE_COMMENT(id_comment_ int, id_compte_ int)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from commentaire where id_compte = id_compte_ and id = id_comment_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        DELETE FROM commentaire
        WHERE id = id_comment_;
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UPDATE_COMMENT(id_comment_ int, id_compte_ int, content_ text)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from commentaire where id_compte = id_compte_ and id = id_comment_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        UPDATE commentaire
        SET contenu = content_
        WHERE id = id_comment_;
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;


/*
                      ADD TRANSACTION
Cette fonction ajoute une transaction dans la base de donnée

On vérifie si le compte || l'atelier n'exsite pas, dans ce cas on renvoie 0
Exception : 2
Sinon 1
*/

CREATE OR REPLACE FUNCTION ADD_TRANSACTION(id_member_ INT, timeof_ TIMESTAMP, price_ NUMERIC, id_atelier_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_member_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        PERFORM * from atelier where atelier.id = id_atelier_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO transactions(id_member, timeof, price, id_atelier)
        VALUES (id_member_, timeof_, price_, id_atelier_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;


/*
                      ADD RECETTE
Cette fonction ajoute une recette dans la base de donnée

On vérifie seulement si le compte n'exsite pas, dans ce cas on renvoie 0
Exception : 2
Sinon 1
*/
CREATE OR REPLACE FUNCTION ADD_RECETTE(nom_ VARCHAR(255), id_compte_ INT, url_img_ VARCHAR(255), tmp_prep_ TIME, nb_personne_ INT)
       RETURNS INT AS
$$
DECLARE
  ret INT;
BEGIN
        INSERT INTO recette
        VALUES (DEFAULT, nom_, id_compte_, url_img_, tmp_prep_, nb_personne_, now(), FALSE)
        RETURNING id INTO ret;
        RETURN ret;
        EXCEPTION
        WHEN OTHERS THEN RETURN -1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION REMOVE_RECETTE(id_recette_ INT)
       RETURNS void AS
$$
BEGIN
        DELETE FROM commentaire
        WHERE id_recette = id_recette_;
        DELETE FROM etape_recette
        WHERE id_recette = id_recette_;
        DELETE FROM aimer
        WHERE id_recette = id_recette_;
        DELETE FROM recette
        WHERE id = id_recette_;
END;
$$ LANGUAGE plpgsql;

/* là je suis plus trop sur */

CREATE OR REPLACE FUNCTION ADD_ETAPE_IN_RECETTE(id_recette_ INT, id_etape_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from recette where recette.id = id_recette_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO etape_in_recette(id_recette, id_etape)
        VALUES (id_recette_, id_etape_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

/*
                      ADD RECETTE ETAPE
Cette fonction ajoute une etape dans une recette

On vérifie si l'id_recette || id_member n'existe pas, dans ce cas on renvoie 0
Exception : 2
Sinon 1
*/

CREATE OR REPLACE FUNCTION ADD_RECETTE_ETAPE(n_etape_ INT, id_recette_ INT, contenu_ TEXT)
       RETURNS INT AS
$$
BEGIN
        INSERT INTO etape_recette
        VALUES (id_recette_, n_etape_, contenu_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ADD_AIME(id_compte_ INT, id_recette_ INT)
       RETURNS INT AS
$$
BEGIN
        INSERT INTO aimer
        VALUES (id_compte_, id_recette_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION REMOVE_AIME(id_compte_ INT, id_recette_ INT)
       RETURNS INT AS
$$
BEGIN
        DELETE FROM aimer
        WHERE id_compte = id_compte_ AND id_recette_ = id_recette;
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION NB_RECETTE_CREE(retour_ interval)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from recette where recette.id = id_recette_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO etape_in_recette(id_recette, id_etape)
        VALUES (id_recette_, id_etape_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW compte_crees AS
  select count(*) as total_compte from compte;

CREATE OR REPLACE VIEW compte_premium AS
  select count(*) as nb_premium from compte where is_premium(id) IS NOT NULL;

CREATE OR REPLACE VIEW meilleur_chef AS
  select nom as meilleur_chef from (select atelier.id, concat(compte.prenom, ' ', compte.nom) as nom, sum(prix) as total from inscrit
  join atelier on id_atelier = atelier.id
  join compte on atelier.id_compte = compte.id
  group by atelier.id, atelier.nom, compte.prenom, compte.nom order by total desc
  limit 1) as sub;

CREATE OR REPLACE VIEW meilleur_membre AS
  select nom as meilleur_membre from (select recette.id, concat(compte.prenom, ' ', compte.nom) as nom, count(*) as total from recette
  join compte on id_compte = compte.id
  group by recette.id, compte.nom, compte.prenom, compte.nom order by total desc
  limit 1) as sub;

CREATE OR REPLACE VIEW recette_mois AS
  select sum(somme) from transaction WHERE EXTRACT(month from date)= EXTRACT(month from now());

CREATE OR REPLACE VIEW top5_commentaire AS
  SELECT recette.nom, count(*) AS nb FROM commentaire
  JOIN recette ON commentaire.id_recette = recette.id
  GROUP BY recette.nom
  ORDER BY nb DESC LIMIT 5;

CREATE OR REPLACE VIEW top5_recettes AS
  select recette.id, nom, count(*) from recette
  join aimer on aimer.id_recette = recette.id
  group by recette.id
  order by count desc
  limit 5;


/* Graph views */
CREATE OR REPLACE VIEW recette_activites AS
  SELECT * FROM (SELECT count(*), to_char(date_creation, 'YYYY-MM-DD') AS date FROM recette
  GROUP BY date_creation
  ORDER BY date_creation DESC LIMIT 30) AS first ORDER BY date ASC;

CREATE OR REPLACE VIEW compo_comptes AS
  SELECT status, count(*) FROM compte
  GROUP BY status;

CREATE OR REPLACE VIEW type_comptes AS
  SELECT CASE WHEN token = 0 THEN 'Local'
  WHEN token = 1 THEN 'Facebook'
  WHEN token = 2 THEN 'Google'
  END AS type, count(*) FROM compte
  GROUP BY token;

CREATE OR REPLACE VIEW repartition_gains AS
  select date::DATE, sum(somme)::NUMERIC from transaction WHERE EXTRACT(month from date)= EXTRACT(month from now())
  GROUP BY date::DATE;

CREATE OR REPLACE VIEW provenance_fonds AS
  select CASE WHEN id_atelier IS NULL THEN 'Abonnement Premium' ELSE 'Atelier' END AS provenance,
  sum(somme)::NUMERIC from transaction WHERE EXTRACT(month from date)= EXTRACT(month from now())
  GROUP BY id_atelier;
