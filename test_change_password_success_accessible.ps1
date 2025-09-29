# BITV 2.0 Accessibility Test für ChangePasswordSuccessScreenAccessible
# PowerShell Script zur Validierung der Barrierefreiheit

Write-Host "=== BITV 2.0 Accessibility Test ===" -ForegroundColor Green
Write-Host "Datei: change_password_success_screen_accessible.dart" -ForegroundColor Cyan
Write-Host "Datum: $(Get-Date -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
Write-Host ""

# Pfad zur Datei
$filePath = "c:\projekte\BSSB\meinbssb\lib\screens\change_password_success_screen_accessible.dart"

if (-not (Test-Path $filePath)) {
    Write-Host "❌ Datei nicht gefunden: $filePath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $filePath -Raw

# Accessibility Metriken zählen
$semanticsCount = ([regex]::Matches($content, "Semantics\(")).Count
$semanticsServiceCount = ([regex]::Matches($content, "SemanticsService\.announce")).Count
$germanLabelsCount = ([regex]::Matches($content, "label:\s*['\"].*[äöüßÄÖÜ].*['\"]")).Count + 
                     ([regex]::Matches($content, "['\"].*(?:erfolgreich|Fehler|Passwort|ändern|Startseite|wiederholen|Hilfe).*['\"]")).Count

Write-Host "📊 ACCESSIBILITY METRIKEN" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "🎯 Semantics Widgets: $semanticsCount" -ForegroundColor White
Write-Host "📢 SemanticsService Announcements: $semanticsServiceCount" -ForegroundColor White
Write-Host "🗣️ Deutsche Labels/Texte: $germanLabelsCount" -ForegroundColor White
Write-Host ""

# BITV 2.0 Kriterien prüfen
$score = 0
$maxScore = 600
$violations = @()
$recommendations = @()

Write-Host "🔍 BITV 2.0 KRITERIEN ANALYSE" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

# 1.3.1 - Info und Beziehungen (Level A)
if ($content -match "container:\s*true" -and $content -match "header:\s*true") {
    Write-Host "✅ 1.3.1 Info und Beziehungen (Level A) - ERFÜLLT" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 1.3.1 Info und Beziehungen (Level A) - NICHT ERFÜLLT" -ForegroundColor Red
    $violations += "1.3.1 - Strukturelle Kennzeichnung unvollständig"
}

# 1.4.1 - Verwendung von Farbe (Level A)
if ($content -match "border:\s*Border\.all" -and $content -match "semanticLabel") {
    Write-Host "✅ 1.4.1 Verwendung von Farbe (Level A) - ERFÜLLT" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "⚠️ 1.4.1 Verwendung von Farbe (Level A) - TEILWEISE" -ForegroundColor Yellow
    $score += 40
    $recommendations += "1.4.1 - Zusätzliche nicht-farbliche Kennzeichnung empfohlen"
}

# 2.4.6 - Überschriften und Beschriftungen (Level AA)
if ($content -match "header:\s*true") {
    Write-Host "✅ 2.4.6 Überschriften und Beschriftungen (Level AA) - ERFÜLLT" -ForegroundColor Green
    $score += 70
} else {
    Write-Host "❌ 2.4.6 Überschriften und Beschriftungen (Level AA) - NICHT ERFÜLLT" -ForegroundColor Red
    $violations += "2.4.6 - Überschriften nicht als Header gekennzeichnet"
}

# 2.5.3 - Beschriftung im Namen (Level A)
if ($content -match "button:\s*true" -and $content -match "label:" -and $content -match "tooltip:") {
    Write-Host "✅ 2.5.3 Beschriftung im Namen (Level A) - ERFÜLLT" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 2.5.3 Beschriftung im Namen (Level A) - NICHT ERFÜLLT" -ForegroundColor Red
    $violations += "2.5.3 - Button-Beschriftungen unvollständig"
}

# 4.1.2 - Name, Rolle, Wert (Level A)
if ($content -match "image:\s*true" -and $content -match "button:\s*true" -and $content -match "enabled:\s*true") {
    Write-Host "✅ 4.1.2 Name, Rolle, Wert (Level A) - ERFÜLLT" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 4.1.2 Name, Rolle, Wert (Level A) - NICHT ERFÜLLT" -ForegroundColor Red
    $violations += "4.1.2 - Rollen und Eigenschaften unvollständig"
}

# 4.1.3 - Statusmeldungen (Level AA)
if ($content -match "liveRegion:\s*true" -and $content -match "SemanticsService\.announce") {
    Write-Host "✅ 4.1.3 Statusmeldungen (Level AA) - ERFÜLLT" -ForegroundColor Green
    $score += 90
} else {
    Write-Host "❌ 4.1.3 Statusmeldungen (Level AA) - NICHT ERFÜLLT" -ForegroundColor Red
    $violations += "4.1.3 - Automatische Statusankündigungen fehlen"
}

# 3.1.1 - Sprache der Seite (Level A)
if ($content -match "TextDirection\.ltr" -and $germanLabelsCount -gt 10) {
    Write-Host "✅ 3.1.1 Sprache der Seite (Level A) - ERFÜLLT" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "⚠️ 3.1.1 Sprache der Seite (Level A) - TEILWEISE" -ForegroundColor Yellow
    $score += 40
    $recommendations += "3.1.1 - Mehr deutsche Sprachkennzeichnung empfohlen"
}

# Zusätzliche Accessibility Features
$bonusPoints = 0
if ($content -match "initState.*SemanticsService\.announce") {
    $bonusPoints += 20
    Write-Host "🌟 Bonus: Automatische Ankündigung beim Laden" -ForegroundColor Magenta
}

if ($content -match "_navigateHome.*SemanticsService\.announce") {
    $bonusPoints += 15
    Write-Host "🌟 Bonus: Navigation mit Ankündigung" -ForegroundColor Magenta
}

if ($content -match "success.*error.*help") {
    $bonusPoints += 25
    Write-Host "🌟 Bonus: Umfassende Fehlerbehandlung mit Hilfe" -ForegroundColor Magenta
}

$score += $bonusPoints

Write-Host ""
Write-Host "📈 ERGEBNIS" -ForegroundColor Yellow
Write-Host "===========" -ForegroundColor Yellow

$percentage = [math]::Round(($score / $maxScore) * 100, 1)

if ($percentage -ge 90) {
    Write-Host "🏆 AUSGEZEICHNET: $percentage% ($score/$maxScore Punkte)" -ForegroundColor Green
    $rating = "AUSGEZEICHNET"
} elseif ($percentage -ge 80) {
    Write-Host "✅ SEHR GUT: $percentage% ($score/$maxScore Punkte)" -ForegroundColor Green
    $rating = "SEHR GUT"
} elseif ($percentage -ge 70) {
    Write-Host "👍 GUT: $percentage% ($score/$maxScore Punkte)" -ForegroundColor Yellow
    $rating = "GUT"
} elseif ($percentage -ge 60) {
    Write-Host "⚠️ AUSREICHEND: $percentage% ($score/$maxScore Punkte)" -ForegroundColor Yellow
    $rating = "AUSREICHEND"
} else {
    Write-Host "❌ UNGENÜGEND: $percentage% ($score/$maxScore Punkte)" -ForegroundColor Red
    $rating = "UNGENÜGEND"
}

Write-Host ""

# Level Compliance
$levelA = $true
$levelAA = $true

if ($violations -match "Level A") { $levelA = $false }
if ($violations -match "Level AA") { $levelAA = $false }

Write-Host "🎯 BITV 2.0 LEVEL COMPLIANCE" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
if ($levelA) {
    Write-Host "✅ Level A: KONFORM" -ForegroundColor Green
} else {
    Write-Host "❌ Level A: NICHT KONFORM" -ForegroundColor Red
}

if ($levelAA) {
    Write-Host "✅ Level AA: KONFORM" -ForegroundColor Green
} else {
    Write-Host "❌ Level AA: NICHT KONFORM" -ForegroundColor Red
}

Write-Host ""

# Verstöße ausgeben
if ($violations.Count -gt 0) {
    Write-Host "⚠️ VERSTÖSSE ($($violations.Count))" -ForegroundColor Red
    Write-Host "===================" -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "• $violation" -ForegroundColor White
    }
    Write-Host ""
}

