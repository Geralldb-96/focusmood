# Base de datos

FocusMood utiliza PostgreSQL. Las migraciones ejecutables se mantienen junto al backend para que Flyway las aplique automáticamente desde:

`backend/src/main/resources/db/migration/`

No se deben duplicar aquí, porque dos copias podrían divergir. La carpeta `backups/` queda reservada para respaldos locales y estos no deben contener información personal real ni subirse al repositorio.

Para iniciar PostgreSQL y el backend desde la raíz del proyecto:

```sh
docker compose --env-file .env -f infrastructure/docker/compose.yml up --build
```
