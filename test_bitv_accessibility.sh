#!/bin/bash

# BITV 2.0 Web Accessibility Test Script für Mein BSSB
# Automatisierte Tests für deutsche Barrierefreiheit

echo "🇩🇪 BITV 2.0 Web Accessibility Test"
echo "========================================"
echo "Mein BSSB Flutter Web Application"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASS=0
FAIL=0
WARN=0

# Function to print test result
print_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    case $status in
        "PASS")
            echo -e "✅ ${GREEN}PASS${NC} - $test_name"
            ((PASS++))
            ;;
        "FAIL")
            echo -e "❌ ${RED}FAIL${NC} - $test_name"
            if [ ! -z "$details" ]; then
                echo -e "   ${RED}→ $details${NC}"
            fi
            ((FAIL++))
            ;;
        "WARN")
            echo -e "⚠️  ${YELLOW}WARN${NC} - $test_name"
            if [ ! -z "$details" ]; then
                echo -e "   ${YELLOW}→ $details${NC}"
            fi
            ((WARN++))
            ;;
    esac
}

echo -e "${BLUE}Phase 1: Flutter Web Build Test${NC}"
echo "--------------------------------"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    print_result "Flutter Installation" "FAIL" "Flutter CLI nicht gefunden"
    exit 1
fi

print_result "Flutter Installation" "PASS"

# Build Flutter web
echo ""
echo "🔨 Building Flutter Web..."
if flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false > build.log 2>&1; then
    print_result "Flutter Web Build" "PASS"
else
    print_result "Flutter Web Build" "FAIL" "Siehe build.log für Details"
fi

echo ""
echo -e "${BLUE}Phase 2: HTML Structure Analysis${NC}"
echo "-----------------------------------"

BUILD_DIR="build/web"
INDEX_FILE="$BUILD_DIR/index.html"

