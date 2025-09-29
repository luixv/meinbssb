# BITV 2.0 Accessibility Analysis
Write-Host "=== BITV 2.0 Analysis - AusweisBestellenScreenAccessible ===" -ForegroundColor Blue

$file = "lib/screens/ausweis_bestellen_screen_accessible.dart"
if (Test-Path $file) {
    $content = Get-Content $file -Raw
    
    # Count features
    $semanticsCount = [regex]::Matches($content, "Semantics\(").Count
    $announceCount = [regex]::Matches($content, "announce").Count
    $labelCount = [regex]::Matches($content, "label:").Count
    $hintCount = [regex]::Matches($content, "hint:").Count
    $buttonCount = [regex]::Matches($content, "button: true").Count
    $liveRegionCount = [regex]::Matches($content, "liveRegion: true").Count
    $containerCount = [regex]::Matches($content, "container: true").Count
    $readOnlyCount = [regex]::Matches($content, "readOnly: true").Count
    
    Write-Host "Semantics Widgets: $semanticsCount" -ForegroundColor Green
    Write-Host "Announcements: $announceCount" -ForegroundColor Green  
    Write-Host "Labels: $labelCount" -ForegroundColor Green
    Write-Host "Hints: $hintCount" -ForegroundColor Green
    Write-Host "Buttons: $buttonCount" -ForegroundColor Green
    Write-Host "Live Regions: $liveRegionCount" -ForegroundColor Green
    Write-Host "Containers: $containerCount" -ForegroundColor Green
    Write-Host "ReadOnly Elements: $readOnlyCount" -ForegroundColor Green
    
    $score = ($semanticsCount * 8) + ($announceCount * 12) + ($labelCount * 5) + ($hintCount * 7) + ($buttonCount * 10) + ($liveRegionCount * 15) + ($containerCount * 6) + ($readOnlyCount * 4)
    Write-Host "Accessibility Score: $score points" -ForegroundColor Yellow
    
    if ($score -gt 300) {
        Write-Host "BITV 2.0 Compliance: EXCELLENT" -ForegroundColor Green
    } elseif ($score -gt 200) {
        Write-Host "BITV 2.0 Compliance: VERY GOOD" -ForegroundColor Yellow
    } elseif ($score -gt 100) {
        Write-Host "BITV 2.0 Compliance: GOOD" -ForegroundColor Yellow
    } else {
        Write-Host "BITV 2.0 Compliance: NEEDS IMPROVEMENT" -ForegroundColor Red
    }
    
    # Check for German terms
    Write-Host "`nGerman Accessibility Terms Found:" -ForegroundColor Blue
    $germanTerms = @("Schützenausweis", "bestellen", "Bestellung", "Fehler", "erfolgreich", "verarbeitet", "Bestätigung")
    foreach ($term in $germanTerms) {
        if ($content -match $term) {
            Write-Host "  ✅ $term" -ForegroundColor White
        }
    }
} else {
    Write-Host "File not found!" -ForegroundColor Red
}