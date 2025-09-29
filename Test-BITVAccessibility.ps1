# BITV 2.0 Web Accessibility Test Script für Mein BSSB
# PowerShell Version für Windows

Write-Host "🇩🇪 BITV 2.0 Web Accessibility Test" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host "Mein BSSB Flutter Web Application" -ForegroundColor Blue
Write-Host ""

# Test counters
$script:Pass = 0
$script:Fail = 0
$script:Warn = 0

# Function to print test results
function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Details = ""
    )
    
    switch ($Status) {
        "PASS" {
            Write-Host "✅ PASS - $TestName" -ForegroundColor Green
            $script:Pass++
        }
        "FAIL" {
            Write-Host "❌ FAIL - $TestName" -ForegroundColor Red
            if ($Details) {
                Write-Host "   → $Details" -ForegroundColor Red
            }
            $script:Fail++
        }
        "WARN" {
            Write-Host "⚠️  WARN - $TestName" -ForegroundColor Yellow
            if ($Details) {
                Write-Host "   → $Details" -ForegroundColor Yellow
            }
            $script:Warn++
        }
    }
}

Write-Host "Phase 1: Flutter Web Build Test" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

# Check Flutter installation
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-TestResult "Flutter Installation" "PASS"
    } else {
        Write-TestResult "Flutter Installation" "FAIL" "Flutter CLI nicht gefunden"
        exit 1
    }
} catch {
    Write-TestResult "Flutter Installation" "FAIL" "Flutter nicht verfügbar"
    exit 1
}

Write-Host ""
Write-Host "🔨 Building Flutter Web..." -ForegroundColor Yellow

# Build Flutter web
$buildResult = flutter build web --release 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-TestResult "Flutter Web Build" "PASS"
} else {
    Write-TestResult "Flutter Web Build" "FAIL" "Build Fehler aufgetreten"
    Write-Host $buildResult -ForegroundColor Red
}

Write-Host ""
Write-Host "Phase 2: HTML Structure Analysis" -ForegroundColor Cyan
Write-Host "-----------------------------------" -ForegroundColor Cyan

$buildDir = "build\web"
$indexFile = "$buildDir\index.html"

if (Test-Path $indexFile) {
    Write-TestResult "HTML File Exists" "PASS"
    
    $indexContent = Get-Content $indexFile -Raw
    
    # Check HTML lang attribute
    if ($indexContent -match 'lang="de"') {
        Write-TestResult "HTML lang='de' Attribute" "PASS"
    } else {
        Write-TestResult "HTML lang='de' Attribute" "FAIL" "Deutsche Sprache nicht deklariert"
    }
    
    # Check meta description
    if ($indexContent -match 'name="description"') {
        Write-TestResult "Meta Description" "PASS"
    } else {
        Write-TestResult "Meta Description" "FAIL" "Meta Description fehlt"
    }
    
    # Check viewport meta
    if ($indexContent -match 'name="viewport"') {
        Write-TestResult "Viewport Meta Tag" "PASS"
    } else {
        Write-TestResult "Viewport Meta Tag" "FAIL" "Responsive Design Meta Tag fehlt"
    }
    
    # Check page title
    if ($indexContent -match '<title>(.*?)</title>') {
        $title = $matches[1]
        if ($title.Length -gt 10) {
            Write-TestResult "Seitentitel" "PASS" "Titel: $title"
        } else {
            Write-TestResult "Seitentitel" "WARN" "Titel zu kurz: $title"
        }
    } else {
        Write-TestResult "Seitentitel" "FAIL" "Kein Titel gefunden"
    }
    
} else {
    Write-TestResult "HTML File Exists" "FAIL" "index.html nicht in build\web\ gefunden"
}

Write-Host ""
Write-Host "Phase 3: Accessibility Feature Check" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

if (Test-Path $indexFile) {
    $indexContent = Get-Content $indexFile -Raw
    
    # Check for skip links
    if ($indexContent -match "(skip|sprung|hauptinhalt)") {
        Write-TestResult "Skip Navigation Links" "PASS"
    } else {
        Write-TestResult "Skip Navigation Links" "WARN" "Keine Skip-Links erkannt"
    }
    
    # Check for ARIA attributes
    if ($indexContent -match "aria-") {
        Write-TestResult "ARIA Attributes" "PASS"
    } else {
        Write-TestResult "ARIA Attributes" "WARN" "Keine ARIA Attribute in HTML gefunden"
    }
    
    # Check for semantic HTML5 elements
    if ($indexContent -match "(main|nav|header|footer|section|article)") {
        Write-TestResult "Semantic HTML5 Elements" "PASS"
    } else {
        Write-TestResult "Semantic HTML5 Elements" "WARN" "Wenig semantische HTML5 Elemente"
    }
}

Write-Host ""
Write-Host "Phase 4: Flutter Accessibility Features" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Check for Dart files
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
$dartFilesCount = $dartFiles.Count
Write-TestResult "Dart Files Found" "PASS" "$dartFilesCount Dateien"

