# CellSense App Store Connect Metadata & Submission Details

This document contains all the text, configurations, and metadata assets required to publish **CellSense** on the iOS App Store. Copy and paste these fields directly into App Store Connect.

---

## 🏷️ General App Information

### 1. App Name (Title)
*   **Text**: `CellSense — Battery ROI Calc`
*   **Length**: 28 / 30 characters
*   **Guidelines**: Include key features (Battery, ROI, Calculator) to maximize search visibility.

### 2. Subtitle
*   **Text**: `Estimate Home Battery Savings`
*   **Length**: 29 / 30 characters
*   **Guidelines**: Explains the core utility value proposition immediately.

### 3. Promotional Text
*   **Text**: `Scan your electricity bill to instantly calculate home solar & battery ROI. Discover your NEM 3.0 savings today!`
*   **Length**: 118 / 170 characters
*   **Guidelines**: Appears at the top of the App Store product detail page (can be updated without submitting a new binary).

### 4. Description
```text
CellSense is a modern, serverless home battery ROI calculator designed to help you analyze solar battery savings under NEM 3.0, Time-of-Use (TOU) arbitrage, and Virtual Power Plant (VPP) configurations.

Maximize your energy independence. Import or scan your PGE, SCE, or SDGE electricity bills using Apple's built-in VisionKit OCR to instantly prefill your utility rate plan and monthly usage.

KEY FEATURES:
• Bill Parsing: Instantly extract utility, rate plan, and energy costs from PDF bills or photo screenshots.
• NEM 3.0 Analysis: Evaluate solar export value under California's Net Billing Tariff.
• Arbitrage Calculator: Simulates energy shifting (charging during off-peak hours, discharging during peak hours).
• VPP Calculations: Model additional income from Virtual Power Plant programs.
• Clean Interactive Charts: Compare paybacks for industry-leading batteries (Base Power, Tesla Powerwall 3, and Enphase 5P).

PRIVACY-FIRST:
CellSense performs 100% of OCR scanning and calculation locally on-device. No images, PDF documents, or personal energy data are ever transmitted to external servers. No login or accounts required.
```

### 5. Keywords
*   **Text**: `solar battery,roi calculator,nem 3.0,pge bill scanner,powerwall,enphase,energy arbitrage,electricity savings,vpp calculator`
*   **Length**: 109 / 100 characters (Trim to: `solar battery,roi calculator,nem 3.0,bill scanner,powerwall,enphase,energy arbitrage,savings,vpp`)
*   **Optimized Keywords**: `solar battery,roi calculator,nem 3.0,bill scanner,powerwall,enphase,energy arbitrage,savings,vpp`

---

## 🌐 URLs & Support

*   **Support URL**: `https://github.com/mrbese/cellsense` (Or your personal website support page)
*   **Marketing URL**: `https://github.com/mrbese/cellsense`
*   **Privacy Policy URL**: `https://mrbese.github.io/cellsense/privacy.html` (Points to the hosted `docs/privacy.html` page)

---

## 🔒 Privacy & Permissions (Info.plist Justifications)

When Xcode uploads your build, App Store Connect checks for system permission keys. You must provide the same justifications on the **App Privacy** screen:

### Camera Usage Description
*   **Key**: `NSCameraUsageDescription`
*   **Text**: `CellSense needs camera access to scan your electricity bills for automatic form autofill.`
*   **Reviewer Justification**: Required for the standard VisionKit document camera (`VNDocumentCameraViewController`) which parses printed paper utility bills on-device.

### Data Collection Disclosure
On the App Store Connect **App Privacy** questionnaire, select:
1.  **Do you collect data?**: **No, we do not collect any data.**
2.  **Justification**: All processing (document scanning, OCR, financial modeling) is performed locally inside the app sandbox on the user's device. No user identifier or behavioral data is tracked or uploaded.

---

## 📦 App Store Review Notes (For Apple Reviewers)

To ensure a smooth, rejection-free review cycle (preventing rejections under **Guideline 2.1 - App Completeness** or **Guideline 5.1.1 - Privacy**), paste this text in the **App Review Notes** box:

```text
Dear App Review Team,

CellSense is a home energy solar/battery ROI utility app. 
To facilitate testing, please note:
1. The app does not require a login or account registration. All features are fully accessible upon launch.
2. The "Scan Bill" feature can be tested on the simulator or physical device. For OCR testing, you can use the "Files App" or "Photos Library" options to upload an image of a standard utility bill.
3. 100% of OCR scanning and financial logic is executed locally on-device using Apple's Vision framework (VNRecognizeTextRequest). No external API or server-side calls are made, guaranteeing total user privacy.
4. The app is locked to Portrait orientation for consistent form layout design. The UIRequiresFullScreen plist flag has been enabled to conform to iPadOS orientation standards.

Thank you,
CellSense Developer Team
```
