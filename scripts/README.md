# scripts

## auto-pr-on-10-changes.sh

**변경사항이 10개 이상일 때** 자동으로 다음을 수행합니다.

1. `git pull origin <기본브랜치>` 로 최신화  
2. 변경된 파일이 10개 이상이면 한 번에 커밋  
3. 현재 브랜치가 기본 브랜치(main)이면 `auto-pr/날짜-시간` 브랜치 생성  
4. `git push origin <현재브랜치>`  
5. **GitHub CLI(`gh`)** 가 있으면 `gh pr create --fill` 로 PR 생성  

### 기준

- **변경 파일 10개 이상**: `git status --short` 기준 (추적 중인 파일의 수정/추가/삭제)  
- **또는** **커밋 10개 이상**: `origin/main`(또는 원격 기본 브랜치) 대비 앞선 커밋 수  

둘 중 하나만 만족해도 위 흐름이 실행됩니다.

### 사용 방법

1. **수동 실행** (Git Bash 또는 WSL에서)  
   ```bash
   chmod +x scripts/auto-pr-on-10-changes.sh   # 최초 1회
   ./scripts/auto-pr-on-10-changes.sh
   ```

2. **자동 실행 (커밋 시)**  
   `post-commit` 훅이 이미 `.git/hooks/post-commit` 에 설치되어 있습니다.  
   훅을 실행 가능하게 만들려면 (Git Bash에서):  
   ```bash
   chmod +x .git/hooks/post-commit
   ```  
   이후 **커밋할 때마다** 스크립트가 실행되고,  
   **main 대비 커밋이 10개 이상**이면 그때 push + PR 생성이 시도됩니다.

### 필요 사항

- **PR 자동 생성**: [GitHub CLI](https://cli.github.com/) 설치 후 `gh auth login`  
- 기본 브랜치가 `main`이 아니면 환경변수로 지정 가능:  
  `GIT_DEFAULT_BRANCH=flutter ./scripts/auto-pr-on-10-changes.sh`
