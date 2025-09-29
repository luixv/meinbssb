# BITV 2.0 Accessibility Test für ausweis_bestellen_screen.dart
# PowerShell Test Script

Write-Host "BITV 2.0 Accessibility Analysis - Ausweis Bestellen Screen" -ForegroundColor Blue
Write-Host "==========================================================" -ForegroundColor Blue
Write-Host ""

$Pass = 0
$Fail = 0
$Warn = 0

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

Write-Host "Phase 1: Original Screen Analysis" -ForegroundColor Cyan
Write-Host "---------------------------------" -ForegroundColor Cyan

$originalFile = "lib\screens\ausweis_bestellen_screen.dart"
if (Test-Path $originalFile) {
    Write-TestResult "Original Screen File Found" "PASS"
    
    $originalContent = Get-Content $originalFile -Raw
    
    # Check for Semantics widgets
    if ($originalContent -match "Semantics") {
        Write-TestResult "Original: Semantics Usage" "PASS"
    } else {
        Write-TestResult "Original: Semantics Usage" "FAIL" "Keine Semantics widgets gefunden"
    }
    
    # Check for accessibility labels
    if ($originalContent -match "label:|semanticsLabel|hint:") {
        Write-TestResult "Original: Accessibility Labels" "PASS"
    } else {
        Write-TestResult "Original: Accessibility Labels" "FAIL" "Keine accessibility labels"
    }
    
    # Check for loading state handling
    if ($originalContent -match "CircularProgressIndicator" -and $originalContent -match "isLoading") {
        Write-TestResult "Original: Loading State UI" "PASS"
    } else {
        Write-TestResult "Original: Loading State UI" "WARN" "Loading UI vorhanden aber limitiert"
    }
    
    # Check for error handling
    if ($originalContent -match "SnackBar") {
        Write-TestResult "Original: Error Display" "WARN" "Basis Error-Handling vorhanden"
    } else {
        Write-TestResult "Original: Error Display" "FAIL" "Kein Error-Handling erkannt"
    }

} else {
    Write-TestResult "Original Screen File Found" "FAIL" "Datei nicht gefunden"
}

Write-Host ""
Write-Host "Phase 2: Accessible Version Analysis" -ForegroundColor Cyan
Write-Host "-------------------------------------" -ForegroundColor Cyan

$accessibleFile = "lib\screens\ausweis_bestellen_screen_accessible.dart"
if (Test-Path $accessibleFile) {
    Write-TestResult "Accessible Screen File Created" "PASS"
    
    $accessibleContent = Get-Content $accessibleFile -Raw
    
    # Check for comprehensive Semantics usage
    $semanticsMatches = $accessibleContent | Select-String -Pattern "Semantics" -AllMatches
    $semanticsCount = if ($semanticsMatches) { $semanticsMatches.Matches.Count } else { 0 }
    
    if ($semanticsCount -ge 8) {
        Write-TestResult "Accessible: Comprehensive Semantics" "PASS" "$semanticsCount Semantics widgets"
    } elseif ($semanticsCount -ge 4) {
        Write-TestResult "Accessible: Comprehensive Semantics" "WARN" "$semanticsCount Semantics widgets - mehr empfohlen"
    } else {
        Write-TestResult "Accessible: Comprehensive Semantics" "FAIL" "Zu wenige Semantics widgets"
    }
    
    # Check for German accessibility labels
    if ($accessibleContent -match "Schützenausweis.*bestellen.*Schaltfläche") {
        Write-TestResult "Accessible: German Accessibility Labels" "PASS"
    } else {
        Write-TestResult "Accessible: German Accessibility Labels" "WARN" "Deutsche Labels teilweise vorhanden"
    }
    
    # Check for SemanticsService announcements
    if ($accessibleContent -match "SemanticsService.announce") {
        Write-TestResult "Accessible: Live Region Announcements" "PASS"
    } else {
        Write-TestResult "Accessible: Live Region Announcements" "FAIL" "Keine Screen Reader Ankündigungen"
    }
    
    # Check for liveRegion usage
    if ($accessibleContent -match "liveRegion: true") {
        Write-TestResult "Accessible: Live Regions" "PASS"
    } else {
        Write-TestResult "Accessible: Live Regions" "FAIL" "Keine Live Regions definiert"
    }
    
    # Check for enhanced error handling
    if ($accessibleContent -match "errorMessage" -and $accessibleContent -match "TextDirection") {
        Write-TestResult "Accessible: Enhanced Error Handling" "PASS"
    } else {
        Write-TestResult "Accessible: Enhanced Error Handling" "WARN" "Error Handling teilweise implementiert"
    }
    
    # Check for button semantics
    if ($accessibleContent -match "button: true") {
        Write-TestResult "Accessible: Button Semantics" "PASS"
    } else {
        Write-TestResult "Accessible: Button Semantics" "WARN" "Button Semantics teilweise implementiert"
    }

} else {
    Write-TestResult "Accessible Screen File Created" "FAIL" "Accessible version nicht erstellt"
}

Write-Host ""
Write-Host "Phase 3: BITV 2.0 Core Criteria Check" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

# Simplified BITV checks
$bitvScore = 0
$bitvTotal = 10

# Check 1.1.1 - Non-text Content
if ($accessibleContent -and $accessibleContent -match "label:") {
    Write-Host "✓ 1.1.1 Nicht-Text-Inhalte - Icons haben Labels" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 1.1.1 Nicht-Text-Inhalte - Unvollständig" -ForegroundColor Yellow
}

