# SoukJomla Release Guide

## Pre-Release Checklist

### Code & Versioning
- [ ] All features tested and working
- [ ] No `print()` or `debugPrint()` statements
- [ ] Error handling complete and user-friendly
- [ ] Update `pubspec.yaml` version: `version: 1.0.0+2`
- [ ] Commit and tag: `git tag v1.0.0`

### Android
- [ ] `minSdkVersion: 21` (or higher)
- [ ] `targetSdkVersion: 34`
- [ ] `compileSdkVersion: 34`
- [ ] `applicationId: com.soukjomla.app`
- [ ] All required permissions in `AndroidManifest.xml`

### iOS
- [ ] iOS deployment target: 12.0 or higher
- [ ] Update `Info.plist` with app metadata
- [ ] Bundle identifier matches App Store Connect

---

## Step 1: Generate Keystore (One-time)

Create a signing key for your app:

```bash
# macOS/Linux
keytool -genkey -v -keystore ~/soukjomla-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias soukjomla-key

# Windows
keytool -genkey -v -keystore C:\Users\%USERNAME%\soukjomla-key.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias soukjomla-key
```

When prompted, enter:
- **Keystore password**: Strong password (save it!)
- **Key password**: Same as keystore password
- **Name**: Your Name
- **Organization**: Souk Jomla
- **City**: Your City
- **State/Province**: Your State
- **Country Code**: MA (for Morocco)
- **CN confirmation**: Enter 'yes'

**⚠️ Save the keystore file and password securely. You'll need it for every release!**

---

## Step 2: Configure Signing in Flutter

### Create `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=soukjomla-key
storeFile=/full/path/to/soukjomla-key.jks
```

⚠️ **NEVER commit `key.properties` to Git!**

The `.gitignore` already excludes it:
```
**/android/key.properties
**/android/**/*.keystore
**/android/**/*.jks
```

---

## Step 3: Build Release APK (for testing)

```bash
cd soukjomla_flutter

flutter build apk \
  --release \
  --dart-define=FLAVOR=production \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.soukjomla.ma
```

**Output:** `build/app/outputs/apk/release/app-release.apk`

Test the APK on a device:
```bash
flutter install -d <device_id> --release
```

---

## Step 4: Build Release App Bundle (for Play Store)

Google Play Store requires `.aab` (App Bundle) format:

```bash
cd soukjomla_flutter

flutter build appbundle \
  --release \
  --dart-define=FLAVOR=production \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.soukjomla.ma
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## Step 5: Sign & Upload to Play Console

### Prerequisites
1. **Google Play Developer Account** ($25 one-time fee)
   - Register at: https://play.google.com/console
   - Accept Developer Agreement

2. **Create App in Play Console**
   - Package name: `com.soukjomla.app`
   - App name: "SoukJomla"

### Upload Bundle

1. Go to **Play Console** → Your App → **Release** → **Production**
2. Click **Create new release**
3. Upload `app-release.aab`
4. Review app details:
   - **App name**: SoukJomla
   - **Short description**: "Platform B2B لربط المشترين والبائعين بالجملة في المغرب"
   - **Full description**: See below
5. **Add screenshots** (at least 4):
   - Login screen
   - Product listing
   - Product detail
   - Chat screen
6. **Add content rating**:
   - Fill out Google Play Content Rating form
7. **Privacy policy**: Upload or link to your privacy policy
8. **Target audience**: Select "Everyone" or appropriate age group
9. Click **Review release** → **Start rollout**

---

## Step 6: Monitor Release

After approval (24-48 hours):

- Check **Release overview** in Play Console
- Monitor **Crashes & ANRs** if available
- Check **User reviews** for feedback
- Monitor **Install tracking**

---

## App Store Listing Content

### Title
SoukJomla

### Short Description
منصة للبيع بالجملة تربط المشترين والبائعين في المغرب

### Full Description
اكتشف أكبر منصة B2B في المغرب لشراء وبيع المنتجات بالجملة.