# Check for accessible screen versions
$accessibleFiles = Get-ChildItem -Path "lib" -Filter "*accessible*.dart" -Recurse
$accessibleFilesCount = $accessibleFiles.Count

if ($accessibleFilesCount -gt 0) {
    Write-TestResult "Accessible Screen Versions" "PASS" "$accessibleFilesCount accessible Screens"
} else {
    Write-TestResult "Accessible Screen Versions" "WARN" "Keine *accessible.dart Dateien gefunden"
}

# Check for Semantics usage
$semanticsFiles = @()
foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match "Semantics\(") {
        $semanticsFiles += $file
    }
}

$semanticsUsage = $semanticsFiles.Count
if ($semanticsUsage -gt 0) {
    Write-TestResult "Semantics Widget Usage" "PASS" "$semanticsUsage Dateien verwenden Semantics"
} else {
    Write-TestResult "Semantics Widget Usage" "FAIL" "Keine Semantics Widgets gefunden"
}

# Check for German accessibility labels
$germanLabelFiles = @()
foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and ($content -match "label.*deutsch" -or $content -match "hint.*deutsch" -or $content -match "semanticsLabel.*de")) {
        $germanLabelFiles += $file
    }
}

$germanLabels = $germanLabelFiles.Count
if ($germanLabels -gt 0) {
    Write-TestResult "German Accessibility Labels" "PASS" "$germanLabels Dateien mit deutschen Labels"
} else {
    Write-TestResult "German Accessibility Labels" "WARN" "Wenige deutsche Accessibility Labels erkannt"
}

Write-Host ""
Write-Host "Phase 5: Web Accessibility Configuration" -ForegroundColor Cyan
Write-Host "------------------------------------------" -ForegroundColor Cyan

# Check for web accessibility config
if (Test-Path "lib\utils\web_accessibility_config.dart") {
    Write-TestResult "Web Accessibility Config" "PASS"
} else {
    Write-TestResult "Web Accessibility Config" "WARN" "web_accessibility_config.dart nicht gefunden"
}

# Check for accessible index.html
if (Test-Path "web\index_accessible.html") {
    Write-TestResult "Enhanced HTML Template" "PASS"
} else {
    Write-TestResult "Enhanced HTML Template" "WARN" "index_accessible.html nicht gefunden"
}

# Check for enhanced manifest
if (Test-Path "web\manifest_accessible.json") {
    Write-TestResult "Accessible Web Manifest" "PASS"
} else {
    Write-TestResult "Accessible Web Manifest" "WARN" "manifest_accessible.json nicht gefunden"
}

Write-Host ""
Write-Host "Phase 6: Manual Testing Requirements" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

Write-Host "⌨️  Keyboard Navigation Tests (Manuell erforderlich):" -ForegroundColor White
Write-Host "   - Tab durch alle interaktiven Elemente" -ForegroundColor Gray
Write-Host "   - Skip-Links funktionieren (Alt+1 oder Tab)" -ForegroundColor Gray
Write-Host "   - Escape schließt Dialoge" -ForegroundColor Gray
Write-Host "   - Focus ist sichtbar (blaue Outline)" -ForegroundColor Gray
Write-Host ""

Write-Host "🔊 Screen Reader Tests (Manuell erforderlich):" -ForegroundColor White
Write-Host "   - NVDA: https://www.nvaccess.org/download/" -ForegroundColor Gray
Write-Host "   - JAWS: Kommerzielle Lösung" -ForegroundColor Gray
Write-Host "   - VoiceOver: macOS/iOS integriert" -ForegroundColor Gray
Write-Host ""

Write-Host "🎨 Farbkontrast Tests (Tools verwenden):" -ForegroundColor White
Write-Host "   - WAVE: https://wave.webaim.org/" -ForegroundColor Gray
Write-Host "   - axe DevTools: Chrome/Firefox Extension" -ForegroundColor Gray
Write-Host "   - Lighthouse: Chrome DevTools > Audits" -ForegroundColor Gray
Write-Host ""

Write-Host "📱 Responsive Tests:" -ForegroundColor White
Write-Host "   - 200% Zoom Test" -ForegroundColor Gray
Write-Host "   - Mobile Accessibility" -ForegroundColor Gray
Write-Host "   - High Contrast Mode" -ForegroundColor Gray
Write-Host ""

Write-Host ""
Write-Host "Test Summary" -ForegroundColor Blue
Write-Host "=============" -ForegroundColor Blue
$total = $script:Pass + $script:Fail + $script:Warn
$score = if ($total -gt 0) { [math]::Round(($script:Pass * 100) / $total) } else { 0 }

Write-Host "✅ Passed: " -ForegroundColor Green -NoNewline
Write-Host $script:Pass -ForegroundColor White
Write-Host "❌ Failed: " -ForegroundColor Red -NoNewline  
Write-Host $script:Fail -ForegroundColor White
Write-Host "⚠️  Warnings: " -ForegroundColor Yellow -NoNewline
Write-Host $script:Warn -ForegroundColor White
Write-Host "📊 Score: $score% ($($script:Pass)/$total)" -ForegroundColor White
Write-Host ""

