# BITV 2.0 Accessibility Analysis
Write-Host "=== BITV 2.0 Analysis - BaseScreenLayoutAccessible ===" -ForegroundColor Blue

$file = "lib/screens/base_screen_layout_accessible.dart"
if (Test-Path $file) {
    $content = Get-Content $file -Raw
    
    # Count features
    $semanticsCount = [regex]::Matches($content, "Semantics\(").Count
    $announceCount = [regex]::Matches($content, "announce").Count
    $labelCount = [regex]::Matches($content, "label:").Count
    $hintCount = [regex]::Matches($content, "hint:").Count
    $buttonCount = [regex]::Matches($content, "button: true").Count
    $headerCount = [regex]::Matches($content, "header: true").Count
    
    Write-Host "Semantics Widgets: $semanticsCount" -ForegroundColor Green
    Write-Host "Announcements: $announceCount" -ForegroundColor Green  
    Write-Host "Labels: $labelCount" -ForegroundColor Green
    Write-Host "Hints: $hintCount" -ForegroundColor Green
    Write-Host "Buttons: $buttonCount" -ForegroundColor Green
    Write-Host "Headers: $headerCount" -ForegroundColor Green
    
    $score = ($semanticsCount * 10) + ($announceCount * 8) + ($labelCount * 5) + ($hintCount * 5) + ($buttonCount * 8) + ($headerCount * 10)
    Write-Host "Accessibility Score: $score points" -ForegroundColor Yellow
    
    if ($score -gt 200) {
        Write-Host "BITV 2.0 Compliance: EXCELLENT" -ForegroundColor Green
    } elseif ($score -gt 100) {
        Write-Host "BITV 2.0 Compliance: GOOD" -ForegroundColor Yellow
    } else {
        Write-Host "BITV 2.0 Compliance: NEEDS IMPROVEMENT" -ForegroundColor Red
    }
} else {
    Write-Host "File not found!" -ForegroundColor Red
}