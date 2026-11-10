package com.focusmood;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class FocusMoodApplication {

    public static void main(String[] args) {
        SpringApplication.run(FocusMoodApplication.class, args);
    }
}
