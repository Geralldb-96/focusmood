package com.focusmood.security;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * Limita intentos fallidos por clave (p. ej. correo + IP) para frenar fuerza bruta.
 * En memoria: con varias instancias del backend debe moverse a Redis.
 */
@Component
public class LoginRateLimiter {

    static final int MAX_FAILURES = 5;
    static final Duration WINDOW = Duration.ofMinutes(15);

    private record Entry(int failures, Instant windowStart) {
    }

    private final ConcurrentHashMap<String, Entry> entries = new ConcurrentHashMap<>();
    private final Clock clock;

    LoginRateLimiter(Clock clock) {
        this.clock = clock;
    }

    public boolean isBlocked(String key) {
        Entry e = entries.get(key);
        if (e == null) {
            return false;
        }
        if (e.windowStart().plus(WINDOW).isBefore(clock.instant())) {
            entries.remove(key, e);
            return false;
        }
        return e.failures() >= MAX_FAILURES;
    }

    public void recordFailure(String key) {
        Instant now = clock.instant();
        if (entries.size() > 10_000) {
            entries.values().removeIf(e -> e.windowStart().plus(WINDOW).isBefore(now));
        }
        entries.merge(key, new Entry(1, now), (old, ignored) -> old.windowStart().plus(WINDOW).isBefore(now)
                ? new Entry(1, now)
                : new Entry(old.failures() + 1, old.windowStart()));
    }

    public void reset(String key) {
        entries.remove(key);
    }
}
