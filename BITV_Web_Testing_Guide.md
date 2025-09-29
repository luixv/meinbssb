# BITV 2.0 Web Accessibility Testing Guide
## Mein BSSB Flutter Web Application

---

## 🔍 **Automated Testing Tools**

### **1. axe-core Browser Extension**
**Installation:**
- Chrome: [axe DevTools](https://chrome.google.com/webstore/detail/axe-devtools-web-accessibility/lhdoppojpmngadmnindnejefpokejbdd)
- Firefox: [axe-DevTools](https://addons.mozilla.org/en-US/firefox/addon/axe-devtools/)

**Usage:**
1. Open your Flutter web app in browser
2. Open DevTools (F12)
3. Navigate to "axe DevTools" tab
4. Click "Scan All of My Page"
5. Review violations by WCAG level

**Expected Results:** 0 violations for Level A, minimal for Level AA

### **2. WAVE (Web Accessibility Evaluation Tool)**
**URL:** https://wave.webaim.org/

**Usage:**
1. Enter your web app URL
2. Review the visual report
3. Check for:
   - Missing alt text
   - Color contrast issues
   - Heading structure problems
   - Form labeling issues

### **3. Lighthouse Accessibility Audit**
**Usage:**
1. Open Chrome DevTools
2. Go to "Lighthouse" tab
3. Select "Accessibility" category
4. Run audit

**Target Score:** 95+ for BITV 2.0 compliance

---

## ⌨️ **Manual Keyboard Testing**

### **Navigation Tests**
```
Test 1: Tab Navigation
- Press Tab key repeatedly
- Ensure all interactive elements receive focus
- Focus should be visible (blue outline)
- Focus order should be logical

Test 2: Skip Links
- Press Tab on page load
- "Zum Hauptinhalt springen" should appear
- Press Enter to skip navigation
- Focus should move to main content

Test 3: Keyboard Shortcuts
- Test Alt+1 through Alt+9 for quick navigation
- Test Escape key to close dialogs
- Test Space/Enter on buttons
- Test arrow keys in lists/menus
```

### **Form Testing**
```
Test 4: Form Navigation
- Tab through all form fields
- Labels should be announced by screen readers
- Required fields should be clearly marked
- Error messages should be accessible

Test 5: Form Submission
- Submit forms with errors
- Error messages should receive focus
- Success messages should be announced
```

---

## 🔊 **Screen Reader Testing**

### **NVDA (Windows) - Free**
**Installation:** https://www.nvaccess.org/download/

**Test Procedure:**
1. Start NVDA (Ctrl+Alt+N)
2. Navigate to your web app
3. Use these commands:
   - **H**: Navigate by headings
   - **K**: Navigate by links
   - **B**: Navigate by buttons
   - **F**: Navigate by form fields
   - **G**: Navigate by graphics
   - **Insert+F7**: List all elements

**Test Checklist:**
- [ ] Page title is announced
- [ ] Headings are properly structured (H1 → H2 → H3)
- [ ] Links have meaningful text
- [ ] Buttons describe their action
- [ ] Form fields have proper labels
- [ ] Images have alt text
- [ ] Loading states are announced
- [ ] Error messages are read aloud

### **JAWS (Windows) - Commercial**
**Similar testing procedure as NVDA**

### **VoiceOver (macOS) - Built-in**
**Activation:** System Preferences → Accessibility → VoiceOver

**Commands:**
- **Ctrl+Option+→**: Next item
- **Ctrl+Option+←**: Previous item
- **Ctrl+Option+U**: Web rotor
- **Ctrl+Option+Space**: Activate item

---

## 🎨 **Visual Accessibility Testing**

### **Color Contrast Testing**
**Tools:**
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Chrome DevTools Color Picker

**Requirements:**
- **Normal text:** 4.5:1 contrast ratio (AA level)
- **Large text:** 3:1 contrast ratio (AA level)
- **AAA level:** 7:1 for normal text, 4.5:1 for large text

**Test Procedure:**
1. Check all text/background combinations
2. Test hover and focus states
3. Verify button states (enabled/disabled)
4. Test link colors (visited/unvisited)

### **High Contrast Mode Testing**
**Windows High Contrast:**
1. Windows + U → High Contrast
2. Turn on high contrast
3. Test all app functionality
4. Ensure all content is visible
5. Check that focus indicators work

**Browser High Contrast:**
- Edge: Settings → Accessibility → High contrast
- Chrome: Settings → Advanced → Accessibility

### **Zoom Testing**
**Requirements:**
- Text must be readable at 200% zoom
- All functionality must work at 200% zoom
- Horizontal scrolling should be minimal

**Test Procedure:**
1. Set browser zoom to 200% (Ctrl++)
2. Navigate entire application
3. Check form submission
4. Verify button accessibility
5. Test responsive design

---

## 📱 **Responsive Accessibility Testing**

### **Mobile Screen Readers**
**iOS VoiceOver:**
- Settings → Accessibility → VoiceOver
- Test with Safari on iPhone/iPad

**Android TalkBack:**
- Settings → Accessibility → TalkBack
- Test with Chrome on Android

### **Touch Target Testing**
**Requirements:**
- Minimum 44px × 44px touch targets
- 8px spacing between targets

---

## 🧪 **Automated Testing Setup**

### **Jest + @testing-library/flutter Testing**
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.0.0
```

### **Accessibility Testing Script**
```dart
// test/accessibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/main.dart';

void main() {
  testWidgets('App meets basic accessibility requirements', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Test semantic structure
    expect(find.byType(Semantics), findsWidgets);
    
    // Test that all buttons have semantic labels
    final buttons = find.byType(ElevatedButton);
    for (int i = 0; i < tester.widgetList(buttons).length; i++) {
      final button = tester.widget<ElevatedButton>(buttons.at(i));
      // Verify button has accessible text or semantic label
    }
    
    // Test form field labels
    final textFields = find.byType(TextField);
    for (int i = 0; i < tester.widgetList(textFields).length; i++) {
      // Verify each text field has proper labeling
    }
  });
}
```

---

## 📊 **BITV 2.0 Compliance Checklist**

### **Level A Requirements**
- [ ] **1.1.1** Alt text for images
- [ ] **1.2.1** Captions for audio content
- [ ] **1.3.1** Information and relationships
- [ ] **1.3.2** Meaningful sequence
- [ ] **1.3.3** Sensory characteristics
- [ ] **1.4.1** Use of color
- [ ] **1.4.2** Audio control
- [ ] **2.1.1** Keyboard accessibility
- [ ] **2.1.2** No keyboard trap
- [ ] **2.2.1** Timing adjustable
- [ ] **2.2.2** Pause, stop, hide
- [ ] **2.3.1** Three flashes threshold
- [ ] **2.4.1** Bypass blocks
- [ ] **2.4.2** Page titled
- [ ] **2.4.3** Focus order
- [ ] **2.4.4** Link purpose in context
- [ ] **3.1.1** Language of page
- [ ] **3.2.1** On focus
- [ ] **3.2.2** On input
- [ ] **3.3.1** Error identification
- [ ] **3.3.2** Labels or instructions
- [ ] **4.1.1** Parsing
- [ ] **4.1.2** Name, role, value

### **Level AA Requirements**
- [ ] **1.2.4** Live captions
- [ ] **1.2.5** Audio description
- [ ] **1.4.3** Contrast minimum (4.5:1)
- [ ] **1.4.4** Resize text (200%)
- [ ] **1.4.5** Images of text
- [ ] **2.4.5** Multiple ways
- [ ] **2.4.6** Headings and labels
- [ ] **2.4.7** Focus visible
- [ ] **3.1.2** Language of parts
- [ ] **3.2.3** Consistent navigation
- [ ] **3.2.4** Consistent identification
- [ ] **3.3.3** Error suggestion
- [ ] **3.3.4** Error prevention

---

## 🎯 **Testing Schedule**

### **Daily Testing (Development)**
- Keyboard navigation
- Focus management
- New features accessibility

### **Weekly Testing**
- Screen reader testing (NVDA/JAWS)
- Color contrast verification
- Form accessibility

### **Release Testing**
- Full automated accessibility audit
- Manual testing with all screen readers
- High contrast mode testing
- Zoom testing (200%)
- Mobile accessibility testing

### **Quarterly Audit**
- Professional BITV 2.0 assessment
- User testing with disabled users
- Compliance documentation update

---

## 📞 **Support & Resources**

### **German Accessibility Resources**
- **BITV 2.0 Verordnung:** https://www.gesetze-im-internet.de/bitv_2_0/
- **BIK für Alle:** https://bik-fuer-alle.de/
- **Aktion Mensch:** https://www.aktion-mensch.de/inklusion/barrierefreiheit/

### **Testing Tools**
- **WAVE:** https://wave.webaim.org/
- **axe-core:** https://www.deque.com/axe/
- **Pa11y:** https://pa11y.org/
- **Lighthouse:** Built into Chrome DevTools

### **Screen Readers**
- **NVDA:** https://www.nvaccess.org/ (Free)
- **JAWS:** https://www.freedomscientific.com/products/software/jaws/ (Commercial)
- **VoiceOver:** Built into macOS/iOS
- **TalkBack:** Built into Android

---

## 🏆 **Success Metrics**

### **Target Goals**
- **Lighthouse Score:** 95+
- **axe-core Violations:** 0 (Level A), <5 (Level AA)
- **Manual Testing:** 100% keyboard accessible
- **Screen Reader:** All content accessible
- **User Feedback:** Positive accessibility reviews

### **Monitoring**
- Weekly automated accessibility scans
- Monthly screen reader testing
- Quarterly user accessibility testing
- Annual professional BITV 2.0 audit