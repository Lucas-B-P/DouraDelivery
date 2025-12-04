package com.douradelivery.service;

import com.douradelivery.dto.LoginRequest;
import com.douradelivery.dto.RegisterRequest;
import com.douradelivery.model.User;
import com.douradelivery.repository.UserRepository;
import com.douradelivery.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private DocumentValidationService validationService;
    
    public Map<String, Object> login(String email, String password) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validar email
            if (!validationService.isValidEmail(email)) {
                response.put("success", false);
                response.put("message", "Email inválido");
                return response;
            }
            
            // Buscar usuário
            Optional<User> userOpt = userRepository.findByEmailAndActiveTrue(email);
            if (userOpt.isEmpty()) {
                response.put("success", false);
                response.put("message", "Usuário não encontrado ou inativo");
                return response;
            }
            
            User user = userOpt.get();
            
            // Verificar senha
            if (!passwordEncoder.matches(password, user.getPassword())) {
                response.put("success", false);
                response.put("message", "Senha incorreta");
                return response;
            }
            
            // Gerar token JWT
            String token = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getUserType().name());
            
            // Resposta de sucesso
            response.put("success", true);
            response.put("token", token);
            response.put("userType", user.getUserType().name());
            response.put("userId", user.getId());
            response.put("name", user.getName());
            response.put("email", user.getEmail());
            response.put("verificationStatus", user.getVerificationStatus().name());
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Erro interno do servidor: " + e.getMessage());
        }
        
        return response;
    }
    
    public Map<String, Object> register(RegisterRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validações
            String validationError = validateRegistrationRequest(request);
            if (validationError != null) {
                response.put("success", false);
                response.put("message", validationError);
                return response;
            }
            
            // Verificar se email já existe
            if (userRepository.existsByEmail(request.getEmail())) {
                response.put("success", false);
                response.put("message", "Email já cadastrado");
                return response;
            }
            
            // Verificar se CPF já existe
            String cleanCpf = validationService.cleanCPF(request.getCpf());
            if (userRepository.existsByCpf(cleanCpf)) {
                response.put("success", false);
                response.put("message", "CPF já cadastrado");
                return response;
            }
            
            // Criar usuário
            User user = User.builder()
                    .name(request.getName().trim())
                    .email(request.getEmail().toLowerCase().trim())
                    .password(passwordEncoder.encode(request.getPassword()))
                    .userType(User.UserType.valueOf(request.getUserType().toUpperCase()))
                    .cpf(cleanCpf)
                    .birthDate(request.getBirthDate())
                    .phone(validationService.cleanPhone(request.getPhone()))
                    .build();
            
            // Campos específicos para entregadores
            if ("DRIVER".equalsIgnoreCase(request.getUserType())) {
                user.setCnhNumber(validationService.cleanCNH(request.getCnhNumber()));
                user.setCnhCategory(User.CnhCategory.valueOf(request.getCnhCategory()));
                user.setCnhExpiryDate(request.getCnhExpiryDate());
            }
            
            // Salvar no banco
            User savedUser = userRepository.save(user);
            
            // Resposta de sucesso
            response.put("success", true);
            response.put("message", "Usuário registrado com sucesso! Agora você precisa enviar os documentos para verificação.");
            response.put("userId", savedUser.getId());
            response.put("name", savedUser.getName());
            response.put("email", savedUser.getEmail());
            response.put("userType", savedUser.getUserType().name());
            response.put("verificationStatus", savedUser.getVerificationStatus().name());
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Erro interno do servidor: " + e.getMessage());
        }
        
        return response;
    }
    
    private String validateRegistrationRequest(RegisterRequest request) {
        // Validações básicas
        if (request.getName() == null || request.getName().trim().length() < 2) {
            return "Nome deve ter pelo menos 2 caracteres";
        }
        
        if (!validationService.isValidEmail(request.getEmail())) {
            return "Email inválido";
        }
        
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            return "Senha deve ter pelo menos 6 caracteres";
        }
        
        if (!"CLIENT".equalsIgnoreCase(request.getUserType()) && 
            !"DRIVER".equalsIgnoreCase(request.getUserType())) {
            return "Tipo de usuário deve ser CLIENT ou DRIVER";
        }
        
        // Validar CPF
        if (!validationService.isValidCPF(request.getCpf())) {
            return "CPF inválido";
        }
        
        // Validar data de nascimento
        if (!validationService.isValidBirthDate(request.getBirthDate())) {
            return "Data de nascimento inválida (idade deve estar entre 18 e 100 anos)";
        }
        
        // Validar telefone
        if (!validationService.isValidPhone(request.getPhone())) {
            return "Telefone inválido";
        }
        
        // Validações específicas para entregadores
        if ("DRIVER".equalsIgnoreCase(request.getUserType())) {
            if (!validationService.isValidCNH(request.getCnhNumber())) {
                return "Número da CNH inválido";
            }
            
            if (request.getCnhCategory() == null) {
                return "Categoria da CNH é obrigatória para entregadores";
            }
            
            if (!validationService.isValidCNHExpiryDate(request.getCnhExpiryDate())) {
                return "CNH deve estar dentro do prazo de validade";
            }
            
            // Para entregadores, exigir categoria A (moto)
            if (!"A".equals(request.getCnhCategory()) && 
                !"AB".equals(request.getCnhCategory()) && 
                !"AC".equals(request.getCnhCategory()) &&
                !"AD".equals(request.getCnhCategory()) &&
                !"AE".equals(request.getCnhCategory())) {
                return "Entregadores devem ter CNH categoria A (ou AB, AC, AD, AE)";
            }
        }
        
        return null; // Tudo válido
    }
}