package com.douradelivery;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, HibernateJpaAutoConfiguration.class})
@Profile("minimal")
public class MinimalApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(MinimalApplication.class, args);
    }
    
    @RestController
    public static class TestController {
        
        @GetMapping("/")
        public String home() {
            return "Backend funcionando! ✅";
        }
        
        @GetMapping("/test")
        public String test() {
            return "Teste OK! 🎉";
        }
    }
}
