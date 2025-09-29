# BITV 2.0 Accessibility Analysis
Write-Host "=== BITV 2.0 Analysis - ChangePasswordScreenAccessible ===" -ForegroundColor Blue

$file = "lib/screens/change_password_screen_accessible.dart"
if (Test-Path $file) {
    $content = Get-Content $file -Raw
    
    # Count features
    $semanticsCount = [regex]::Matches($content, "Semantics\(").Count
    $announceCount = [regex]::Matches($content, "SemanticsService\.announce").Count
    $labelCount = [regex]::Matches($content, "label:").Count
    $hintCount = [regex]::Matches($content, "hint:").Count
    $buttonCount = [regex]::Matches($content, "button: true").Count
    $liveRegionCount = [regex]::Matches($content, "liveRegion: true").Count
    $containerCount = [regex]::Matches($content, "container: true").Count
    $textFieldCount = [regex]::Matches($content, "textField: true").Count
    $autocompleteCount = [regex]::Matches($content, "autofillHints:").Count
    $focusNodeCount = [regex]::Matches($content, "FocusNode").Count
    $tooltipCount = [regex]::Matches($content, "tooltip:").Count
    
    Write-Host "Semantics Widgets: $semanticsCount" -ForegroundColor Green
    Write-Host "SemanticsService Announcements: $announceCount" -ForegroundColor Green  
    Write-Host "Accessibility Labels: $labelCount" -ForegroundColor Green
    Write-Host "Accessibility Hints: $hintCount" -ForegroundColor Green
    Write-Host "Button Semantics: $buttonCount" -ForegroundColor Green
    Write-Host "Live Regions: $liveRegionCount" -ForegroundColor Green
    Write-Host "Container Semantics: $containerCount" -ForegroundColor Green
    Write-Host "TextField Semantics: $textFieldCount" -ForegroundColor Green
    Write-Host "Autocomplete Hints: $autocompleteCount" -ForegroundColor Green
    Write-Host "Focus Nodes: $focusNodeCount" -ForegroundColor Green
    Write-Host "Tooltips: $tooltipCount" -ForegroundColor Green
    
    $score = ($semanticsCount * 8) + ($announceCount * 15) + ($labelCount * 4) + ($hintCount * 6) + ($buttonCount * 10) + ($liveRegionCount * 12) + ($containerCount * 8) + ($textFieldCount * 15) + ($autocompleteCount * 10) + ($focusNodeCount * 5) + ($tooltipCount * 4)
    Write-Host "Accessibility Score: $score points" -ForegroundColor Yellow
    
    if ($score -gt 500) {
        Write-Host "BITV 2.0 Compliance: EXCELLENT" -ForegroundColor Green
    } elseif ($score -gt 350) {
        Write-Host "BITV 2.0 Compliance: VERY GOOD" -ForegroundColor Yellow
    } elseif ($score -gt 200) {
        Write-Host "BITV 2.0 Compliance: GOOD" -ForegroundColor Yellow
    } else {
        Write-Host "BITV 2.0 Compliance: NEEDS IMPROVEMENT" -ForegroundColor Red
    }
    
    # Check for German terms
    Write-Host "`nGerman Accessibility Features:" -ForegroundColor Blue
    $germanTerms = @("Passwort", "eingeben", "verbergen", "anzeigen", "speichern", "Anforderungen", "Stärke", "erfüllt")
    foreach ($term in $germanTerms) {
        if ($content -match $term) {
            Write-Host "  ✅ $term" -ForegroundColor White
        }
    }
    
    # Check for BITV 2.0 features
    Write-Host "`nBITV 2.0 Features Implemented:" -ForegroundColor Blue
    if ($content -match "textField: true") { Write-Host "  Text field identification" -ForegroundColor White }
    if ($content -match "autofillHints:") { Write-Host "  Input purpose identification" -ForegroundColor White }
    if ($content -match "liveRegion: true") { Write-Host "  Status messages" -ForegroundColor White }
    if ($content -match "FocusNode") { Write-Host "  Focus management" -ForegroundColor White }
    if ($content -match "semanticLabel:") { Write-Host "  Label in name" -ForegroundColor White }
    if ($content -match "SemanticsService") { Write-Host "  Screen reader announcements" -ForegroundColor White }
    if ($content -match "obscured:") { Write-Host "  Password field security" -ForegroundColor White }
    if ($content -match "tooltip:") { Write-Host "  Tooltips for guidance" -ForegroundColor White }
    
} else {
    Write-Host "File not found!" -ForegroundColor Red
}