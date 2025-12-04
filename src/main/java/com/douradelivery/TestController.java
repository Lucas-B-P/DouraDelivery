package com.douradelivery;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    
    @GetMapping("/")
    public String home() {
        return "🚀 DouraDelivery API ONLINE! ✅";
    }
    
    @GetMapping("/test")
    public String test() {
        return "✅ Teste OK! Backend funcionando perfeitamente! 🎉";
    }
    
    @GetMapping("/status")
    public String status() {
        return "Status: ONLINE - Railway Deploy Success! 🚀";
    }
    
    @GetMapping("/health")
    public String health() {
        return "✅ HEALTHY - Spring Boot + MySQL + Railway";
    }
}
