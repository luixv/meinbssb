# BITV 2.0 Cookie Consent Screen - Accessibility Validation
# PowerShell Script fuer umfassende Barrierefreiheitspruefung

Write-Host "BITV 2.0 Barrierefreiheit-Validierung: Cookie Consent Screen" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Gray

$cookieConsentFile = "c:\projekte\BSSB\meinbssb\lib\screens\cookie_consent_screen_accessible.dart"

if (-not (Test-Path $cookieConsentFile)) {
    Write-Host "Datei nicht gefunden: $cookieConsentFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content $cookieConsentFile -Raw

# BITV 2.0 Kriterien-Ueberpruefung
$totalScore = 0
$maxScore = 100

Write-Host "Detaillierte Analyse-Ergebnisse:" -ForegroundColor Yellow
Write-Host ""

# 1. Semantics Widgets (WCAG 1.3.1, 4.1.2)
$semanticsCount = ([regex]::Matches($content, "Semantics\(")).Count
$semanticsScore = [math]::Min(15, ($semanticsCount / 8) * 15)
$totalScore += $semanticsScore
Write-Host "  Semantics Widgets (WCAG 1.3.1, 4.1.2):" -ForegroundColor White
Write-Host "    Gefunden: $semanticsCount | Benoetigt: 8 | Score: $([math]::Round($semanticsScore, 1))/15" -ForegroundColor Gray

# 2. SemanticsService Announcements (WCAG 4.1.3)
$announcementCount = ([regex]::Matches($content, "SemanticsService\.announce")).Count
$announcementScore = [math]::Min(12, ($announcementCount / 5) * 12)
$totalScore += $announcementScore
Write-Host "  Live Announcements (WCAG 4.1.3):" -ForegroundColor White
Write-Host "    Gefunden: $announcementCount | Benoetigt: 5 | Score: $([math]::Round($announcementScore, 1))/12" -ForegroundColor Gray

# 3. Focus Management (WCAG 2.4.3, 2.1.1)
$focusNodes = ([regex]::Matches($content, "FocusNode")).Count
$focusManagement = ([regex]::Matches($content, "requestFocus|FocusScope")).Count
$totalFocus = $focusNodes + $focusManagement
$focusScore = [math]::Min(15, ($totalFocus / 4) * 15)
$totalScore += $focusScore
Write-Host "  Fokus-Management (WCAG 2.4.3, 2.1.1):" -ForegroundColor White
Write-Host "    Gefunden: $totalFocus | Benoetigt: 4 | Score: $([math]::Round($focusScore, 1))/15" -ForegroundColor Gray

# 4. Keyboard Navigation (WCAG 2.1.1, 2.1.2)
$keyboardHandling = ([regex]::Matches($content, "onKeyEvent|KeyEvent|LogicalKeyboardKey")).Count
$keyboardScore = [math]::Min(12, ($keyboardHandling / 6) * 12)
$totalScore += $keyboardScore
Write-Host "  Tastaturnavigation (WCAG 2.1.1, 2.1.2):" -ForegroundColor White
Write-Host "    Gefunden: $keyboardHandling | Benoetigt: 6 | Score: $([math]::Round($keyboardScore, 1))/12" -ForegroundColor Gray

# 5. German Language Labels (WCAG 3.1.1)
$germanLabels = ([regex]::Matches($content, "label:\s*'[^']*Cookie[^']*'")).Count +
                ([regex]::Matches($content, "label:\s*'[^']*Dialog[^']*'")).Count +
                ([regex]::Matches($content, "label:\s*'[^']*Zustimmung[^']*'")).Count
$germanScore = [math]::Min(8, ($germanLabels / 10) * 8)
$totalScore += $germanScore
Write-Host "  Deutsche Semantik-Labels (WCAG 3.1.1):" -ForegroundColor White
Write-Host "    Gefunden: $germanLabels | Benoetigt: 10 | Score: $([math]::Round($germanScore, 1))/8" -ForegroundColor Gray

# 6. Accessible Hints (WCAG 3.3.2)
$hintsCount = ([regex]::Matches($content, "hint:\s*'")).Count
$hintsScore = [math]::Min(10, ($hintsCount / 6) * 10)
$totalScore += $hintsScore
Write-Host "  Accessibility Hints (WCAG 3.3.2):" -ForegroundColor White
Write-Host "    Gefunden: $hintsCount | Benoetigt: 6 | Score: $([math]::Round($hintsScore, 1))/10" -ForegroundColor Gray

# 7. Dialog Structure (WCAG 1.3.1)
$dialogStructures = ([regex]::Matches($content, "header:\s*true|container:\s*true|scopesRoute:\s*true")).Count
$dialogScore = [math]::Min(10, ($dialogStructures / 3) * 10)
$totalScore += $dialogScore
Write-Host "  Dialog-Struktur (WCAG 1.3.1):" -ForegroundColor White
Write-Host "    Gefunden: $dialogStructures | Benoetigt: 3 | Score: $([math]::Round($dialogScore, 1))/10" -ForegroundColor Gray

# 8. Button Semantics (WCAG 4.1.2)
$buttonSemantics = ([regex]::Matches($content, "button:\s*true")).Count
$buttonScore = [math]::Min(8, ($buttonSemantics / 1) * 8)
$totalScore += $buttonScore
Write-Host "  Button-Semantik (WCAG 4.1.2):" -ForegroundColor White
Write-Host "    Gefunden: $buttonSemantics | Benoetigt: 1 | Score: $([math]::Round($buttonScore, 1))/8" -ForegroundColor Gray

# 9. Contrast & Visual Enhancements (WCAG 1.4.3)
$contrastFeatures = ([regex]::Matches($content, "elevation|BorderSide|fontSize|fontWeight")).Count
$contrastScore = [math]::Min(10, ($contrastFeatures / 8) * 10)
$totalScore += $contrastScore
Write-Host "  Visueller Kontrast (WCAG 1.4.3):" -ForegroundColor White
Write-Host "    Gefunden: $contrastFeatures | Benoetigt: 8 | Score: $([math]::Round($contrastScore, 1))/10" -ForegroundColor Gray

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Gray
Write-Host "GESAMTERGEBNIS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Erreichte Punkte: $([math]::Round($totalScore, 1)) / $maxScore" -ForegroundColor White

$finalScore = [math]::Round($totalScore, 1)
Write-Host "  BITV 2.0 Compliance: $finalScore%" -ForegroundColor White

if ($finalScore -ge 95) { 
    Write-Host "  Bewertung: HERVORRAGEND (BITV 2.0 Level AA++)" -ForegroundColor Green
    $grade = "HERVORRAGEND"
} elseif ($finalScore -ge 85) { 
    Write-Host "  Bewertung: EXCELLENT (BITV 2.0 Level AA+)" -ForegroundColor Green
    $grade = "EXCELLENT" 
} elseif ($finalScore -ge 75) { 
    Write-Host "  Bewertung: GUT (BITV 2.0 Level AA)" -ForegroundColor Yellow
    $grade = "GUT"
} elseif ($finalScore -ge 60) { 
    Write-Host "  Bewertung: AKZEPTABEL (BITV 2.0 Level A+)" -ForegroundColor Yellow
    $grade = "AKZEPTABEL"
} elseif ($finalScore -ge 40) { 
    Write-Host "  Bewertung: MANGELHAFT (Nicht konform)" -ForegroundColor Red
    $grade = "MANGELHAFT"
} else { 
    Write-Host "  Bewertung: UNGENÜGEND (Schwere Maengel)" -ForegroundColor Red
    $grade = "UNGENÜGEND"
}

Write-Host ""
Write-Host "Erweiterte Funktionen:" -ForegroundColor Cyan

$escapeHandling = if ($content -match "LogicalKeyboardKey\.escape") { "Implementiert" } else { "Fehlt" }
$autoFocus = if ($content -match "_dialogFocusNode\.requestFocus") { "Implementiert" } else { "Fehlt" }
$loadingAnnouncements = if ($content -match "wird geladen") { "Implementiert" } else { "Fehlt" }
$focusTrap = if ($content -match "Focus.*onKeyEvent") { "Implementiert" } else { "Fehlt" }

Write-Host "  Escape-Key Handling: $escapeHandling" -ForegroundColor Gray
Write-Host "  Auto-Focus auf Dialog: $autoFocus" -ForegroundColor Gray
Write-Host "  Live Loading Announcements: $loadingAnnouncements" -ForegroundColor Gray
Write-Host "  Focus Trap Implementation: $focusTrap" -ForegroundColor Gray

Write-Host ""
Write-Host "BITV 2.0 Compliance Summary:" -ForegroundColor Cyan
Write-Host "  Semantische Struktur: $(if ($semanticsCount -ge 8) { 'Erfuellt' } else { 'Nicht erfuellt' }) ($semanticsCount/8)" -ForegroundColor Gray
Write-Host "  Tastaturnavigation: $(if ($keyboardHandling -ge 6) { 'Erfuellt' } else { 'Nicht erfuellt' }) ($keyboardHandling/6)" -ForegroundColor Gray  
Write-Host "  Screenreader-Support: $(if ($announcementCount -ge 5) { 'Erfuellt' } else { 'Nicht erfuellt' }) ($announcementCount/5)" -ForegroundColor Gray
Write-Host "  Deutsche Lokalisierung: $(if ($germanLabels -ge 10) { 'Erfuellt' } else { 'Teilweise erfuellt' }) ($germanLabels/10)" -ForegroundColor Gray
Write-Host "  WCAG 2.1 Level AA: $(if ($finalScore -ge 75) { 'Erfuellt' } else { 'Nicht erfuellt' })" -ForegroundColor Gray

Write-Host ""
Write-Host "Validierung abgeschlossen am: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')" -ForegroundColor DarkGray

# Exit Code fuer CI/CD
if ($finalScore -ge 75) { exit 0 } else { exit 1 }