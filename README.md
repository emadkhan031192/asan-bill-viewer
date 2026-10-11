# Asan Bill Viewer — آسان بل ویور

One app to view Pakistani utility bills **from official sources only**.
Bills open inside the app, but only on the official utility website.
No scraping, no backend, no accounts, no analytics. Everything stays on the phone.

## Features

- **14 providers, one data file** — 10 PITC electricity companies (LESCO, GEPCO,
  FESCO, IESCO, MEPCO, PESCO, HESCO, SEPCO, QESCO, TESCO), K-Electric, SNGPL,
  SSGC, PTCL and WASA Lahore. Adding a provider is a single entry in
  `lib/core/data/providers.dart`.
- **Bill Viewer** — the official bill page in an in-app WebView (JavaScript on)
  with a strict domain allowlist: any navigation outside the provider's
  official domains is blocked with a snackbar. Your reference number stays
  pinned at the bottom with a Copy button.
- **Torn payment slip** — saved bills render as a torn slip (CustomPainter:
  utility-colour top band, edge notches, dashed tear line) with amount, status
  chip (Paid / Due in N days / Due today / Overdue) and due date.
- **Save PDF** — the loaded bill page is rendered by an offscreen WebView and
  captured to a paginated A4 PDF (native `PdfDocument`, no print dialog, no
  extra dependencies) stored in the on-device **Vault** (app-private storage;
  no storage permission requested).
- **Scan** — on-device OCR (ML Kit, bundled model, works offline) reads the
  reference/account number from a printed bill through the camera or gallery,
  suggests the provider from the digit count, and asks you to confirm the
  company when it can't be inferred.
- **English + اردو** — instant switch from the Home pill or Settings; Urdu
  flips the whole UI to RTL with Noto Nastaliq Urdu (generous line height, no
  clipping). Numbers always stay in Western digits.
- **Light / dark themes** following the system, with manual override.
- **Offline-friendly** — friendly retry screen in the viewer; saved bills and
  the Vault work without internet.

## Project layout

```
lib/
  main.dart                 entry (loads SharedPreferences, overrides provider)
  app.dart                  MaterialApp + bottom navigation shell
  core/
    data/providers.dart     THE provider registry (add one entry per provider)
    l10n/strings.dart       every user-facing string in EN + UR
    theme/app_theme.dart    palettes, Sora/Manrope/Nastaliq text themes
    format.dart             Rs / byte / date formatting (Western digits)
  models/                   SavedBill, VaultFile, due-status logic
  state/                    Riverpod: settings, saved bills, vault (+debug seed)
  services/                 validators, domain allowlist, OCR, PDF channel
  widgets/                  slip card painter, official badge, tiles, sheets
  screens/                  home, lookup, viewer, scan, vault, settings
test/                       unit + widget tests
tools/
  patch_android.sh/.py      wires permissions, MainActivity, R8, icons into android/
  android/                  MainActivity.kt.template, proguard rules, icon res/
  make_icon.py              regenerates the launcher icon
assets/fonts/               bundled Sora / Manrope / Noto Nastaliq Urdu
```

## Run it

Prerequisites: Flutter stable, Java 17, an Android device or emulator.

```bash
flutter create --platforms=android --org dev.asanbill --project-name asan_bill_viewer .
bash tools/patch_android.sh   # permissions, PDF channel, R8, launcher icons
flutter pub get
flutter analyze
flutter test
flutter run
```

Debug builds show a **"Load demo bills"** button in Settings (guarded by
`kDebugMode`). Release builds never seed fake data.

## Add a provider

Append one `BillProvider` to `kProviders` in `lib/core/data/providers.dart`:

```dart
BillProvider(
  id: 'newco',                 // stable id
  code: 'NEWCO',               // short code for tiles/slips
  nameEn: 'New Company',
  nameUr: 'نیو کمپنی',
  kind: UtilityKind.electricity,
  url: 'https://bill.newco.pk/check',
  allowedDomains: ['bill.newco.pk', 'newco.pk'],  // viewer allowlist
  minLength: 14,
  maxLength: 14,
  hintEn: '14-digit reference number',
  hintUr: '14 ہندسوں کا ریفرنس نمبر',
),
```

Home tiles, Lookup validation, the viewer allowlist, the trust list in
Settings and Vault grouping all pick it up automatically.

## Build a release APK

```bash
flutter build apk --release --split-per-abi
```

Size measures: `--split-per-abi`, R8 + resource shrinking (see
`tools/patch_android.sh`), minimal dependencies, and subset fonts
(Noto Nastaliq Urdu is subset to the characters the app actually uses).
Target: under 15 MB per ABI APK.

CI (`.github/workflows/build.yml`, "Build Asan Bill Viewer APK"): checkout →
Java 17 → Flutter stable (cached) → `flutter create` if `android/` is missing
→ patch → `pub get` → `analyze` → `test` → `build apk --release
--split-per-abi` → upload artifacts → attach to a GitHub Release on `v*` tags.

## By hand (what the automation can't do)

1. **Signing key** — CI signs with debug keys. For the Play Store, create an
   upload keystore, add a `key.properties`, and point the release
   `signingConfig` at it (keep the keystore and passwords out of git).
2. **Store listing** — Play Console listing, screenshots, data-safety form
   (note: no data leaves the device; INTERNET + CAMERA are the only
   permissions, no storage permission).
3. **Manual QA on a real device** — camera/OCR, WebView rendering of each
   provider page, and the native PDF print on your target Android versions.

## Provider URL verification (2026-10-11)

Each official URL was live-checked (read-only, no forms submitted):

- ✅ `bill.pitc.com.pk/lescobill` — loads ("LESCO BILL / Search Your
  Electricity Bill"); the 14-digit reference rule is confirmed by PITC-linked
  sources. All 10 DISCO paths follow the `/<name>bill` convention (the GEPCO
  spot-check was unreachable from the check network, but LESCO verified the
  pattern live).
- ✅ `viewbill.ssgc.com.pk` — loads, redirects to `/web/`, and is a bill
  lookup page asking for the **10-digit Customer Number**. The data file and
  tests were updated to require exactly 10 digits for SSGC.
- ✅ K-Electric 13-digit account number — confirmed via KE's official
  channels.
- ✅ SNGPL consumer number — official guidance says 11 digits (the app allows
  8–12, which covers it).
- ⚠️ `bill.ke.com.pk` — does not resolve (DNS NXDOMAIN) from the check
  network; `ke.com.pk` loads but is the corporate homepage, not a bill
  lookup page. URL kept per spec — re-check on a real device in Pakistan.
- ⚠️ `bill.sngpl.com.pk` — does not resolve (DNS NXDOMAIN); `sngpl.com.pk`
  shows a TLS certificate warning.
- ⚠️ `dbill.ptcl.net.pk` — connection closed, unreachable from the check
  network (may be geo-restricted rather than dead).
- ⚠️ `wasa.lahore.gop.pk` — does not resolve (DNS NXDOMAIN).

Some failures may be specific to the check network rather than the sites
themselves. On a real device in Pakistan, open each provider's Lookup: if a
page fails to load, update that provider's `url` (and `allowedDomains` if the
host changed) in `lib/core/data/providers.dart` — one entry per provider.

## Privacy

- No accounts, no analytics, no tracking, no backend.
- Bills load only on official utility domains; off-domain links are blocked.
- Saved bills, settings and PDFs live in app-private storage on the phone.
- OCR runs on-device (bundled ML Kit model).
- Android permissions: INTERNET and CAMERA only. No storage permission.