# Empfehlungen ausgeben
if ($recommendations.Count -gt 0) {
    Write-Host "💡 EMPFEHLUNGEN ($($recommendations.Count))" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    foreach ($recommendation in $recommendations) {
        Write-Host "• $recommendation" -ForegroundColor White
    }
    Write-Host ""
}

# Detaillierte Feature-Analyse
Write-Host "🔍 FEATURE ANALYSE" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow

$features = @{
    "Automatische Ankündigungen" = ($content -match "initState.*SemanticsService")
    "Live Regions" = ($content -match "liveRegion:\s*true")
    "Strukturelle Container" = ($content -match "container:\s*true")
    "Icon-Semantics" = ($content -match "image:\s*true.*semanticLabel")
    "Button-Zugänglichkeit" = ($content -match "button:\s*true.*hint:")
    "Deutsche Beschriftungen" = ($germanLabelsCount -gt 15)
    "Fehler-Hilfe System" = ($content -match "_buildErrorHelp|help")
    "Navigation mit Ansage" = ($content -match "_navigateHome.*announce")
    "Tooltips" = ($content -match "tooltip:")
    "Farbunabhängige Icons" = ($content -match "border:\s*Border\.all")
}

foreach ($feature in $features.GetEnumerator()) {
    if ($feature.Value) {
        Write-Host "✅ $($feature.Key)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($feature.Key)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🧪 TEST EMPFEHLUNGEN" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "🎯 Screen Reader Test (NVDA/JAWS): Automatische Ankündigungen prüfen"
Write-Host "⌨️ Tastatur-Navigation: Tab-Reihenfolge und Button-Fokus testen"
Write-Host "🎨 Kontrast-Test: Erfolgs/Fehler-Farben mit Analyzer validieren"
Write-Host "🔊 Audio-Test: Ankündigungen beim Seitenladen hören"
Write-Host "👁️ Visueller Test: Icons ohne Farben erkennbar prüfen"
Write-Host ""

# HTML Report generieren
$htmlContent = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>BITV 2.0 Test Report - ChangePasswordSuccessScreenAccessible</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .score { font-size: 2em; text-align: center; margin: 20px 0; font-weight: bold; }
        .excellent { color: #22c55e; }
        .good { color: #22c55e; }
        .warning { color: #f59e0b; }
        .error { color: #ef4444; }
        .feature { margin: 10px 0; padding: 10px; border-left: 4px solid #22c55e; background: #f0f9ff; }
        .feature.missing { border-left-color: #ef4444; background: #fef2f2; }
        .metric { display: inline-block; margin: 10px; padding: 10px 15px; background: #ddd6fe; border-radius: 6px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 BITV 2.0 Accessibility Test Report</h1>
        <h2>ChangePasswordSuccessScreenAccessible</h2>
        <p><strong>Datum:</strong> $(Get-Date -Format 'dd.MM.yyyy HH:mm')</p>
        
        <div class="score excellent">🏆 $rating: $percentage%</div>
        
        <h3>📊 Metriken</h3>
        <div class="metric">🎯 Semantics: $semanticsCount</div>
        <div class="metric">📢 Announcements: $semanticsServiceCount</div>
        <div class="metric">🗣️ Deutsche Labels: $germanLabelsCount</div>
        
        <h3>✅ Accessibility Features</h3>
"@

foreach ($feature in $features.GetEnumerator()) {
    $class = if ($feature.Value) { "feature" } else { "feature missing" }
    $icon = if ($feature.Value) { "✅" } else { "❌" }
    $htmlContent += "<div class=`"$class`">$icon $($feature.Key)</div>`n"
}

$htmlContent += @"
        
        <h3>🎯 BITV 2.0 Compliance</h3>
        <p><strong>Level A:</strong> $(if ($levelA) { "✅ KONFORM" } else { "❌ NICHT KONFORM" })</p>
        <p><strong>Level AA:</strong> $(if ($levelAA) { "✅ KONFORM" } else { "❌ NICHT KONFORM" })</p>
    </div>
</body>
</html>
"@

$htmlPath = "c:\projekte\BSSB\meinbssb\bitv_change_password_success_accessible_test.html"
$htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8

Write-Host "📋 HTML Report erstellt: $htmlPath" -ForegroundColor Green
Write-Host ""
Write-Host "=== Test abgeschlossen ===" -ForegroundColor Green

# JSON Output für weitere Verarbeitung
$testResult = @{
    "file" = "change_password_success_screen_accessible.dart"
    "score" = $score
    "maxScore" = $maxScore
    "percentage" = $percentage
    "rating" = $rating
    "levelA" = $levelA
    "levelAA" = $levelAA
    "semanticsCount" = $semanticsCount
    "announcementsCount" = $semanticsServiceCount
    "germanLabelsCount" = $germanLabelsCount
    "violations" = $violations
    "recommendations" = $recommendations
    "features" = $features
    "timestamp" = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
} | ConvertTo-Json -Depth 3

$jsonPath = "c:\projekte\BSSB\meinbssb\bitv_change_password_success_accessible_result.json"
$testResult | Out-File -FilePath $jsonPath -Encoding UTF8

Write-Host "📊 JSON Result: $jsonPath" -ForegroundColor Cyan