package com.douradelivery.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SimpleHealthController {
    
    @GetMapping("/")
    public String root() {
        return "DouraDelivery Backend is running! ✅";
    }
    
    @GetMapping("/ping")
    public String ping() {
        return "pong";
    }
}
