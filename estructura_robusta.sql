-- 1. Limpiar tablas anteriores en orden inverso por las llaves foráneas
DROP TABLE IF EXISTS estudiantes;
DROP TABLE IF EXISTS materias;
DROP TABLE IF EXISTS profesores;

-- 2. Crear Tabla de Profesores
CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL
);

-- 3. Crear Tabla de Materias (Conectada a Profesores)
CREATE TABLE materias (
    id SERIAL PRIMARY KEY,
    codigo_puce VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    creditos INT NOT NULL,
    profesor_id INT REFERENCES profesores(id) ON DELETE SET NULL
);

-- 4. Crear Tabla de Estudiantes Normalizada (Conectada a Materias)
CREATE TABLE estudiantes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    materia_id INT REFERENCES materias(id) ON DELETE CASCADE,
    nota NUMERIC(4,2) NOT NULL CHECK (nota >= 0 AND nota <= 10)
);

-- INYECCIÓN DE DATOS MAESTROS DE PRUEBA
INSERT INTO profesores (nombre, correo) VALUES 
('Bryan Celi', 'bceli@puce.edu.ec'),
('Ing. Orquestación', 'cloud.docente@puce.edu.ec');

INSERT INTO materias (codigo_puce, nombre, creditos, profesor_id) VALUES 
('INF-401', 'Arquitectura Cloud', 4, 1),
('INF-402', 'SRE & Observabilidad', 4, 1),
('INF-403', 'Desarrollo Web Fullstack', 3, 2),
('INF-404', 'Bases de Datos II', 4, 2),
('INF-405', 'Sistemas Operativos', 3, 2);
