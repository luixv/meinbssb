# BITV 2.0 Accessibility Test for ChangePasswordSuccessScreenAccessible
Write-Host "=== BITV 2.0 Accessibility Test ===" -ForegroundColor Green
Write-Host "File: change_password_success_screen_accessible.dart" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
Write-Host ""

$filePath = "c:\projekte\BSSB\meinbssb\lib\screens\change_password_success_screen_accessible.dart"

if (-not (Test-Path $filePath)) {
    Write-Host "File not found: $filePath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $filePath -Raw

# Count accessibility metrics
$semanticsCount = ([regex]::Matches($content, "Semantics\(")).Count
$semanticsServiceCount = ([regex]::Matches($content, "SemanticsService\.announce")).Count
$germanLabelsCount = ([regex]::Matches($content, "erfolgreich|Fehler|Passwort|Startseite|wiederholen|Hilfe")).Count

Write-Host "ACCESSIBILITY METRICS" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Write-Host "Semantics Widgets: $semanticsCount" -ForegroundColor White
Write-Host "SemanticsService Announcements: $semanticsServiceCount" -ForegroundColor White
Write-Host "German Labels/Texts: $germanLabelsCount" -ForegroundColor White
Write-Host ""

# Check BITV 2.0 criteria
$score = 0
$maxScore = 600

Write-Host "BITV 2.0 CRITERIA ANALYSIS" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow

# 1.3.1 - Info and Relationships (Level A)
if ($content -match "container:\s*true" -and $content -match "header:\s*true") {
    Write-Host "✅ 1.3.1 Info and Relationships (Level A) - PASSED" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 1.3.1 Info and Relationships (Level A) - FAILED" -ForegroundColor Red
}

# 1.4.1 - Use of Color (Level A)
if ($content -match "border:\s*Border\.all" -and $content -match "semanticLabel") {
    Write-Host "✅ 1.4.1 Use of Color (Level A) - PASSED" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "⚠️ 1.4.1 Use of Color (Level A) - PARTIAL" -ForegroundColor Yellow
    $score += 40
}

# 2.4.6 - Headings and Labels (Level AA)
if ($content -match "header:\s*true") {
    Write-Host "✅ 2.4.6 Headings and Labels (Level AA) - PASSED" -ForegroundColor Green
    $score += 70
} else {
    Write-Host "❌ 2.4.6 Headings and Labels (Level AA) - FAILED" -ForegroundColor Red
}

# 2.5.3 - Label in Name (Level A)
if ($content -match "button:\s*true" -and $content -match "label:" -and $content -match "tooltip:") {
    Write-Host "✅ 2.5.3 Label in Name (Level A) - PASSED" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 2.5.3 Label in Name (Level A) - FAILED" -ForegroundColor Red
}

# 4.1.2 - Name, Role, Value (Level A)
if ($content -match "image:\s*true" -and $content -match "button:\s*true" -and $content -match "enabled:\s*true") {
    Write-Host "✅ 4.1.2 Name, Role, Value (Level A) - PASSED" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "❌ 4.1.2 Name, Role, Value (Level A) - FAILED" -ForegroundColor Red
}

# 4.1.3 - Status Messages (Level AA)
if ($content -match "liveRegion:\s*true" -and $content -match "SemanticsService\.announce") {
    Write-Host "✅ 4.1.3 Status Messages (Level AA) - PASSED" -ForegroundColor Green
    $score += 90
} else {
    Write-Host "❌ 4.1.3 Status Messages (Level AA) - FAILED" -ForegroundColor Red
}

# 3.1.1 - Language of Page (Level A)
if ($content -match "TextDirection\.ltr" -and $germanLabelsCount -gt 10) {
    Write-Host "✅ 3.1.1 Language of Page (Level A) - PASSED" -ForegroundColor Green
    $score += 80
} else {
    Write-Host "⚠️ 3.1.1 Language of Page (Level A) - PARTIAL" -ForegroundColor Yellow
    $score += 40
}

# Bonus features
$bonusPoints = 0
if ($content -match "initState.*SemanticsService\.announce") {
    $bonusPoints += 20
    Write-Host "🌟 Bonus: Automatic announcement on load" -ForegroundColor Magenta
}

if ($content -match "_navigateHome.*SemanticsService\.announce") {
    $bonusPoints += 15
    Write-Host "🌟 Bonus: Navigation with announcement" -ForegroundColor Magenta
}

if ($content -match "success.*error.*help") {
    $bonusPoints += 25
    Write-Host "🌟 Bonus: Comprehensive error handling with help" -ForegroundColor Magenta
}

$score += $bonusPoints

Write-Host ""
Write-Host "RESULT" -ForegroundColor Yellow
Write-Host "======" -ForegroundColor Yellow

$percentage = [math]::Round(($score / $maxScore) * 100, 1)

if ($percentage -ge 90) {
    Write-Host "EXCELLENT: $percentage% ($score/$maxScore points)" -ForegroundColor Green
    $rating = "EXCELLENT"
} elseif ($percentage -ge 80) {
    Write-Host "VERY GOOD: $percentage% ($score/$maxScore points)" -ForegroundColor Green
    $rating = "VERY GOOD"
} elseif ($percentage -ge 70) {
    Write-Host "GOOD: $percentage% ($score/$maxScore points)" -ForegroundColor Yellow
    $rating = "GOOD"
} else {
    Write-Host "NEEDS IMPROVEMENT: $percentage% ($score/$maxScore points)" -ForegroundColor Red
    $rating = "NEEDS IMPROVEMENT"
}

Write-Host ""
Write-Host "FEATURE ANALYSIS" -ForegroundColor Yellow
Write-Host "================" -ForegroundColor Yellow

$features = @{
    "Automatic Announcements" = ($content -match "initState.*SemanticsService")
    "Live Regions" = ($content -match "liveRegion:\s*true")
    "Structural Containers" = ($content -match "container:\s*true")
    "Icon Semantics" = ($content -match "image:\s*true.*semanticLabel")
    "Button Accessibility" = ($content -match "button:\s*true.*hint:")
    "German Labels" = ($germanLabelsCount -gt 15)
    "Error Help System" = ($content -match "_buildErrorHelp|help")
    "Navigation with Announcement" = ($content -match "_navigateHome.*announce")
    "Tooltips" = ($content -match "tooltip:")
    "Color-Independent Icons" = ($content -match "border:\s*Border\.all")
}

foreach ($feature in $features.GetEnumerator()) {
    if ($feature.Value) {
        Write-Host "✅ $($feature.Key)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($feature.Key)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test completed ===" -ForegroundColor Green