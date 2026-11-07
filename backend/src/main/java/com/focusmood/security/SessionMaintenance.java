package com.focusmood.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** Limpieza diaria de sesiones vencidas o revocadas. */
@Component
@EnableScheduling
class SessionMaintenance {

    private static final Logger log = LoggerFactory.getLogger(SessionMaintenance.class);

    private final SessionService sessions;

    SessionMaintenance(SessionService sessions) {
        this.sessions = sessions;
    }

    @Scheduled(cron = "0 15 3 * * *")
    void purge() {
        log.info("Sesiones purgadas: {}", sessions.purgeExpired());
    }
}
