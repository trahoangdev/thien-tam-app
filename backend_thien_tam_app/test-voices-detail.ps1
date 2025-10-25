# Test ElevenLabs Voice IDs for Vietnamese

Write-Host "=== Testing ElevenLabs Vietnamese Voices ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:4000"

# Voice IDs to test
$voices = @(
    @{
        id = "DvG3I1kDzdBY3u4EzYh6"
        name = "Female Calm (giọng nữ)"
        color = "Magenta"
    },
    @{
        id = "DXiwi9uoxet6zAiZXynP"
        name = "Male Default (giọng nam)"
        color = "Cyan"
    }
)

$testText = "Nam mô Bổn Sư Thích Ca Mâu Ni Phật. Xin chào quý Phật tử."

foreach ($voice in $voices) {
    Write-Host "Testing: $($voice.name)" -ForegroundColor $voice.color
    Write-Host "Voice ID: $($voice.id)" -ForegroundColor Gray
    
    $body = @{
        text = $testText
        voiceId = $voice.id
    } | ConvertTo-Json

    $outputFile = "test-voice-$($voice.id.Substring(0,8)).mp3"
    
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/tts/text-to-speech" `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -OutFile $outputFile
        
        if (Test-Path $outputFile) {
            $fileSize = (Get-Item $outputFile).Length
            if ($fileSize -gt 1000) {
                Write-Host "✅ SUCCESS! Audio generated: $outputFile" -ForegroundColor Green
                Write-Host "   File size: $([math]::Round($fileSize / 1KB, 2)) KB" -ForegroundColor Green
            } else {
                Write-Host "⚠️  WARNING: File too small ($fileSize bytes)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ FAILED: No output file created" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Testing completed!" -ForegroundColor Green
Write-Host ""
Write-Host "If voices fail, they might not support Vietnamese." -ForegroundColor Yellow
Write-Host "Check ElevenLabs dashboard for Vietnamese-compatible voices." -ForegroundColor Yellow

