/*Ejercicio Nivel 1 

Se crea la tabla user teniendo en cuenta la distribucion de los datos en los archivos csv "users_ca", "users_uk" y "users_usa", el campo id es la primary key*/
CREATE DATABASE sp4;
use sp4;

CREATE TABLE user (
id INT PRIMARY KEY,
nombre VARCHAR(50),
apellido VARCHAR(50),
telefono VARCHAR(50),
email VARCHAR(50),
fecha_de_nacimiento VARCHAR(50),
pais VARCHAR(50),
ciudad VARCHAR(50),
codigo_postal VARCHAR(50),
direccion VARCHAR(100)
);

SET GLOBAL local_infile = 'ON';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE user
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

/*CREACION DE LA TABLA COMPANY*/

CREATE TABLE company (
id VARCHAR(50) PRIMARY KEY,
nombre VARCHAR(50),
telefono VARCHAR(50),
email VARCHAR(50),
pais VARCHAR(50),
website VARCHAR(100)
);

/*SE IMPORTAN LOS DATOS DEL ARCHIVO COMPANIES.CSV*/

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE company
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

/*CREACION DE LA TABLA credit_cards*/

CREATE TABLE credit_cards (
id VARCHAR(50) PRIMARY KEY,
user_id int,
iban VARCHAR(50),
pan VARCHAR(50),
pin int,
cvv int,
track1 VARCHAR(150),
track2 VARCHAR(150),
expiring_date VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

/*CREACION DE LA TABLA products*/

CREATE TABLE products (
id INT PRIMARY KEY,
product_name VARCHAR(50),
price VARCHAR(50),
colour VARCHAR(50),
weight DOUBLE,
warehouse_id VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

/*CREACION DE LA TABLA transactions*/

CREATE TABLE transactions (
id VARCHAR(50) PRIMARY KEY,
card_id VARCHAR(50),
business_id VARCHAR(50),
timestamp DATE,
amount DOUBLE,
declined int,
product_ids VARCHAR(150),
user_id INT,
lat DOUBLE,
longitude DOUBLE
);

/*SE IMPORTAN LOS DATOS DEL ARCHIVO transactions.CSV
y se crean las FK*/

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Ignora la primera línea si contiene encabezados

ALTER TABLE transactions
ADD FOREIGN KEY (card_id) REFERENCES credit_cards(id),
ADD FOREIGN KEY (business_id) REFERENCES company(id),
ADD FOREIGN KEY (user_id) REFERENCES user(id);

#Ejercicio 1

SELECT u.id AS UserId, concat(u.nombre, ' ', u.apellido) AS User, count(t.id) AS No_operaciones
FROM user u
JOIN transactions t ON u.id = t.user_id
GROUP BY UserId
HAVING No_operaciones > 30;

# Ejercicio 2

SELECT format(AVG(t.amount), 2) AS Media_de_gasto, cc.iban AS Iban
FROM credit_cards cc
JOIN transactions t ON t.card_id = cc.id
JOIN company c ON t.business_id = c.id
WHERE c.nombre = "Donec Ltd"
GROUP BY Iban;

#Ejercicio Nivel 2

CREATE TABLE Status (
SELECT last3.Card_id, (
CASE
    WHEN sum(last3.declined) = 3 THEN 'Inactiva'
	ELSE 'Activa'
END) as Status
FROM (SELECT card_id, declined, timestamp
 FROM (SELECT t.declined, t.card_id, t.timestamp,
     @rown := IF(@target = t.card_id, @rown + 1, 1) AS rown, @target := t.card_id 
        FROM transactions t JOIN (SELECT @target = NULL, @rown = 0) 
AS Bucle ORDER BY t.card_id, t.timestamp DESC, t.declined ) AS T1 WHERE rown <= 3) AS last3
GROUP BY card_id);

ALTER TABLE status
ADD PRIMARY KEY (card_id);

ALTER TABLE transactions
ADD FOREIGN KEY (card_id) REFERENCES status (card_id);


SELECT count(status) AS Total_Tarjetas_Activas
FROM status
WHERE status = "Activa";

#Ejercicio Nv3

CREATE TABLE Prods_Transaction (
SELECT 
    t.id AS id,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', n.n), ',', -1) AS UNSIGNED) AS pid
FROM 
    transactions t
CROSS JOIN 
    (SELECT @prods := @prods + 1 AS n
     FROM (SELECT @prods := 0) r
     CROSS JOIN transactions
     WHERE declined = 0) n
WHERE 
    n.n <= LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ',', '')) + 1 AND t.declined = 0);

ALTER TABLE Prods_Transaction MODIFY pid int,
ADD FOREIGN KEY (id) REFERENCES transactions(id),
ADD FOREIGN KEY (pid) REFERENCES products(id);


SELECT p.id AS Product_Id, p.product_name, COUNT(pt.pid) Total_Vendido
FROM products p
LEFT JOIN prods_transaction pt ON pt.pid = p.id
GROUP BY Product_Id
ORDER BY Product_Id ASC;
