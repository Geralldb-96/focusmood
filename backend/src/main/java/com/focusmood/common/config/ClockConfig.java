package com.focusmood.common.config;

import java.time.Clock;
import java.time.ZoneId;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Reloj inyectable: permite probar la lógica dependiente del tiempo y fija la zona horaria de "hoy". */
@Configuration
public class ClockConfig {

    @Bean
    Clock clock(@Value("${focusmood.zone:America/Bogota}") String zone) {
        return Clock.system(ZoneId.of(zone));
    }
}
