# 📋 TidyDuu Release Checklist

Use this checklist to verify that all code checks, builds, documentation, and Git tags are complete before publishing a new release on GitHub.

---

## 🛠️ Code Validation
- [ ] **Code Formatting**: Ensure all files conform to standard code formatting:
  ```bash
  dart format --output=none --set-exit-if-changed .
  ```
- [ ] **Static Analysis**: Verify there are no compiler warnings or linter errors:
  ```bash
  flutter analyze
  ```
- [ ] **Automated Testing**: Run the complete suite of unit and widget tests to guarantee zero regression:
  ```bash
  flutter test
  ```

---

## 📦 Production Builds
Verify that all targeted platforms build successfully without compilation issues:
- [ ] **Android Standalone APK**:
  ```bash
  flutter build apk --release
  ```
- [ ] **Android App Bundle (for Play Store)**:
  ```bash
  flutter build appbundle --release
  ```
- [ ] **iOS Build**:
  ```bash
  flutter build ios --release --no-codesign
  ```

---

## 🎨 Presentation Assets & Docs
- [ ] **Screenshot Verification**: Check that all screenshots in `assets/screenshots/` (light/dark/android/ios) are correctly captured, high-res, and do not contain test overlays or debug banners.
- [ ] **README Review**: Confirm the tagline, badges, architecture diagram, feature highlights, and release setup notes in `README.md` are accurate and fully complete.
- [ ] **CHANGELOG Review**: Check that all new features, bug fixes, quality improvements, and infrastructure changes are cataloged under the release version tag in `CHANGELOG.md`.

---

## 🔒 Security Checks
- [ ] **No Sensitive Files**: Ensure no private configuration files, local keys, keystores, or platform configs are tracked by git. Run:
  ```bash
  git status --ignored
  ```
  Double-check that `.env`, `*.keystore`, `*.jks`, `local.properties`, `google-services.json`, or Xcode provisioning profiles are not staged.

---

## 🏷️ Git Tag & Release
- [ ] **Version Verification**: Verify the version string in `pubspec.yaml` matches the release tag (e.g. `version: 0.1.0+1`).
- [ ] **Create Tag**: Create and push the semantic Git tag:
  ```bash
  git tag -a v0.1.0 -m "Release v0.1.0"
  git push origin v0.1.0
  ```
- [ ] **GitHub Releases**: Go to the GitHub Releases page, select the tag `v0.1.0`, paste the release notes from `docs/github-release-v0.1.0.md`, attach the compiled `.apk` asset, and publish.