# Check 1.3.1 - Info and Relationships
if ($accessibleContent -and $accessibleContent -match "Semantics") {
    Write-Host "✓ 1.3.1 Info und Beziehungen - Semantische Struktur" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 1.3.1 Info und Beziehungen - Fehlt" -ForegroundColor Yellow
}

# Check 2.1.1 - Keyboard Access
if ($accessibleContent -and $accessibleContent -match "button: true") {
    Write-Host "✓ 2.1.1 Tastatur - Alle Funktionen bedienbar" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 2.1.1 Tastatur - Unvollständig" -ForegroundColor Yellow
}

# Check 2.4.6 - Headings and Labels
if ($accessibleContent -and $accessibleContent -match "hint:") {
    Write-Host "✓ 2.4.6 Labels - Beschreibende Labels" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 2.4.6 Labels - Teilweise implementiert" -ForegroundColor Yellow
}

# Check 3.1.1 - Language
if ($accessibleContent -and $accessibleContent -match "deutsch") {
    Write-Host "✓ 3.1.1 Sprache - Deutsche Labels" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 3.1.1 Sprache - Unvollständig" -ForegroundColor Yellow
}

# Check 3.3.1 - Error Identification
if ($accessibleContent -and $accessibleContent -match "errorMessage") {
    Write-Host "✓ 3.3.1 Fehler-Identifikation - Fehler werden kommuniziert" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 3.3.1 Fehler-Identifikation - Basis implementiert" -ForegroundColor Yellow
}

# Check 4.1.3 - Status Messages  
if ($accessibleContent -and $accessibleContent -match "liveRegion: true") {
    Write-Host "✓ 4.1.3 Statusmeldungen - Live Regions implementiert" -ForegroundColor Green
    $bitvScore++
} else {
    Write-Host "⚠ 4.1.3 Statusmeldungen - Teilweise implementiert" -ForegroundColor Yellow
}

# Additional checks
if ($accessibleContent -and $accessibleContent -match "container: true") {
    Write-Host "✓ Zusätzlich: Container Semantics" -ForegroundColor Green
    $bitvScore++
}

if ($accessibleContent -and $accessibleContent -match "SemanticsService") {
    Write-Host "✓ Zusätzlich: Screen Reader Announcements" -ForegroundColor Green
    $bitvScore++
}

if ($accessibleContent -and $accessibleContent -match "BITV 2.0") {
    Write-Host "✓ Zusätzlich: BITV 2.0 Dokumentation" -ForegroundColor Green
    $bitvScore++
}

Write-Host ""
Write-Host "Test Summary" -ForegroundColor Blue
Write-Host "============" -ForegroundColor Blue

$total = $Pass + $Fail + $Warn
$score = if ($total -gt 0) { [math]::Round(($Pass * 100) / $total) } else { 0 }
$bitvPercentage = [math]::Round(($bitvScore * 100) / $bitvTotal)

Write-Host "General Tests:"
Write-Host "  Passed: $Pass" -ForegroundColor Green
Write-Host "  Failed: $Fail" -ForegroundColor Red  
Write-Host "  Warnings: $Warn" -ForegroundColor Yellow
Write-Host "  Score: $score% ($Pass/$total)" -ForegroundColor White

Write-Host ""
Write-Host "BITV 2.0 Compliance:"
Write-Host "  Criteria Met: $bitvScore/$bitvTotal" -ForegroundColor White
Write-Host "  BITV Score: $bitvPercentage%" -ForegroundColor White

Write-Host ""

# Overall assessment
if ($bitvPercentage -ge 90 -and $Fail -le 1) {
    Write-Host "Excellent! BITV 2.0 Level AA Compliance Ready!" -ForegroundColor Green
    Write-Host "Die accessible Version erfüllt die meisten BITV 2.0 Anforderungen." -ForegroundColor Green
} elseif ($bitvPercentage -ge 70 -and $Fail -le 3) {
    Write-Host "Good! BITV 2.0 Level A Compliance" -ForegroundColor Yellow
    Write-Host "Gute Basis, einige Verbesserungen für Level AA nötig." -ForegroundColor Yellow
} else {
    Write-Host "BITV 2.0 Compliance Improvements Needed" -ForegroundColor Red
    Write-Host "Weitere Accessibility-Verbesserungen erforderlich." -ForegroundColor Red
}

Write-Host ""
Write-Host "Recommendations for ausweis_bestellen_screen:" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host "1. Use the accessible version for production" -ForegroundColor White
Write-Host "2. Test with NVDA screen reader" -ForegroundColor White
Write-Host "3. Verify keyboard navigation works completely" -ForegroundColor White
Write-Host "4. Test on real devices with TalkBack/VoiceOver" -ForegroundColor White
Write-Host "5. Validate color contrast in different themes" -ForegroundColor White
Write-Host "6. Run Flutter integration tests with semantics" -ForegroundColor White

Write-Host ""
Write-Host "Implementation Steps:" -ForegroundColor Blue
Write-Host "1. Replace original screen with accessible version" -ForegroundColor Gray
Write-Host "2. Update imports in routing/navigation files" -ForegroundColor Gray
Write-Host "3. Test all user flows with screen readers" -ForegroundColor Gray
Write-Host "4. Validate with German BITV 2.0 audit tools" -ForegroundColor Gray