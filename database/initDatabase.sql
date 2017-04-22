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

CREATE TABLE atelier (
  id INT PRIMARY KEY,
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
  id_membre INT,
  content TEXT,
  FOREIGN KEY(id_recette) REFERENCES recette(id),
  FOREIGN KEY(id_membre) REFERENCES compte(id)
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

CREATE OR REPLACE FUNCTION ADD_MEMBERS(email_ VARCHAR(255), pwd_ TEXT, status_ VARCHAR(30))
       RETURNS INT AS
$$
BEGIN
        PERFORM * from compte where compte.email = email_;
        IF found = TRUE THEN
           RETURN 0;
        END IF;
        INSERT INTO compte(email, pwd, status, token) VALUES (email_, pwd_, status_, NULL);
        RETURN 1;
        EXCEPTION
        WHEN OTHERS THEN RETURN 0;  
END;
$$ LANGUAGE plpgsql;
