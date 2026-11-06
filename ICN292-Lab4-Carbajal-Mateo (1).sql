-- ============================================================
-- ICN-292 Sistemas de Información para la Gestión
-- Laboratorio 4 - Austral Editores (MySQL 8)
-- Entregable 1: creación de la base | Entregable 2: consultas
-- ============================================================

DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;

-- MySQL Workbench trae activado el modo "Safe Updates", que bloquea
-- DELETE/UPDATE con WHERE sobre columnas no clave (error 1175).
SET SQL_SAFE_UPDATES = 0;

-- ------------------------------------------------------------
-- ENTREGABLE 1: TABLAS
-- ------------------------------------------------------------

-- El país puede quedar vacío (NULL); el género admite solo 5 valores.
CREATE TABLE autores (
    id_autor INT NOT NULL AUTO_INCREMENT,
    nombre   VARCHAR(80) NOT NULL,
    pais     VARCHAR(50),
    genero   ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Tabla que faltaba en el diagrama entregado (la referencia libros.id_coleccion).
CREATE TABLE colecciones (
    id_coleccion      INT NOT NULL AUTO_INCREMENT,
    titulo            VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- id_coleccion admite NULL: la carga oficial no trae colecciones.
CREATE TABLE libros (
    id_libro            INT NOT NULL AUTO_INCREMENT,
    id_autor            INT NOT NULL,
    id_coleccion        INT,
    titulo              VARCHAR(120) NOT NULL,
    paginas             INT,
    ejemplares_vendidos INT,
    anio                INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones (id_coleccion)
);

-- Segunda tabla que faltaba: pagos hechos a los autores.
CREATE TABLE pagos (
    id_pago    INT NOT NULL AUTO_INCREMENT,
    id_autor   INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor)
);

-- ------------------------------------------------------------
-- ENTREGABLE 1: CARGA OFICIAL
-- (los id los asigna AUTO_INCREMENT, en el orden de la carga)
-- ------------------------------------------------------------

INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

-- id_autor: 1 Elena, 2 Harold, 3 Rodrigo, 4 Valentina, 5 Nora (Kenji no tiene libros).
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 'Cielo de Enero',     210, 1500, 2024),
    (1, 'Marea Baja',         185,  800, 2023),
    (1, 'El Norte',           200, 2200, 2024),
    (2, 'Estrellas que Caen', 240, 3000, 2022),
    (2, 'Máquinas',           215,  450, 2024),
    (3, 'Luz Artificial',     300, 1200, 2024),
    (3, 'Ruido Blanco',       280,  600, 2023),
    (4, 'El Barrio de Lila',  190, 5000, 2024),
    (4, 'Antes del Amanecer', 205, 2700, 2024),
    (4, 'La Calle 8',         175,  900, 2023),
    (5, 'Flor de Hierro',     195, 4100, 2024),
    (5, 'Hora Dorada',        220, 1800, 2022);

-- ------------------------------------------------------------
-- ENTREGABLE 2: CONSULTAS
-- Las consultas 1 a 6 se ejecutan sobre la carga oficial,
-- antes de las modificaciones de las consultas 7 y 8.
-- ------------------------------------------------------------

-- [Q1] Autores cuyo país no es Chile, incluyendo a quien no tiene país.
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- [Q2] Libros de 190 a 220 páginas (extremos incluidos), de mayor a menor.
SELECT titulo, paginas
FROM libros
WHERE paginas >= 190 AND paginas <= 220
ORDER BY paginas DESC;

-- [Q3] Una sola fila con las cuatro métricas del catálogo.
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares
FROM libros;

-- [Q4] Géneros distintos de los autores, en orden alfabético.
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- [Q5] Autores con más de un libro publicado en 2024 y cuántos son.
SELECT a.nombre AS autor, COUNT(*) AS libros_2024
FROM autores a
JOIN libros l ON l.id_autor = a.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- [Q6] Libros de 2024 con más de 2000 ejemplares: solo los tres primeros.
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- [Q7a] Inserta el libro 'Papel Mojado' (id_autor 3 = Rodrigo Bahamonde).
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

-- [Q7b] SELECT previo con el mismo criterio del DELETE: la fila que se va a borrar.
SELECT id_libro, id_autor, titulo, paginas, ejemplares_vendidos, anio
FROM libros
WHERE titulo = 'Papel Mojado';

-- [Q7c] DELETE que filtra por título.
DELETE FROM libros
WHERE titulo = 'Papel Mojado';

-- [Q7d] SELECT posterior: no debe devolver filas.
SELECT id_libro, id_autor, titulo, paginas, ejemplares_vendidos, anio
FROM libros
WHERE titulo = 'Papel Mojado';

-- [Q8a] SELECT previo con el mismo WHERE del UPDATE.
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- [Q8b] UPDATE: el nuevo valor se calcula a partir del actual.
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- [Q8c] SELECT posterior.
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- ------------------------------------------------------------
-- DATOS DE PRUEBA PARA LAS CONSULTAS 9 Y 10
-- (la carga oficial no trae colecciones ni pagos)
-- ------------------------------------------------------------

INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Voces del Sur',      '2025-03-14'),
    ('Clásicos Australes', '2025-09-01'),
    ('Nueva Narrativa',    '2026-04-23');

-- Se asignan los doce libros: ids 1-4, 5-8 y 9-12.
UPDATE libros SET id_coleccion = 1 WHERE id_libro <= 4;
UPDATE libros SET id_coleccion = 2 WHERE id_libro >= 5 AND id_libro <= 8;
UPDATE libros SET id_coleccion = 3 WHERE id_libro >= 9 AND id_libro <= 12;

-- Cuatro pagos; Elena Pizarro (1) recibe dos.
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (1, '2026-03-10', 250000.50),
    (1, '2026-06-10', 180000.00),
    (4, '2026-05-20', 320000.75),
    (5, '2026-07-01', 410000.00);

-- [Q9] Libro, colección a la que pertenece y fecha de publicación de la colección.
SELECT l.titulo AS libro,
       c.titulo AS coleccion,
       c.fecha_publicacion
FROM libros l
JOIN colecciones c ON c.id_coleccion = l.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- [Q10a] Pagos hechos a los autores: nombre, fecha y monto.
SELECT a.nombre AS autor, p.fecha_pago, p.monto
FROM pagos p
JOIN autores a ON a.id_autor = p.id_autor
ORDER BY a.nombre, p.fecha_pago;

-- [Q10b] Total pagado a cada autor.
SELECT a.nombre AS autor, SUM(p.monto) AS total_pagado
FROM pagos p
JOIN autores a ON a.id_autor = p.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre;
