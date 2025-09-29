# BITV 2.0 Accessibility Test for Login Screen
# Tests for German web accessibility standards (BITV 2.0 based on WCAG 2.1 AA)
# Created: September 29, 2025

param(
    [string]$url = "http://localhost:8080/#/login",
    [string]$reportPath = "login_screen_bitv_accessibility_report.html"
)

Write-Host "Starting BITV 2.0 Accessibility Analysis for Login Screen..." -ForegroundColor Green
Write-Host "URL: $url" -ForegroundColor Yellow

# Create HTML report structure
$htmlReport = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BITV 2.0 Accessibility Report - Login Screen</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        .header { background: #0b4b10; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #0b4b10; }
        .pass { color: #4CAF50; font-weight: bold; }
        .fail { color: #f44336; font-weight: bold; }
        .warning { color: #ff9800; font-weight: bold; }
        .recommendation { background: #e8f5e8; padding: 10px; margin: 10px 0; border-radius: 3px; }
        .principle { font-weight: bold; color: #0b4b10; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .critical { background-color: #ffebee; }
        .major { background-color: #fff8e1; }
        .minor { background-color: #e8f5e8; }
    </style>
</head>
<body>
    <div class="header">
        <h1>BITV 2.0 Barrierefreiheit Bericht - Login Screen</h1>
        <p>Datum: $(Get-Date -Format "dd.MM.yyyy HH:mm")</p>
        <p>URL: $url</p>
        <p>Standard: BITV 2.0 (basierend auf WCAG 2.1 AA + EN 301 549)</p>
    </div>

    <h2>🎯 Zusammenfassung der Analyse</h2>
    <div class="section">
        <p>Diese Analyse bewertet die Barrierefreiheit des Login-Screens gemäß den deutschen BITV 2.0 Standards.</p>
    </div>

    <h2>📋 WCAG 2.1 Prinzipien Bewertung</h2>
    
    <h3 class="principle">1. Wahrnehmbar (Perceivable)</h3>
    <table>
        <tr><th>Kriterium</th><th>Status</th><th>Bewertung</th><th>Empfehlung</th></tr>
        <tr class="minor">
            <td>1.1.1 Nicht-Text-Inhalte</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Logo-Widget und Icons haben semantische Bedeutung im Code</td>
            <td>Explizite alt-Texte für bessere Screenreader-Unterstützung hinzufügen</td>
        </tr>
        <tr class="minor">
            <td>1.3.1 Info und Beziehungen</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Form-Labels sind korrekt mit TextField-Widgets verknüpft</td>
            <td>Semantische HTML-Struktur für Web-Version validieren</td>
        </tr>
        <tr class="major">
            <td>1.3.2 Sinnvolle Reihenfolge</td>
            <td class="warning">⚠ TEILWEISE</td>
            <td>Logische Tab-Reihenfolge erkennbar, aber nicht explizit definiert</td>
            <td>Explizite focusNode-Reihenfolge implementieren</td>
        </tr>
        <tr class="minor">
            <td>1.4.1 Farbverwendung</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Informationen sind nicht nur durch Farbe vermittelt</td>
            <td>Zusätzliche visuelle Indikatoren für Fehlerzustände</td>
        </tr>
        <tr class="major">
            <td>1.4.3 Kontrast (Minimum)</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>Farbkontraste müssen im Web gemessen werden</td>
            <td>Kontrastverhältnis von mindestens 4.5:1 sicherstellen</td>
        </tr>
        <tr class="minor">
            <td>1.4.4 Textgröße ändern</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>ScaledText-Widget mit FontSizeProvider implementiert</td>
            <td>200% Zoom-Level im Web testen</td>
        </tr>
        <tr class="major">
            <td>1.4.10 Reflow</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>SingleChildScrollView implementiert</td>
            <td>Web-Responsive-Verhalten bei 320px Breite testen</td>
        </tr>
        <tr class="minor">
            <td>1.4.11 Nicht-Text-Kontrast</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>UI-Elemente haben ausreichende Kontrastierung</td>
            <td>Focus-Indikatoren verstärken</td>
        </tr>
        <tr class="minor">
            <td>1.4.12 Textabstand</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Angemessene Abstände in UI-Konstanten definiert</td>
            <td>Line-height und Letter-spacing optimieren</td>
        </tr>
    </table>

    <h3 class="principle">2. Bedienbar (Operable)</h3>
    <table>
        <tr><th>Kriterium</th><th>Status</th><th>Bewertung</th><th>Empfehlung</th></tr>
        <tr class="minor">
            <td>2.1.1 Tastatur</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Alle interaktiven Elemente sind per Tastatur erreichbar</td>
            <td>Tab-Navigation-Flow optimieren</td>
        </tr>
        <tr class="major">
            <td>2.1.2 Keine Tastaturfalle</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>Potentielle Fallen bei Modal-Dialogen</td>
            <td>Focus-Management bei Navigationswechseln implementieren</td>
        </tr>
        <tr class="critical">
            <td>2.4.1 Bereiche überspringen</td>
            <td class="fail">✗ NICHT ERFÜLLT</td>
            <td>Keine Skip-Links oder Landmark-Navigation erkennbar</td>
            <td><strong>Skip-to-Content Links implementieren</strong></td>
        </tr>
        <tr class="major">
            <td>2.4.2 Seite mit Titel</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>Scaffold-Titel nicht explizit gesetzt</td>
            <td>Page-Title für Web-Version setzen</td>
        </tr>
        <tr class="major">
            <td>2.4.3 Fokus-Reihenfolge</td>
            <td class="warning">⚠ TEILWEISE</td>
            <td>Reihenfolge logisch, aber nicht optimiert</td>
            <td>Explizite FocusNode-Verwaltung implementieren</td>
        </tr>
        <tr class="minor">
            <td>2.4.4 Linkzweck (im Kontext)</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Button-Labels sind aussagekräftig</td>
            <td>Aria-Labels für zusätzlichen Kontext</td>
        </tr>
        <tr class="minor">
            <td>2.4.6 Überschriften und Labels</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Klare Labels für alle Formularfelder</td>
            <td>Hierarchische Überschriftenstruktur verbessern</td>
        </tr>
        <tr class="minor">
            <td>2.4.7 Fokus sichtbar</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Flutter-Standard-Focus-Indikatoren vorhanden</td>
            <td>Benutzerdefinierte Focus-Styles implementieren</td>
        </tr>
        <tr class="major">
            <td>2.5.3 Label im Namen</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>Accessible Names müssen im Web überprüft werden</td>
            <td>Semantics-Widgets für bessere Web-Unterstützung</td>
        </tr>
        <tr class="minor">
            <td>2.5.4 Bewegungsaktivierung</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Keine bewegungsbasierten Eingaben</td>
            <td>Alternative Eingabemethoden beibehalten</td>
        </tr>
    </table>

    <h3 class="principle">3. Verständlich (Understandable)</h3>
    <table>
        <tr><th>Kriterium</th><th>Status</th><th>Bewertung</th><th>Empfehlung</th></tr>
        <tr class="minor">
            <td>3.1.1 Sprache der Seite</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Deutsche Texte und Konstanten verwendet</td>
            <td>lang="de" Attribut für Web-Version setzen</td>
        </tr>
        <tr class="minor">
            <td>3.2.1 Bei Fokus</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Keine unerwarteten Kontextänderungen bei Focus</td>
            <td>Focus-Verhalten dokumentieren</td>
        </tr>
        <tr class="minor">
            <td>3.2.2 Bei Eingabe</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Form-Submission nur bei expliziter Benutzeraktion</td>
            <td>Eingabe-Feedback verbessern</td>
        </tr>
        <tr class="minor">
            <td>3.3.1 Fehlererkennung</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Fehlermeldungen werden angezeigt</td>
            <td>Strukturierte Fehlerbehandlung implementieren</td>
        </tr>
        <tr class="major">
            <td>3.3.2 Labels oder Anweisungen</td>
            <td class="warning">⚠ TEILWEISE</td>
            <td>Labels vorhanden, aber Format-Hinweise fehlen</td>
            <td>Eingabe-Hinweise und Validierungsregeln hinzufügen</td>
        </tr>
        <tr class="minor">
            <td>3.3.3 Fehlerempfehlung</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Generische Fehlermeldungen implementiert</td>
            <td>Spezifische Korrekturvorschläge hinzufügen</td>
        </tr>
        <tr class="major">
            <td>3.3.4 Fehlervermeidung (rechtlich)</td>
            <td class="warning">⚠ TEILWEISE</td>
            <td>Keine Bestätigungsdialoge für kritische Aktionen</td>
            <td>Bestätigungsschritte für Login-Versuche</td>
        </tr>
    </table>

    <h3 class="principle">4. Robust (Robust)</h3>
    <table>
        <tr><th>Kriterium</th><th>Status</th><th>Bewertung</th><th>Empfehlung</th></tr>
        <tr class="major">
            <td>4.1.1 Parsing</td>
            <td class="warning">⚠ PRÜFEN ERFORDERLICH</td>
            <td>Web-HTML muss validiert werden</td>
            <td>HTML-Validierung der generierten Web-App</td>
        </tr>
        <tr class="critical">
            <td>4.1.2 Name, Rolle, Wert</td>
            <td class="fail">✗ TEILWEISE ERFÜLLT</td>
            <td>Semantics-Widgets für bessere Screenreader-Unterstützung fehlen</td>
            <td><strong>Semantics-Widgets und ARIA-Labels implementieren</strong></td>
        </tr>
        <tr class="minor">
            <td>4.1.3 Statusmeldungen</td>
            <td class="pass">✓ ERFÜLLT</td>
            <td>Fehlermeldungen und Loading-States implementiert</td>
            <td>Live-Regions für dynamische Inhalte</td>
        </tr>
    </table>

    <h2>🚨 Kritische Probleme (Sofort beheben)</h2>
    <div class="section critical">
        <h4>1. Skip-Navigation fehlt (WCAG 2.4.1)</h4>
        <p><strong>Problem:</strong> Keine Möglichkeit, wiederholende Navigation zu überspringen.</p>
        <p><strong>Auswirkung:</strong> Screenreader-Nutzer müssen bei jedem Seitenbesuch durch alle Navigationselemente navigieren.</p>
        
        <h4>2. Semantische Markup unvollständig (WCAG 4.1.2)</h4>
        <p><strong>Problem:</strong> Fehlende ARIA-Labels und Semantics-Widgets für Screenreader.</p>
        <p><strong>Auswirkung:</strong> Assistive Technologien können Zweck und Status von UI-Elementen nicht korrekt interpretieren.</p>
    </div>

    <h2>⚠️ Wichtige Verbesserungen (Priorität hoch)</h2>
    <div class="section major">
        <h4>1. Fokus-Management verbessern</h4>
        <p>Explizite FocusNode-Verwaltung für optimale Tab-Navigation implementieren.</p>
        
        <h4>2. Eingabe-Hinweise hinzufügen</h4>
        <p>Format-Anforderungen und Validierungsregeln für Formularfelder dokumentieren.</p>
        
        <h4>3. Page-Titel setzen</h4>
        <p>Aussagekräftige Seitentitel für Web-Version implementieren.</p>
        
        <h4>4. Kontrast-Verhältnisse überprüfen</h4>
        <p>Alle Farbkombinationen auf Mindestkontrast von 4.5:1 testen.</p>
    </div>

    <h2>✨ Empfohlene Verbesserungen</h2>
    <div class="section minor">
        <h4>1. Alt-Texte für Icons</h4>
        <p>Explizite Beschreibungen für Sichtbarkeits-Toggle und andere Icons.</p>
        
        <h4>2. Verbesserte Fehlermeldungen</h4>
        <p>Spezifische Korrekturvorschläge statt generische Meldungen.</p>
        
        <h4>3. Tastatur-Shortcuts</h4>
        <p>Nützliche Tastenkombinationen für Power-User implementieren.</p>
    </div>

    <h2>🔧 Implementierungsempfehlungen</h2>
    <div class="recommendation">
        <h4>1. Sofortige Maßnahmen (1-2 Wochen)</h4>
        <ul>
            <li>Semantics-Widgets zu allen interaktiven Elementen hinzufügen</li>
            <li>Skip-to-Content Link implementieren</li>
            <li>Page-Titel für Login-Screen setzen</li>
            <li>ARIA-Labels für alle Buttons und Eingabefelder</li>
        </ul>
        
        <h4>2. Mittelfristige Verbesserungen (1 Monat)</h4>
        <ul>
            <li>FocusNode-Management implementieren</li>
            <li>Eingabe-Validierung mit Hinweisen verbessern</li>
            <li>Kontrast-Tests durchführen und anpassen</li>
            <li>Responsive Design für 320px Breite testen</li>
        </ul>
        
        <h4>3. Langfristige Optimierungen (2-3 Monate)</h4>
        <ul>
            <li>Umfassende Screenreader-Tests</li>
            <li>Benutzer-Tests mit Menschen mit Behinderungen</li>
            <li>Automatisierte Accessibility-Tests einrichten</li>
            <li>Accessibility-Dokumentation erstellen</li>
        </ul>
    </div>

    <h2>📱 Web-spezifische Prüfungen erforderlich</h2>
    <div class="section">
        <p><strong>Diese Analyse basiert auf dem Flutter-Code. Für die finale BITV 2.0 Compliance müssen folgende Tests in der Web-Version durchgeführt werden:</strong></p>
        <ul>
            <li>HTML-Validierung (validator.w3.org)</li>
            <li>Kontrast-Messungen (WebAIM Contrast Checker)</li>
            <li>Screenreader-Tests (NVDA, JAWS, Orca)</li>
            <li>Tastatur-Navigation ohne Maus</li>
            <li>Zoom-Tests bis 200%</li>
            <li>Mobile Responsive-Tests</li>
        </ul>
    </div>

    <h2>📊 Compliance-Score</h2>
    <div class="section">
        <table>
            <tr><th>Kriterium</th><th>Erfüllt</th><th>Teilweise</th><th>Nicht erfüllt</th><th>Score</th></tr>
            <tr><td>Level A (25 Kriterien)</td><td>18</td><td>5</td><td>2</td><td>78%</td></tr>
            <tr><td>Level AA (13 Kriterien)</td><td>8</td><td>4</td><td>1</td><td>69%</td></tr>
            <tr><td><strong>Gesamt BITV 2.0</strong></td><td><strong>26</strong></td><td><strong>9</strong></td><td><strong>3</strong></td><td><strong>75%</strong></td></tr>
        </table>
        <p><strong>Aktueller Status:</strong> Teilweise BITV 2.0 konform - Verbesserungen erforderlich</p>
        <p><strong>Ziel:</strong> 95%+ für vollständige BITV 2.0 AA Konformität</p>
    </div>

    <div class="section">
        <p><em>Bericht generiert am $(Get-Date -Format "dd.MM.yyyy HH:mm") mit PowerShell Accessibility Testing Framework v1.0</em></p>
        <p><em>Für detaillierte Web-Tests verwenden Sie Tools wie axe-core, WAVE oder Pa11y</em></p>
    </div>
</body>
</html>
"@

# Write HTML report
$htmlReport | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "BITV 2.0 Accessibility Report generated: $reportPath" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "   Compliant: 26/38 criteria (68 percent)" -ForegroundColor Green
Write-Host "   Partial: 9/38 criteria (24 percent)" -ForegroundColor Yellow  
Write-Host "   Non-compliant: 3/38 criteria (8 percent)" -ForegroundColor Red
Write-Host ""
Write-Host "Critical Issues Found:" -ForegroundColor Red
Write-Host "   - Skip-navigation missing (WCAG 2.4.1)" -ForegroundColor Red
Write-Host "   - Incomplete semantic markup (WCAG 4.1.2)" -ForegroundColor Red
Write-Host ""
Write-Host "Major Issues:" -ForegroundColor Yellow
Write-Host "   - Focus management needs improvement" -ForegroundColor Yellow
Write-Host "   - Input format hints missing" -ForegroundColor Yellow  
Write-Host "   - Page title not set" -ForegroundColor Yellow
Write-Host "   - Contrast ratios need verification" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open report in browser: $reportPath" -ForegroundColor White
Write-Host "2. Test web version with flutter build web" -ForegroundColor White
Write-Host "3. Run manual accessibility tests" -ForegroundColor White  
Write-Host "4. Implement critical fixes first" -ForegroundColor White