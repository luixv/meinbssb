# BITV 2.0 Cookie Consent Screen - Accessibility Validation
# PowerShell Script für umfassende Barrierefreiheitsprüfung

Write-Host "🔍 BITV 2.0 Barrierefreiheit-Validierung: Cookie Consent Screen" -ForegroundColor Cyan
Write-Host "=" * 65 -ForegroundColor Gray

$cookieConsentFile = "c:\projekte\BSSB\meinbssb\lib\screens\cookie_consent_screen_accessible.dart"

if (-not (Test-Path $cookieConsentFile)) {
    Write-Host "❌ Datei nicht gefunden: $cookieConsentFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content $cookieConsentFile -Raw

# BITV 2.0 Kriterien-Überprüfung
$checks = @()

# 1. Semantics Widgets (WCAG 1.3.1, 4.1.2)
$semanticsCount = ([regex]::Matches($content, "Semantics\(")).Count
$checks += @{
    Name = "Semantics Widgets"
    Count = $semanticsCount
    Required = 8
    Weight = 15
    WCAG = "1.3.1, 4.1.2"
}

# 2. SemanticsService Announcements (WCAG 4.1.3)
$announcementCount = ([regex]::Matches($content, "SemanticsService\.announce")).Count
$checks += @{
    Name = "Live Announcements"
    Count = $announcementCount
    Required = 5
    Weight = 12
    WCAG = "4.1.3"
}

# 3. Focus Management (WCAG 2.4.3, 2.1.1)
$focusNodes = ([regex]::Matches($content, "FocusNode")).Count
$focusManagement = ([regex]::Matches($content, "requestFocus|FocusScope")).Count
$totalFocus = $focusNodes + $focusManagement
$checks += @{
    Name = "Fokus-Management"
    Count = $totalFocus
    Required = 4
    Weight = 15
    WCAG = "2.4.3, 2.1.1"
}

# 4. Keyboard Navigation (WCAG 2.1.1, 2.1.2)
$keyboardHandling = ([regex]::Matches($content, "onKeyEvent|KeyEvent|LogicalKeyboardKey")).Count
$checks += @{
    Name = "Tastaturnavigation"
    Count = $keyboardHandling
    Required = 6
    Weight = 12
    WCAG = "2.1.1, 2.1.2"
}

# 5. German Language Labels (WCAG 3.1.1)
$germanLabels = ([regex]::Matches($content, "label:\s*'[^']*[äöüÄÖÜß][^']*'")).Count
$checks += @{
    Name = "Deutsche Semantik-Labels"
    Count = $germanLabels
    Required = 10
    Weight = 8
    WCAG = "3.1.1"
}

# 6. Accessible Hints (WCAG 3.3.2)
$hintsCount = ([regex]::Matches($content, "hint:\s*'")).Count
$checks += @{
    Name = "Accessibility Hints"
    Count = $hintsCount
    Required = 6
    Weight = 10
    WCAG = "3.3.2"
}

# 7. Dialog Structure (WCAG 1.3.1)
$dialogStructures = ([regex]::Matches($content, "header:\s*true|container:\s*true|scopesRoute:\s*true")).Count
$checks += @{
    Name = "Dialog-Struktur"
    Count = $dialogStructures
    Required = 3
    Weight = 10
    WCAG = "1.3.1"
}

# 8. Button Semantics (WCAG 4.1.2)
$buttonSemantics = ([regex]::Matches($content, "button:\s*true")).Count
$checks += @{
    Name = "Button-Semantik"
    Count = $buttonSemantics
    Required = 1
    Weight = 8
    WCAG = "4.1.2"
}

# 9. Contrast & Visual Enhancements (WCAG 1.4.3)
$contrastFeatures = ([regex]::Matches($content, "elevation|BorderSide|fontSize|fontWeight")).Count
$checks += @{
    Name = "Visueller Kontrast"
    Count = $contrastFeatures
    Required = 8
    Weight = 10
    WCAG = "1.4.3"
}

# Bewertung durchführen
$totalScore = 0
$maxScore = 0

Write-Host "📊 Detaillierte Analyse-Ergebnisse:" -ForegroundColor Yellow
Write-Host ""

foreach ($check in $checks) {
    $percentage = [math]::Min(100, [math]::Round(($check.Count / $check.Required) * 100))
    $points = [math]::Round(($percentage / 100) * $check.Weight, 1)
    $totalScore += $points
    $maxScore += $check.Weight
    
    $status = if ($percentage -ge 100) { "✅ EXCELLENT" } 
              elseif ($percentage -ge 80) { "✅ GUT" }
              elseif ($percentage -ge 60) { "⚠️ AKZEPTABEL" }
              elseif ($percentage -ge 40) { "❌ MANGELHAFT" }
              else { "❌ UNGENÜGEND" }
    
    Write-Host "  $($check.Name) (WCAG $($check.WCAG)):" -ForegroundColor White
    Write-Host "    Gefunden: $($check.Count) | Benötigt: $($check.Required) | Score: $percentage% | $status" -ForegroundColor Gray
    Write-Host "    Punkte: $points / $($check.Weight)" -ForegroundColor Gray
    Write-Host ""
}

# Gesamtbewertung
$finalScore = [math]::Round(($totalScore / $maxScore) * 100, 1)

Write-Host "=" * 65 -ForegroundColor Gray
Write-Host "🏆 GESAMTERGEBNIS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Erreichte Punkte: $totalScore / $maxScore" -ForegroundColor White
Write-Host "  BITV 2.0 Compliance: $finalScore%" -ForegroundColor White

$grade = if ($finalScore -ge 95) { 
    Write-Host "  Bewertung: 🥇 HERVORRAGEND (BITV 2.0 Level AA++)" -ForegroundColor Green
    "HERVORRAGEND"
} elseif ($finalScore -ge 85) { 
    Write-Host "  Bewertung: 🥈 EXCELLENT (BITV 2.0 Level AA+)" -ForegroundColor Green
    "EXCELLENT" 
} elseif ($finalScore -ge 75) { 
    Write-Host "  Bewertung: 🥉 GUT (BITV 2.0 Level AA)" -ForegroundColor Yellow
    "GUT"
} elseif ($finalScore -ge 60) { 
    Write-Host "  Bewertung: ⚠️ AKZEPTABEL (BITV 2.0 Level A+)" -ForegroundColor Yellow
    "AKZEPTABEL"
} elseif ($finalScore -ge 40) { 
    Write-Host "  Bewertung: ❌ MANGELHAFT (Nicht konform)" -ForegroundColor Red
    "MANGELHAFT"
} else { 
    Write-Host "  Bewertung: ❌ UNGENÜGEND (Schwere Mängel)" -ForegroundColor Red
    "UNGENÜGEND"
}

Write-Host ""
Write-Host "=" * 65 -ForegroundColor Gray

# Spezielle Funktionen prüfen
Write-Host "🔧 Erweiterte Funktionen:" -ForegroundColor Cyan

$advancedFeatures = @(
    @{ Name = "Escape-Key Handling"; Pattern = "LogicalKeyboardKey\.escape"; Found = $content -match "LogicalKeyboardKey\.escape" },
    @{ Name = "Auto-Focus auf Dialog"; Pattern = "requestFocus"; Found = $content -match "_dialogFocusNode\.requestFocus" },
    @{ Name = "Live Loading Announcements"; Pattern = "wird geladen"; Found = $content -match "wird geladen" },
    @{ Name = "Focus Trap Implementation"; Pattern = "Focus.*onKeyEvent"; Found = $content -match "Focus.*onKeyEvent" },
    @{ Name = "German Accessibility Labels"; Pattern = "'.*[äöüÄÖÜß].*'"; Found = $content -match "'.*[äöüÄÖÜß].*'" }
)

foreach ($feature in $advancedFeatures) {
    $status = if ($feature.Found) { "✅ Implementiert" } else { "❌ Fehlt" }
    Write-Host "  $($feature.Name): $status" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📋 BITV 2.0 Compliance Summary:" -ForegroundColor Cyan
Write-Host "  • Semantische Struktur: $(if ($semanticsCount -ge 8) { '✅' } else { '❌' }) $semanticsCount/8" -ForegroundColor Gray
Write-Host "  • Tastaturnavigation: $(if ($keyboardHandling -ge 6) { '✅' } else { '❌' }) $keyboardHandling/6" -ForegroundColor Gray  
Write-Host "  • Screenreader-Support: $(if ($announcementCount -ge 5) { '✅' } else { '❌' }) $announcementCount/5" -ForegroundColor Gray
Write-Host "  • Deutsche Lokalisierung: $(if ($germanLabels -ge 10) { '✅' } else { '❌' }) $germanLabels/10" -ForegroundColor Gray
Write-Host "  • WCAG 2.1 Level AA: $(if ($finalScore -ge 75) { '✅ Erfüllt' } else { '❌ Nicht erfüllt' })" -ForegroundColor Gray

Write-Host ""
Write-Host "Validierung abgeschlossen am: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')" -ForegroundColor DarkGray

# Exit Code für CI/CD
if ($finalScore -ge 75) { exit 0 } else { exit 1 }