if [ -f "$INDEX_FILE" ]; then
    print_result "HTML File Exists" "PASS"
    
    # Check HTML lang attribute
    if grep -q 'lang="de"' "$INDEX_FILE"; then
        print_result "HTML lang='de' Attribute" "PASS"
    else
        print_result "HTML lang='de' Attribute" "FAIL" "Deutsche Sprache nicht deklariert"
    fi
    
    # Check meta description
    if grep -q 'name="description"' "$INDEX_FILE"; then
        print_result "Meta Description" "PASS"
    else
        print_result "Meta Description" "FAIL" "Meta Description fehlt"
    fi
    
    # Check viewport meta
    if grep -q 'name="viewport"' "$INDEX_FILE"; then
        print_result "Viewport Meta Tag" "PASS"
    else
        print_result "Viewport Meta Tag" "FAIL" "Responsive Design Meta Tag fehlt"
    fi
    
    # Check page title
    if grep -q '<title>.*</title>' "$INDEX_FILE"; then
        TITLE=$(grep -o '<title>.*</title>' "$INDEX_FILE" | sed 's/<title>//g' | sed 's/<\/title>//g')
        if [ ${#TITLE} -gt 10 ]; then
            print_result "Seitentitel" "PASS" "Titel: $TITLE"
        else
            print_result "Seitentitel" "WARN" "Titel zu kurz: $TITLE"
        fi
    else
        print_result "Seitentitel" "FAIL" "Kein Titel gefunden"
    fi
    
else
    print_result "HTML File Exists" "FAIL" "index.html nicht in build/web/ gefunden"
fi

echo ""
echo -e "${BLUE}Phase 3: Accessibility Feature Check${NC}"
echo "--------------------------------------"

# Check for skip links
if [ -f "$INDEX_FILE" ]; then
    if grep -qi "skip\|sprung\|hauptinhalt" "$INDEX_FILE"; then
        print_result "Skip Navigation Links" "PASS"
    else
        print_result "Skip Navigation Links" "WARN" "Keine Skip-Links erkannt"
    fi
    
    # Check for ARIA attributes
    if grep -q "aria-" "$INDEX_FILE"; then
        print_result "ARIA Attributes" "PASS"
    else
        print_result "ARIA Attributes" "WARN" "Keine ARIA Attribute in HTML gefunden"
    fi
    
    # Check for semantic HTML5 elements
    SEMANTIC_ELEMENTS="main\|nav\|header\|footer\|section\|article"
    if grep -q "$SEMANTIC_ELEMENTS" "$INDEX_FILE"; then
        print_result "Semantic HTML5 Elements" "PASS"
    else
        print_result "Semantic HTML5 Elements" "WARN" "Wenig semantische HTML5 Elemente"
    fi
fi

echo ""
echo -e "${BLUE}Phase 4: Flutter Accessibility Features${NC}"
echo "----------------------------------------"

# Check for Semantics widgets in Dart code
DART_FILES_COUNT=$(find lib -name "*.dart" | wc -l)
SEMANTIC_FILES_COUNT=$(find lib -name "*accessible*.dart" | wc -l)

print_result "Dart Files Found" "PASS" "$DART_FILES_COUNT Dateien"

if [ $SEMANTIC_FILES_COUNT -gt 0 ]; then
    print_result "Accessible Screen Versions" "PASS" "$SEMANTIC_FILES_COUNT accessible Screens"
else
    print_result "Accessible Screen Versions" "WARN" "Keine *accessible.dart Dateien gefunden"
fi

# Check for Semantics usage
SEMANTICS_USAGE=$(find lib -name "*.dart" -exec grep -l "Semantics(" {} \; | wc -l)
if [ $SEMANTICS_USAGE -gt 0 ]; then
    print_result "Semantics Widget Usage" "PASS" "$SEMANTICS_USAGE Dateien verwenden Semantics"
else
    print_result "Semantics Widget Usage" "FAIL" "Keine Semantics Widgets gefunden"
fi

# Check for German accessibility labels
GERMAN_LABELS=$(find lib -name "*.dart" -exec grep -l "label.*deutsch\|hint.*deutsch\|semanticsLabel.*de" {} \; 2>/dev/null | wc -l)
if [ $GERMAN_LABELS -gt 0 ]; then
    print_result "German Accessibility Labels" "PASS" "$GERMAN_LABELS Dateien mit deutschen Labels"
else
    print_result "German Accessibility Labels" "WARN" "Wenige deutsche Accessibility Labels erkannt"
fi

echo ""
echo -e "${BLUE}Phase 5: Web Accessibility Configuration${NC}"
echo "------------------------------------------"

# Check for web accessibility config
if [ -f "lib/utils/web_accessibility_config.dart" ]; then
    print_result "Web Accessibility Config" "PASS"
else
    print_result "Web Accessibility Config" "WARN" "web_accessibility_config.dart nicht gefunden"
fi

# Check for accessible index.html
if [ -f "web/index_accessible.html" ]; then
    print_result "Enhanced HTML Template" "PASS"
else
    print_result "Enhanced HTML Template" "WARN" "index_accessible.html nicht gefunden"
fi

# Check for enhanced manifest
if [ -f "web/manifest_accessible.json" ]; then
    print_result "Accessible Web Manifest" "PASS"
else
    print_result "Accessible Web Manifest" "WARN" "manifest_accessible.json nicht gefunden"
fi

echo ""
echo -e "${BLUE}Phase 6: Manual Testing Requirements${NC}"
echo "--------------------------------------"

echo "⌨️  Keyboard Navigation Tests (Manuell erforderlich):"
echo "   - Tab durch alle interaktiven Elemente"
echo "   - Skip-Links funktionieren (Alt+1 oder Tab)"
echo "   - Escape schließt Dialoge"
echo "   - Focus ist sichtbar (blaue Outline)"
echo ""

echo "🔊 Screen Reader Tests (Manuell erforderlich):"
echo "   - NVDA: https://www.nvaccess.org/download/"
echo "   - JAWS: Kommerzielle Lösung"
echo "   - VoiceOver: macOS/iOS integriert"
echo ""

echo "🎨 Farbkontrast Tests (Tools verwenden):"
echo "   - WAVE: https://wave.webaim.org/"
echo "   - axe DevTools: Chrome/Firefox Extension"
echo "   - Lighthouse: Chrome DevTools > Audits"
echo ""

echo "📱 Responsive Tests:"
echo "   - 200% Zoom Test"
echo "   - Mobile Accessibility"
echo "   - High Contrast Mode"
echo ""

echo ""
echo -e "${BLUE}Test Summary${NC}"
echo "=============="
TOTAL=$((PASS + FAIL + WARN))
SCORE=$((PASS * 100 / TOTAL))

echo -e "✅ Passed: ${GREEN}$PASS${NC}"
echo -e "❌ Failed: ${RED}$FAIL${NC}"
echo -e "⚠️  Warnings: ${YELLOW}$WARN${NC}"
echo -e "📊 Score: $SCORE% ($PASS/$TOTAL)"
echo ""

# Compliance assessment
if [ $SCORE -ge 95 ] && [ $FAIL -eq 0 ]; then
    echo -e "🎉 ${GREEN}Excellent! BITV 2.0 Level AA ready${NC}"
    echo "   → Führen Sie manuelle Tests durch"
    echo "   → Planen Sie professionelle BITV 2.0 Prüfung"
elif [ $SCORE -ge 85 ] && [ $FAIL -le 2 ]; then
    echo -e "✅ ${GREEN}Good! BITV 2.0 Level A ready${NC}"
    echo "   → Beheben Sie verbleibende Fehler"
    echo "   → Verbessern Sie Warnings für Level AA"
elif [ $SCORE -ge 70 ]; then
    echo -e "⚠️  ${YELLOW}Partial compliance${NC}"
    echo "   → Kritische Probleme beheben"
    echo "   → Accessibility-Features vervollständigen"
else
    echo -e "❌ ${RED}Needs significant improvement${NC}"
    echo "   → Umfassende Accessibility-Überarbeitung"
    echo "   → Professionelle Beratung empfohlen"
fi

echo ""
echo -e "${BLUE}Next Steps${NC}"
echo "==========="
echo "1. 🔧 Beheben Sie alle FAIL-Tests"
echo "2. ⚠️  Arbeiten Sie WARN-Punkte ab"
echo "3. ⌨️  Führen Sie manuelle Keyboard-Tests durch"
echo "4. 🔊 Testen Sie mit Screen Readern"
echo "5. 🎨 Überprüfen Sie Farbkontraste"
echo "6. 🏆 Lassen Sie professionelle BITV 2.0 Prüfung durchführen"
echo ""

echo -e "${BLUE}Professional BITV 2.0 Certification${NC}"
echo "===================================="
echo "Für offizielle BITV 2.0 Zertifizierung kontaktieren Sie:"
echo "• BIK für Alle: https://bik-fuer-alle.de/"
echo "• TÜV oder DEKRA Prüfstellen"
echo "• Spezialisierte Accessibility-Beratungen"
echo ""

# Create detailed report
cat > bitv_test_report.md << EOF
# BITV 2.0 Test Report - Mein BSSB
**Date:** $(date)
**Score:** $SCORE% ($PASS/$TOTAL tests passed)

## Summary
- ✅ Passed: $PASS
- ❌ Failed: $FAIL  
- ⚠️ Warnings: $WARN

## Files Checked
- Flutter Web Build: $BUILD_DIR
- Dart Source Files: $DART_FILES_COUNT
- Accessible Screens: $SEMANTIC_FILES_COUNT
- Semantics Usage: $SEMANTICS_USAGE files

## Manual Testing Required
1. Keyboard navigation testing
2. Screen reader testing (NVDA, JAWS, VoiceOver)
3. Color contrast verification
4. Responsive design validation
5. High contrast mode testing

## Recommendations
EOF

if [ $FAIL -gt 0 ]; then
    echo "- 🔴 **Critical:** Fix all failed tests immediately" >> bitv_test_report.md
fi

if [ $WARN -gt 0 ]; then
    echo "- 🟡 **Important:** Address warning items for Level AA compliance" >> bitv_test_report.md
fi

echo "- 📋 **Required:** Complete manual accessibility testing" >> bitv_test_report.md
echo "- 🎯 **Goal:** Schedule professional BITV 2.0 audit" >> bitv_test_report.md

print_result "Test Report Generated" "PASS" "bitv_test_report.md"

exit 0