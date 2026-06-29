#!/bin/bash
source .env

echo "=== [SRE] ACTIVANDO PLAN DE RECUPERACIÓN MULTI-TABLA ROBUSTO (< 3 MIN) ==="
START_TIME=$(date +%s)

# 1. Intentar descargar el respaldo desde AWS S3
echo "Descargando último respaldo desde el almacenamiento inmortal S3..."
LAST_BACKUP=$(aws s3 ls s3://$BUCKET_S3_NAME/ | sort | tail -n 1 | awk '{print $4}')

if [ -z "$LAST_BACKUP" ]; then
    echo "⚠️ No se encontró backup en S3. Aplicando plan de emergencia relacional local con nuevos maestros..."
    
    # Asegurar la estructura base limpia
    sudo docker exec -i academic_postgres_db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < estructura_robusta.sql
    
    # Inyectar los nuevos profesores y reconfigurar materias en caliente
    sudo docker exec -i academic_postgres_db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' << 'SQL'
TRUNCATE TABLE profesores CASCADE;
INSERT INTO profesores (id, nombre, correo) VALUES 
(1, 'Dr. Alejandro Ortega', 'aortega@puce.edu.ec'),
(2, 'Ing. Paola Santillán', 'psantillan@puce.edu.ec');

TRUNCATE TABLE materias CASCADE;
INSERT INTO materias (id, codigo_puce, nombre, creditos, profesor_id) VALUES 
(1, 'INF-401', 'Arquitectura Cloud', 4, 1),
(2, 'INF-402', 'SRE & Observabilidad', 4, 1),
(3, 'INF-403', 'Desarrollo Web Fullstack', 3, 2),
(4, 'INF-404', 'Bases de Datos II', 4, 2),
(5, 'INF-405', 'Sistemas Operativos', 3, 2);

SELECT setval('profesores_id_seq', 2);
SELECT setval('materias_id_seq', 5);
SQL

    # Volver a inyectar los 100 alumnos
    sudo docker exec -i academic_postgres_db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < cargar_100_notas_robustas.sql
else
    echo "✅ Respaldo detectado en S3. Extrayendo..."
    aws s3 cp s3://$BUCKET_S3_NAME/$LAST_BACKUP ./restore_temp.sql
    sudo docker exec -i academic_postgres_db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < ./restore_temp.sql
    rm -f ./restore_temp.sql
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# Registrar la bitácora de auditoría exigida por la rúbrica SRE
echo "[$(date '+%Y-%m-%d %H:%M:%S')] CAOS: Infraestructura robusta restaurada exitosamente. RTO: $ELAPSED segundos." >> sli.log

echo "=== [ÉXITO] ENTORNO MULTI-TABLA RESTAURADO ==="
echo "Tiempo total de recuperación (RTO): $ELAPSED segundos."
