# BITV 2.0 Web Accessibility Test Script fuer Mein BSSB
# PowerShell Version fuer Windows

Write-Host "BITV 2.0 Web Accessibility Test" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host "Mein BSSB Flutter Web Application" -ForegroundColor Blue
Write-Host ""

# Test counters
$Pass = 0
$Fail = 0
$Warn = 0

# Function to print test results
function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Details = ""
    )
    
    switch ($Status) {
        "PASS" {
            Write-Host "PASS - $TestName" -ForegroundColor Green
            $script:Pass++
        }
        "FAIL" {
            Write-Host "FAIL - $TestName" -ForegroundColor Red
            if ($Details) {
                Write-Host "   -> $Details" -ForegroundColor Red
            }
            $script:Fail++
        }
        "WARN" {
            Write-Host "WARN - $TestName" -ForegroundColor Yellow
            if ($Details) {
                Write-Host "   -> $Details" -ForegroundColor Yellow
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
    Write-TestResult "Flutter Installation" "FAIL" "Flutter nicht verfuegbar"
    exit 1
}

Write-Host ""
Write-Host "Building Flutter Web..." -ForegroundColor Yellow

# Build Flutter web
$buildResult = flutter build web --release 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-TestResult "Flutter Web Build" "PASS"
} else {
    Write-TestResult "Flutter Web Build" "FAIL" "Build Fehler aufgetreten"
}

Write-Host ""
Write-Host "Phase 2: HTML Structure Analysis" -ForegroundColor Cyan
Write-Host "---------------------------------" -ForegroundColor Cyan

$buildDir = "build\web"
$indexFile = "$buildDir\index.html"

if (Test-Path $indexFile) {
    Write-TestResult "HTML File Exists" "PASS"
    
    $indexContent = Get-Content $indexFile -Raw
    
    # Check HTML lang attribute
    if ($indexContent -match 'lang="de"') {
        Write-TestResult "HTML lang Attribute" "PASS"
    } else {
        Write-TestResult "HTML lang Attribute" "FAIL" "Deutsche Sprache nicht deklariert"
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
    
} else {
    Write-TestResult "HTML File Exists" "FAIL" "index.html nicht in build\web gefunden"
}

Write-Host ""
Write-Host "Phase 3: Flutter Accessibility Features" -ForegroundColor Cyan
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
    Write-TestResult "Accessible Screen Versions" "WARN" "Keine accessible.dart Dateien gefunden"
}

# Check for Semantics usage in a few sample files
$semanticsCount = 0
$sampleFiles = $dartFiles | Select-Object -First 10
foreach ($file in $sampleFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match "Semantics") {
        $semanticsCount++
    }
}

if ($semanticsCount -gt 0) {
    Write-TestResult "Semantics Widget Usage" "PASS" "$semanticsCount von 10 Beispieldateien"
} else {
    Write-TestResult "Semantics Widget Usage" "WARN" "Wenige Semantics Widgets in Beispieldateien"
}

Write-Host ""
Write-Host "Phase 4: Web Accessibility Configuration" -ForegroundColor Cyan
Write-Host "-----------------------------------------" -ForegroundColor Cyan

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

Write-Host ""
Write-Host "Test Summary" -ForegroundColor Blue
Write-Host "============" -ForegroundColor Blue

$total = $Pass + $Fail + $Warn
$score = if ($total -gt 0) { [math]::Round(($Pass * 100) / $total) } else { 0 }

Write-Host "Passed: $Pass" -ForegroundColor Green
Write-Host "Failed: $Fail" -ForegroundColor Red
Write-Host "Warnings: $Warn" -ForegroundColor Yellow
Write-Host "Score: $score% ($Pass/$total)" -ForegroundColor White
Write-Host ""

# Compliance assessment
if ($score -ge 95 -and $Fail -eq 0) {
    Write-Host "Excellent! BITV 2.0 Level AA ready" -ForegroundColor Green
    Write-Host "-> Fuehren Sie manuelle Tests durch" -ForegroundColor Gray
} elseif ($score -ge 85 -and $Fail -le 2) {
    Write-Host "Good! BITV 2.0 Level A ready" -ForegroundColor Green
    Write-Host "-> Beheben Sie verbleibende Fehler" -ForegroundColor Gray
} elseif ($score -ge 70) {
    Write-Host "Partial compliance" -ForegroundColor Yellow
    Write-Host "-> Kritische Probleme beheben" -ForegroundColor Gray
} else {
    Write-Host "Needs significant improvement" -ForegroundColor Red
    Write-Host "-> Umfassende Accessibility-Ueberarbeitung" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Manual Testing Requirements" -ForegroundColor Blue
Write-Host "============================" -ForegroundColor Blue
Write-Host "1. Keyboard Navigation:" -ForegroundColor White
Write-Host "   - Tab durch alle interaktiven Elemente" -ForegroundColor Gray
Write-Host "   - Escape schliesst Dialoge" -ForegroundColor Gray
Write-Host "   - Focus ist sichtbar" -ForegroundColor Gray

Write-Host ""
Write-Host "2. Screen Reader Tests:" -ForegroundColor White
Write-Host "   - NVDA: https://www.nvaccess.org/download/" -ForegroundColor Gray
Write-Host "   - Testen Sie alle Hauptfunktionen" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Browser Tools:" -ForegroundColor White
Write-Host "   - Chrome DevTools > Lighthouse Audit" -ForegroundColor Gray
Write-Host "   - Firefox Accessibility Inspector" -ForegroundColor Gray
Write-Host "   - WAVE Extension" -ForegroundColor Gray

Write-Host ""
if (Test-Path "$buildDir\index.html") {
    $fullPath = (Resolve-Path "$buildDir\index.html").Path
    Write-Host "Test your app now:" -ForegroundColor Cyan
    Write-Host "file:///$($fullPath.Replace('\', '/'))" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Professional BITV 2.0 Certification" -ForegroundColor Blue
Write-Host "====================================" -ForegroundColor Blue
Write-Host "Fuer offizielle BITV 2.0 Zertifizierung:" -ForegroundColor White
Write-Host "• BIK fuer Alle: https://bik-fuer-alle.de/" -ForegroundColor Gray
Write-Host "• TUEV oder DEKRA Pruefstellen" -ForegroundColor Gray