# Teste de registro simples
$BASE_URL = "https://douradelivery-production.up.railway.app"

Write-Host "🧪 Testando registro simples..."

# Teste com dados mínimos
$registerBody = @{
    name = "Teste Usuario"
    email = "teste.simples@example.com"
    password = "123456"
    userType = "CLIENT"
    cpf = "11144477735"
    birthDate = "1990-01-01"
    phone = "11999999999"
} | ConvertTo-Json

Write-Host "📤 Enviando dados:"
Write-Host $registerBody

try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/api/auth/register" -Method POST -Headers @{"Content-Type"="application/json"} -Body $registerBody -UseBasicParsing
    
    Write-Host "✅ Sucesso! Status: $($response.StatusCode)"
    Write-Host "📥 Resposta:"
    Write-Host $response.Content
}
catch {
    Write-Host "❌ Erro:"
    Write-Host "Status: $($_.Exception.Response.StatusCode)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Resposta: $responseBody"
    }
}
