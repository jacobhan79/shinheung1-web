# shinheung1-web 공개 + GitHub Pages 자동 배포
# 사전조건: gh auth login 으로 jacobhan79 계정 로그인 완료
$ErrorActionPreference = "Stop"
$gh = "C:\Program Files\GitHub CLI\gh.exe"
$repoName = "shinheung1-web"
$repoDir = "C:\Users\win\source\repos\shinheung1-web"
Set-Location $repoDir

# 0) 로그인 확인
& $gh auth status
$acct = (& $gh api user --jq ".login")
"로그인 계정: $acct"

# 1) 원격 저장소 생성(없으면) + push  (공개)
$exists = $false
try { & $gh repo view "$acct/$repoName" *> $null; $exists = $true } catch { $exists = $false }
if (-not $exists) {
  & $gh repo create "$acct/$repoName" --public --source "." --remote origin --push
} else {
  if (-not (git remote | Select-String origin)) { git remote add origin "https://github.com/$acct/$repoName.git" }
  git push -u origin main
}

# 2) GitHub Pages 활성화 (main 브랜치 루트)
try {
  & $gh api -X POST "repos/$acct/$repoName/pages" -f "source[branch]=main" -f "source[path]=/" *> $null
  "Pages 생성 요청 완료"
} catch {
  & $gh api -X PUT "repos/$acct/$repoName/pages" -f "source[branch]=main" -f "source[path]=/" *> $null
  "Pages 설정 갱신 완료"
}

"`n=== 완료 ===`n공개 URL: https://$($acct.ToLower()).github.io/$repoName/`n(빌드에 1~2분 소요)"
