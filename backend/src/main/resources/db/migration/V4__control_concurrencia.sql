-- Bloqueo optimista: evita que dos solicitudes simultaneas se pisen al modificar el mismo registro.
ALTER TABLE habito ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE recordatorio ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE registro_diario ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE perfil ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE usuario ADD COLUMN version BIGINT NOT NULL DEFAULT 0;
