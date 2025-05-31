param(
    [Parameter(Mandatory=$true)]
    [string]$TagVersion
)

# 一時ファイルを作成
$tempFile = [System.IO.Path]::GetTempFileName()

# git-cliffで直前のtagから現在までの変更内容を生成し、一時ファイルに書き込む
git cliff "$(git describe --tags --abbrev=0)..HEAD" --tag $TagVersion > $tempFile

# 既存のCHANGELOG.mdの内容を取得
$existingContent = Get-Content CHANGELOG.md -Raw

# 新しい内容と既存の内容を結合
$newContent = (Get-Content $tempFile -Raw) + "`n" + $existingContent

# 結合した内容をCHANGELOG.mdに書き込む
$newContent | Set-Content CHANGELOG.md -NoNewline

# 一時ファイルを削除
Remove-Item $tempFile

Write-Host "CHANGELOG.md has been updated with version $TagVersion."
