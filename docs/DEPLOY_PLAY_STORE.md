# Google Play 스토어 배포 (CI/CD)

GitHub Actions를 사용해 Android App Bundle(AAB)을 빌드하고, 선택적으로 Google Play 내부 테스트 트랙에 배포하는 방법입니다.

## 1. 업로드 키스토어 생성 (최초 1회)

로컬에서 다음 명령으로 업로드용 키스토어를 생성합니다.

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- `upload-keystore.jks`: 키스토어 파일 (절대 Git에 커밋하지 말 것)
- `upload`: 키 별칭 (KEY_ALIAS)
- 입력한 비밀번호는 GitHub Secrets에 등록합니다.

## 2. GitHub Secrets 등록

저장소 **Settings → Secrets and variables → Actions**에서 다음 시크릿을 추가합니다.

| 시크릿 이름 | 설명 |
|------------|------|
| `KEYSTORE_BASE64` | 키스토어 파일을 Base64 인코딩한 값. 로컬에서: `base64 -w 0 upload-keystore.jks` (Linux/Mac) 또는 PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))` |
| `STORE_PASSWORD` | 키스토어 비밀번호 |
| `KEY_ALIAS` | 키 별칭 (예: `upload`) |
| `KEY_PASSWORD` | 키 비밀번호 (STORE_PASSWORD와 동일하게 둔 경우가 많음) |

### KEYSTORE_BASE64 생성 예시 (Windows PowerShell)

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```

생성된 문자열을 GitHub **KEYSTORE_BASE64** 시크릿 값에 붙여넣습니다.

## 3. 워크플로우 동작

- **main 브랜치에 push** 또는 **Actions 탭에서 "Build and Deploy to Play Store" 수동 실행** 시:
  1. Flutter 앱이 release 모드로 빌드됩니다.
  2. 등록한 키스토어로 AAB가 서명됩니다.
  3. `app-release.aab`가 **Artifacts**로 업로드됩니다.

Artifacts는 Actions 실행 결과 페이지에서 **Download**로 받을 수 있습니다. 이 AAB를 [Google Play Console](https://play.google.com/console) → 앱 → **출시** → **프로덕션/내부 테스트 등**에서 수동 업로드할 수 있습니다.

## 4. (선택) Play Store 자동 배포

수동 업로드 대신, **수동 실행(workflow_dispatch)** 시에만 Play Store **내부 테스트** 트랙으로 자동 배포하려면 아래를 설정합니다.

### 4.1 Google Play Console API 사용 설정

1. [Google Play Console](https://play.google.com/console) → **설정** → **API 액세스**에서 서비스 계정을 연결합니다.
2. **서비스 계정 만들기** 후 JSON 키를 다운로드합니다.
3. Play Console **사용자 및 권한**에서 해당 서비스 계정에 **앱 권한** 부여(예: 앱 선택 → 관리자 또는 출시 관리자).

### 4.2 GitHub Secret 추가

- **이름**: `PLAY_STORE_SERVICE_ACCOUNT_JSON`
- **값**: 위에서 받은 JSON 키 파일 **전체 내용**을 복사해 붙여넣습니다.

이후 **Actions** → **Build and Deploy to Play Store** → **Run workflow**로 수동 실행하면, 빌드 후 **Deploy to Play Store (Internal)** 단계가 실행되어 내부 테스트 트랙에 배포됩니다.

## 5. 버전 관리

- **versionName** / **versionCode**는 `pubspec.yaml`의 `version: 1.0.0+1`에서 관리됩니다.
- Play Store에 새로 올릴 때마다 버전을 올린 뒤 커밋·푸시하거나 수동 실행합니다.

## 6. 문제 해결

- **빌드 실패 (서명 관련)**: KEYSTORE_PATH, STORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD가 CI에만 설정됩니다. 로컬 `flutter build appbundle`은 debug 서명을 사용합니다.
- **Deploy 단계 실패**: PLAY_STORE_SERVICE_ACCOUNT_JSON이 정확한지, Play Console에서 해당 서비스 계정에 앱 권한이 있는지 확인하세요.
