-- Sesiones de usuario: cada login crea una sesion revocable en servidor.
-- El refresh token nunca se guarda en claro, solo su hash SHA-256.
CREATE TABLE sesion_usuario (
    id_sesion_usuario     VARCHAR(36) PRIMARY KEY,
    id_usuario            BIGINT NOT NULL,
    refresh_hash          VARCHAR(64) NOT NULL,
    refresh_hash_anterior VARCHAR(64),
    creada_en             TIMESTAMP WITH TIME ZONE NOT NULL,
    ultimo_uso            TIMESTAMP WITH TIME ZONE NOT NULL,
    expira_en             TIMESTAMP WITH TIME ZONE NOT NULL,
    revocada              BOOLEAN NOT NULL DEFAULT FALSE,
    dispositivo           VARCHAR(255),
    ip                    VARCHAR(45),
    CONSTRAINT fk_sesion_usuario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
);
CREATE INDEX idx_sesion_usuario_usuario ON sesion_usuario (id_usuario);
CREATE INDEX idx_sesion_usuario_expira ON sesion_usuario (expira_en);