**للمشترين:**
- ابحث عن آلاف المنتجات من بائعين موثوقين
- احصل على أفضل الأسعار بالجملة
- تواصل مباشرة مع البائعين
- إدارة طلبياتك بسهولة

**للبائعين:**
- اعرض منتجاتك أمام آلاف المشترين
- زيادة مبيعاتك بالجملة
- إدارة مخزونك بسهولة
- تواصل فوري مع العملاء

**الفئات المتاحة:**
- المنسوجات والملابس
- الإلكترونيات
- المواد الغذائية
- الأثاث والديكور
- الصحة والجمال
- والمزيد...

### Privacy Policy URL
https://soukjomla.ma/privacy-policy

### Support Email
support@soukjomla.ma

### Website
https://soukjomla.ma

---

## Versioning Guide

```
Version format: MAJOR.MINOR.PATCH+BUILD

1.0.0+1  ← First release
1.0.1+2  ← Bug fix
1.1.0+3  ← New features (minor)
2.0.0+4  ← Major rewrite
```

**Update `pubspec.yaml`:**
```yaml
version: 1.0.0+1
```

---

## Testing Checklist Before Release

### Functional Testing
- [ ] Login/Signup flow
- [ ] Product search and filtering
- [ ] Product detail page
- [ ] Image upload
- [ ] Chat messages send/receive
- [ ] Order creation
- [ ] Payment (if applicable)
- [ ] Profile management

### Device Testing
- [ ] Test on Android 7+ (API 24+)
- [ ] Test on iOS 12+
- [ ] Test on both portrait & landscape
- [ ] Test on tablet and phone

### Performance
- [ ] No janky scrolling
- [ ] Images load quickly
- [ ] No excessive memory usage
- [ ] App launches in < 3 seconds

### Error Handling
- [ ] No internet → shows offline message
- [ ] Server 500 error → shows friendly message
- [ ] Timeout → shows retry button
- [ ] Invalid input → shows field errors

---

## Troubleshooting

### Build fails: "Keystore file not found"
```
✗ Check key.properties path is absolute
✗ Verify file permissions
✗ Check keystore exists at the path
```

### APK too large (> 100MB)
```bash
# Enable Proguard/R8 in release mode
# Add to android/app/build.gradle:
# minifyEnabled true
```

### App crashes after release
1. Check **Crashes & ANRs** in Play Console
2. Download crash logs
3. Check logcat:
   ```bash
   flutter logs
   ```
4. Fix and rollback if critical

### Users report "API error"
- Check backend is live
- Check API URL in release settings
- Check network connectivity from Play Console logs

---

## Non-Code Tasks (Do These in Play Console)

**Before submitting release:**
- [ ] Create store listing with screenshots
- [ ] Set content rating (IARC form)
- [ ] Upload privacy policy
- [ ] Set target audience
- [ ] Add support email
- [ ] Add support website
- [ ] Enable auto-update settings

**After approval:**
- [ ] Monitor crashes & reviews
- [ ] Respond to user reviews
- [ ] Monitor install trends
- [ ] Check ANR (Application Not Responding) rate

---

## Release Rollout Strategy

### Phase 1: Internal Testing (0% rollout)
- Deploy to internal testers
- Run full QA suite
- Test on various devices
- **Duration:** 1-2 weeks

### Phase 2: Closed Testing (5% rollout)
- Release to testers on Play Store
- Monitor crashes & feedback
- **Duration:** 3-5 days

### Phase 3: Open Release (100% rollout)
- Full rollout to all users
- Monitor reviews and crashes
- Prepare hotfix if needed

---

## Quick Commands Reference

```bash
# Clean build
flutter clean
cd android && ./gradlew clean && cd ..

# Build APK (release)
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.soukjomla.ma

# Build App Bundle (for Play Store)
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.soukjomla.ma

# Install on device
flutter install -d <device_id> --release

# View keystore info
keytool -list -v -keystore ~/soukjomla-key.jks

# Check version code
grep versionCode android/app/build.gradle
```

---

## Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Flutter Release Guide](https://flutter.dev/docs/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Release Guide](https://flutter.dev/docs/deployment/ios)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
