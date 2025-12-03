package com.douradelivery;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    
    @GetMapping("/")
    public String home() {
        return "Backend funcionando! ✅";
    }
    
    @GetMapping("/test")
    public String test() {
        return "Teste OK! 🎉";
    }
    
    @GetMapping("/status")
    public String status() {
        return "Status: ONLINE";
    }
}
