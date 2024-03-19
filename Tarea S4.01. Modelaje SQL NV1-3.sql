/*Ejercicio Nivel 1 

Se crea la tabla user teniendo en cuenta la distribucion de los datos en los archivos csv "users_ca", "users_uk" y "users_usa"
manteniendo la caracteristica de autoincremento del campo id que es la primary key*/

CREATE TABLE user (
id INT PRIMARY KEY AUTO_INCREMENT,
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

/*Se hace la importacion de los datos mediante el "Table data import wizard".*/

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

#Se crea la tabla products

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
product_name VARCHAR(50),
price VARCHAR(50),
colour VARCHAR(50),
weight DOUBLE,
warehouse_id VARCHAR(50)
);

/*SE IMPORTAN LOS DATOS DEL ARCHIVO products.CSV

se crea la tabla transactions*/

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

ALTER TABLE transactions
ADD FOREIGN KEY (card_id) REFERENCES credit_cards(id),
ADD FOREIGN KEY (business_id) REFERENCES company(id),
ADD FOREIGN KEY (user_id) REFERENCES user(id);

#Ejercicio 1

SELECT u.id AS Usuario, count(t.id) AS No_operaciones
FROM user u
JOIN transactions t ON u.id = t.user_id
GROUP BY Usuario
HAVING No_operaciones > 30;

# Ejercicio 2

SELECT AVG(t.amount) AS Media_de_gasto, cc.iban AS Iban
FROM credit_cards cc
JOIN transactions t ON t.card_id = cc.id
JOIN company c ON t.business_id = c.id
WHERE c.nombre IN ("Donec Ltd")
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
        FROM transactions t JOIN (SELECT @target := NULL, @rown := 0) 
AS Bucle ORDER BY t.card_id, t.timestamp DESC, t.declined ) AS T1 WHERE rown <= 3) AS last3
GROUP BY card_id);

SELECT * 
FROM status;

#Ejercicio Nv3

CREATE TABLE Prods_Transaction (
SELECT id, pid
FROM (
	SELECT id, @num := 1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) AS num,
		IF(@num >= 1, SUBSTRING_INDEX(product_ids, ',', 1), NULL) AS PID
	FROM transactions t
    where t.declined = 0) AS pdi1
UNION ALL 
SELECT id, pid
FROM (
	SELECT id, @num := 1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) AS num,
		IF(@num > 1, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1), NULL) AS PID
	FROM transactions t
    where t.declined = 0) AS pdi2
UNION ALL
SELECT id, pid
FROM (
	SELECT id, @num := 1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) AS num,
		IF(@num > 2, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1), NULL) AS PID
	FROM transactions t
    where t.declined = 0) AS pdi3
UNION ALL
SELECT id, pid
FROM (
	SELECT id, @num := 1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) AS num,
		IF(@num > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1), NULL) AS PID
	FROM transactions t
    where t.declined = 0) AS pdi4
);

ALTER TABLE Prods_Transaction MODIFY pid int,
ADD FOREIGN KEY (id) REFERENCES transactions(id),
ADD FOREIGN KEY (pid) REFERENCES products(id);

SELECT p.id AS Producto, COUNT(pt.pid) Total_Vendido
FROM products p
JOIN prods_transaction pt ON pt.pid = p.id
GROUP BY Producto
ORDER BY Producto ASC;