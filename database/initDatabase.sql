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
DROP TABLE aimer;
DROP TABLE atelier;
DROP TABLE commentaire;
DROP TABLE compte;
DROP TABLE etape_recette;
DROP TABLE inscrit;
DROP TABLE recette;
DROP TABLE transaction;


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
    CONSTRAINT atelier_pk PRIMARY KEY (id)
);

-- Table: commentaire
CREATE TABLE commentaire (
    id_compte int  NOT NULL,
    id_recette int  NOT NULL,
    contenu text  NOT NULL,
    CONSTRAINT commentaire_pk PRIMARY KEY (id_compte,id_recette)
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
    pwd varchar(30)  NULL,
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
    CONSTRAINT inscrit_pk PRIMARY KEY (id_compte,id_atelier)
);

-- Table: recette
CREATE TABLE recette (
    id serial  NOT NULL,
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
    somme money  NOT NULL,
    CONSTRAINT transaction_pk PRIMARY KEY (id_compte)
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
