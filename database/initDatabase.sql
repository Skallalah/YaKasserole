DROP TABLE IF EXISTS recette CASCADE;
DROP TABLE IF EXISTS compte CASCADE;
DROP TABLE IF EXISTS atelier CASCADE;
DROP TABLE IF EXISTS inscrit CASCADE;
DROP TABLE IF EXISTS comment CASCADE;
DROP TABLE IF EXISTS etape_in_recette CASCADE;
DROP TABLE IF EXISTS recette_etape CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;

CREATE TABLE compte (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255),
  prenom VARCHAR(255),
  nom VARCHAR(255),
  adresse VARCHAR(255),
  pays VARCHAR(255),
  telephone INT,
  code_postal INT,
  pwd TEXT,
  status VARCHAR(30),
  token INT
);

--get_status;

CREATE TABLE atelier (
  id SERIAL PRIMARY KEY,
  id_creator INT,
  url_img VARCHAR(255),
  price NUMERIC,
  nb_max INT,
  FOREIGN KEY(id_creator) REFERENCES compte(id)
);

CREATE TABLE inscrit (
  id_atelier INT,
  id_member INT,
  FOREIGN KEY(id_atelier) REFERENCES atelier(id),
  FOREIGN KEY(id_member) REFERENCES compte(id)
);


CREATE TABLE recette (
  id SERIAL,
  name VARCHAR(255),
  likes INT,
  url_img VARCHAR(255),
  time TIMESTAMP,
  id_creator INT,
  id_content INT,
  PRIMARY KEY(id)
);

CREATE TABLE comment (
  id_recette INT,
  id_member INT,
  content TEXT,
  FOREIGN KEY(id_recette) REFERENCES recette(id),
  FOREIGN KEY(id_member) REFERENCES compte(id)
);


CREATE TABLE recette_etape (
  id SERIAL PRIMARY KEY,
  content TEXT
);

CREATE TABLE etape_in_recette (
  id_recette INT,
  id_etape INT,
  FOREIGN KEY(id_recette) REFERENCES recette(id),
  FOREIGN KEY(id_etape) REFERENCES recette_etape(id)
);

CREATE TABLE transactions (
  id_member INT,
  timeof TIMESTAMP,
  price NUMERIC,
  id_atelier INT,
  FOREIGN KEY(id_atelier) REFERENCES atelier(id),
  FOREIGN KEY(id_member) REFERENCES compte(id)
);

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
CREATE OR REPLACE FUNCTION ADD_MEMBRE(email_ VARCHAR(255), pwd_ TEXT,
                                       nom_ VARCHAR(255), prenom_ VARCHAR(255),
                                       adresse_ VARCHAR(255), code_postal_ INT,
                                       telephone_ INT, pays_ VARCHAR(255), status_ VARCHAR(30))
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.email = email_;
        IF found = TRUE THEN
           RETURN 0;
        END IF;
        INSERT INTO compte(email, pwd, nom, prenom, adresse, code_postal, telephone, pays, status, token)
        VALUES (email_, pwd_, nom_, prenom_, adresse_, code_postal_, telephone_, pays_, status_, NULL);
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
CREATE OR REPLACE FUNCTION ADD_ATELIER(id_creator_ INT, url_img_ VARCHAR(255), price_ NUMERIC, nb_max_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_creator_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO atelier(id_creator, url_img, price, nb_max)
        VALUES (id_creator_, url_img_, price_, nb_max_);
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
        INSERT INTO comment(id_recette, id_member, content)
        VALUES (id_recette_, id_member_, content_);
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
CREATE OR REPLACE FUNCTION ADD_RECETTE(name_ VARCHAR(255), url_img_ VARCHAR(255), time_ TIMESTAMP, id_creator_ INT, id_content_ INT)
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.id = id_creator_;
        IF found = FALSE THEN
          RETURN 0;
        END IF;
        INSERT INTO recette (name, likes, url_img, time, id_creator, id_content)
        VALUES (name_, 0, url_img_, time_, id_creator_, id_content_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
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

CREATE OR REPLACE FUNCTION ADD_RECETTE_ETAPE(content_ TEXT)
       RETURNS INT AS
$$
BEGIN
        INSERT INTO recette_etape(content)
        VALUES (content_);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 2;
END;
$$ LANGUAGE plpgsql;
