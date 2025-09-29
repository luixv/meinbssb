# BITV 2.0 Email Verification Screen - Accessibility Validation
# PowerShell Script fuer umfassende Barrierefreiheitspruefung

Write-Host "BITV 2.0 Barrierefreiheit-Validierung: Email Verification Screen" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Gray

$emailVerificationFile = "c:\projekte\BSSB\meinbssb\lib\screens\email_verification_screen_accessible.dart"

if (-not (Test-Path $emailVerificationFile)) {
    Write-Host "Datei nicht gefunden: $emailVerificationFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content $emailVerificationFile -Raw

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
$announcementScore = [math]::Min(15, ($announcementCount / 6) * 15)
$totalScore += $announcementScore
Write-Host "  Live Announcements (WCAG 4.1.3):" -ForegroundColor White
Write-Host "    Gefunden: $announcementCount | Benoetigt: 6 | Score: $([math]::Round($announcementScore, 1))/15" -ForegroundColor Gray

# 3. Progress Tracking (WCAG 1.3.1, 4.1.3)
$progressFeatures = ([regex]::Matches($content, "_progressStep|_totalSteps|_progressPercentage|_updateProgress")).Count
$progressScore = [math]::Min(12, ($progressFeatures / 8) * 12)
$totalScore += $progressScore
Write-Host "  Progress Tracking (WCAG 1.3.1, 4.1.3):" -ForegroundColor White
Write-Host "    Gefunden: $progressFeatures | Benoetigt: 8 | Score: $([math]::Round($progressScore, 1))/12" -ForegroundColor Gray

# 4. Live Regions (WCAG 4.1.3)
$liveRegions = ([regex]::Matches($content, "liveRegion:\s*true")).Count
$liveRegionScore = [math]::Min(10, ($liveRegions / 1) * 10)
$totalScore += $liveRegionScore
Write-Host "  Live Regions (WCAG 4.1.3):" -ForegroundColor White
Write-Host "    Gefunden: $liveRegions | Benoetigt: 1 | Score: $([math]::Round($liveRegionScore, 1))/10" -ForegroundColor Gray

# 5. German Language Features (WCAG 3.1.1)
$germanLabels = ([regex]::Matches($content, "label:\s*'[^']*Mail[^']*'")).Count +
                ([regex]::Matches($content, "label:\s*'[^']*Bestaetigung[^']*'")).Count +
                ([regex]::Matches($content, "label:\s*'[^']*Verifikation[^']*'")).Count +
                ([regex]::Matches($content, "Schritt.*von")).Count
$germanScore = [math]::Min(8, ($germanLabels / 8) * 8)
$totalScore += $germanScore
Write-Host "  Deutsche Semantik-Labels (WCAG 3.1.1):" -ForegroundColor White
Write-Host "    Gefunden: $germanLabels | Benoetigt: 8 | Score: $([math]::Round($germanScore, 1))/8" -ForegroundColor Gray

# 6. Accessible Navigation (WCAG 2.4.3)
$navigationFeatures = ([regex]::Matches($content, "_announceNavigationAndNavigate|Navigation.*zur")).Count
$navigationScore = [math]::Min(10, ($navigationFeatures / 3) * 10)
$totalScore += $navigationScore
Write-Host "  Accessible Navigation (WCAG 2.4.3):" -ForegroundColor White
Write-Host "    Gefunden: $navigationFeatures | Benoetigt: 3 | Score: $([math]::Round($navigationScore, 1))/10" -ForegroundColor Gray

# 7. Error Handling Accessibility (WCAG 3.3.3)
$errorHandling = ([regex]::Matches($content, "Fehler.*announce|failure.*announce")).Count
$errorScore = [math]::Min(8, ($errorHandling / 2) * 8)
$totalScore += $errorScore
Write-Host "  Error Handling Accessibility (WCAG 3.3.3):" -ForegroundColor White
Write-Host "    Gefunden: $errorHandling | Benoetigt: 2 | Score: $([math]::Round($errorScore, 1))/8" -ForegroundColor Gray

# 8. Loading State Accessibility (WCAG 1.3.1)
$loadingFeatures = ([regex]::Matches($content, "CircularProgressIndicator.*value|label.*Fortschritt")).Count
$loadingScore = [math]::Min(10, ($loadingFeatures / 2) * 10)
$totalScore += $loadingScore
Write-Host "  Loading State Accessibility (WCAG 1.3.1):" -ForegroundColor White
Write-Host "    Gefunden: $loadingFeatures | Benoetigt: 2 | Score: $([math]::Round($loadingScore, 1))/10" -ForegroundColor Gray

# 9. Information Architecture (WCAG 1.3.1)
$infoFeatures = ([regex]::Matches($content, "header:\s*true|container:\s*true|hint:")).Count
$infoScore = [math]::Min(6, ($infoFeatures / 6) * 6)
$totalScore += $infoScore
Write-Host "  Information Architecture (WCAG 1.3.1):" -ForegroundColor White
Write-Host "    Gefunden: $infoFeatures | Benoetigt: 6 | Score: $([math]::Round($infoScore, 1))/6" -ForegroundColor Gray

# 10. Visual Enhancements (WCAG 1.4.3)
$visualFeatures = ([regex]::Matches($content, "fontSize|fontWeight|BorderRadius|decoration|padding")).Count
$visualScore = [math]::Min(6, ($visualFeatures / 8) * 6)
$totalScore += $visualScore
Write-Host "  Visual Enhancements (WCAG 1.4.3):" -ForegroundColor White
Write-Host "    Gefunden: $visualFeatures | Benoetigt: 8 | Score: $([math]::Round($visualScore, 1))/6" -ForegroundColor Gray

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
Write-Host "Spezielle Accessibility Features:" -ForegroundColor Cyan

$progressTracking = if ($content -match "_updateProgress.*announce") { "Implementiert" } else { "Fehlt" }
$navigationAnnouncements = if ($content -match "_announceNavigationAndNavigate") { "Implementiert" } else { "Fehlt" }
$liveUpdates = if ($content -match "liveRegion:\s*true") { "Implementiert" } else { "Fehlt" }
$errorAnnouncements = if ($content -match "Fehler.*announce") { "Implementiert" } else { "Fehlt" }
$automaticProcess = if ($content -match "Automatische.*läuft") { "Implementiert" } else { "Fehlt" }

Write-Host "  Progress Tracking mit Announcements: $progressTracking" -ForegroundColor Gray
Write-Host "  Navigation Announcements: $navigationAnnouncements" -ForegroundColor Gray
Write-Host "  Live Region Updates: $liveUpdates" -ForegroundColor Gray
Write-Host "  Error Announcements: $errorAnnouncements" -ForegroundColor Gray
Write-Host "  Automatic Process Information: $automaticProcess" -ForegroundColor Gray

Write-Host ""
Write-Host "BITV 2.0 Compliance Summary:" -ForegroundColor Cyan
Write-Host "  Semantische Struktur: $(if ($semanticsCount -ge 8) { 'Erfuellt' } else { 'Nicht erfuellt' }) ($semanticsCount/8)" -ForegroundColor Gray
Write-Host "  Live Announcements: $(if ($announcementCount -ge 6) { 'Erfuellt' } else { 'Nicht erfuellt' }) ($announcementCount/6)" -ForegroundColor Gray  
Write-Host "  Progress Tracking: $(if ($progressFeatures -ge 8) { 'Erfuellt' } else { 'Teilweise erfuellt' }) ($progressFeatures/8)" -ForegroundColor Gray
Write-Host "  Deutsche Lokalisierung: $(if ($germanLabels -ge 8) { 'Erfuellt' } else { 'Teilweise erfuellt' }) ($germanLabels/8)" -ForegroundColor Gray
Write-Host "  WCAG 2.1 Level AA: $(if ($finalScore -ge 75) { 'Erfuellt' } else { 'Nicht erfuellt' })" -ForegroundColor Gray

Write-Host ""
Write-Host "Validierung abgeschlossen am: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')" -ForegroundColor DarkGray

# Exit Code fuer CI/CD
if ($finalScore -ge 75) { exit 0 } else { exit 1 }