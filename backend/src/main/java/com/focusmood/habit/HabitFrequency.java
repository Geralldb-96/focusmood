package com.focusmood.habit;

import java.time.DayOfWeek;
import java.time.LocalDate;

/** Frecuencia del hábito y cuántos cumplimientos se esperan en un rango de fechas. */
public enum HabitFrequency {
    DAILY {
        @Override
        public int expectedBetween(LocalDate from, LocalDate to) {
            return (int) (to.toEpochDay() - from.toEpochDay() + 1);
        }
    },
    WEEKDAYS {
        @Override
        public int expectedBetween(LocalDate from, LocalDate to) {
            int count = 0;
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                if (d.getDayOfWeek() != DayOfWeek.SATURDAY && d.getDayOfWeek() != DayOfWeek.SUNDAY) {
                    count++;
                }
            }
            return count;
        }
    },
    WEEKLY {
        @Override
        public int expectedBetween(LocalDate from, LocalDate to) {
            int days = (int) (to.toEpochDay() - from.toEpochDay() + 1);
            return (days + 6) / 7;
        }
    };

    /** Cumplimientos esperados en [from, to], ambos inclusive. Devuelve 0 si el rango es vacío. */
    public abstract int expectedBetween(LocalDate from, LocalDate to);
}