# Compliance assessment
if ($score -ge 95 -and $script:Fail -eq 0) {
    Write-Host "🎉 Excellent! BITV 2.0 Level AA ready" -ForegroundColor Green
    Write-Host "   → Führen Sie manuelle Tests durch" -ForegroundColor Gray
    Write-Host "   → Planen Sie professionelle BITV 2.0 Prüfung" -ForegroundColor Gray
} elseif ($score -ge 85 -and $script:Fail -le 2) {
    Write-Host "✅ Good! BITV 2.0 Level A ready" -ForegroundColor Green
    Write-Host "   → Beheben Sie verbleibende Fehler" -ForegroundColor Gray
    Write-Host "   → Verbessern Sie Warnings für Level AA" -ForegroundColor Gray
} elseif ($score -ge 70) {
    Write-Host "⚠️  Partial compliance" -ForegroundColor Yellow
    Write-Host "   → Kritische Probleme beheben" -ForegroundColor Gray
    Write-Host "   → Accessibility-Features vervollständigen" -ForegroundColor Gray
} else {
    Write-Host "❌ Needs significant improvement" -ForegroundColor Red
    Write-Host "   → Umfassende Accessibility-Überarbeitung" -ForegroundColor Gray
    Write-Host "   → Professionelle Beratung empfohlen" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Next Steps" -ForegroundColor Blue
Write-Host "===========" -ForegroundColor Blue
Write-Host "1. 🔧 Beheben Sie alle FAIL-Tests" -ForegroundColor White
Write-Host "2. ⚠️  Arbeiten Sie WARN-Punkte ab" -ForegroundColor White
Write-Host "3. ⌨️  Führen Sie manuelle Keyboard-Tests durch" -ForegroundColor White
Write-Host "4. 🔊 Testen Sie mit Screen Readern" -ForegroundColor White
Write-Host "5. 🎨 Überprüfen Sie Farbkontraste" -ForegroundColor White
Write-Host "6. 🏆 Lassen Sie professionelle BITV 2.0 Prüfung durchführen" -ForegroundColor White
Write-Host ""

Write-Host "Professional BITV 2.0 Certification" -ForegroundColor Blue
Write-Host "====================================" -ForegroundColor Blue
Write-Host "Für offizielle BITV 2.0 Zertifizierung kontaktieren Sie:" -ForegroundColor White
Write-Host "• BIK für Alle: https://bik-fuer-alle.de/" -ForegroundColor Gray
Write-Host "• TÜV oder DEKRA Prüfstellen" -ForegroundColor Gray
Write-Host "• Spezialisierte Accessibility-Beratungen" -ForegroundColor Gray
Write-Host ""

# Create detailed report
$reportContent = @"
# BITV 2.0 Test Report - Mein BSSB
**Date:** $(Get-Date)
**Score:** $score% ($($script:Pass)/$total tests passed)

## Summary
- ✅ Passed: $($script:Pass)
- ❌ Failed: $($script:Fail)  
- ⚠️ Warnings: $($script:Warn)

## Files Checked
- Flutter Web Build: $buildDir
- Dart Source Files: $dartFilesCount
- Accessible Screens: $accessibleFilesCount
- Semantics Usage: $semanticsUsage files

## Manual Testing Required
1. Keyboard navigation testing
2. Screen reader testing (NVDA, JAWS, VoiceOver)
3. Color contrast verification
4. Responsive design validation
5. High contrast mode testing

## Recommendations
"@

if ($script:Fail -gt 0) {
    $reportContent += "`n- 🔴 **Critical:** Fix all failed tests immediately"
}

if ($script:Warn -gt 0) {
    $reportContent += "`n- 🟡 **Important:** Address warning items for Level AA compliance"
}

$reportContent += "`n- 📋 **Required:** Complete manual accessibility testing"
$reportContent += "`n- 🎯 **Goal:** Schedule professional BITV 2.0 audit"

$reportContent | Out-File -FilePath "bitv_test_report.md" -Encoding UTF8

Write-TestResult "Test Report Generated" "PASS" "bitv_test_report.md"

Write-Host ""
Write-Host "🔍 Öffnen Sie jetzt Ihren Browser und testen Sie:" -ForegroundColor Cyan
if (Test-Path "$buildDir\index.html") {
    $fullPath = (Resolve-Path "$buildDir\index.html").Path
    Write-Host "   file:///$($fullPath.Replace('\', '/'))" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Verwenden Sie diese Browser-Extensions für automatisierte Tests:" -ForegroundColor White
    Write-Host "• axe DevTools: Chrome/Firefox Extension" -ForegroundColor Gray
    Write-Host "• WAVE: https://wave.webaim.org/" -ForegroundColor Gray
    Write-Host "• Lighthouse: Chrome DevTools > Audits" -ForegroundColor Gray
}