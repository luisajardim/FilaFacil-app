$ErrorActionPreference = 'Stop'
Set-Location "c:\Users\jardi\FilaFacil-app"
Write-Output "Staging changes (excluding Documentação) ..."
git add -A
try {
    git reset -- 'Documentação' 2>$null
} catch {
    # ignore
}

$commitMsg = 'Migrate DB to SQLite; update README and docs to reflect SQLite; tested endpoints'
Write-Output "Committing: $commitMsg"
git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) { Write-Output 'No changes to commit' }

Write-Output 'Pulling remote changes with rebase...'
$pullOk = $true
try {
    git pull --rebase origin HEAD
} catch {
    Write-Output 'Rebase failed; attempting to auto-resolve conflicts in Documentação by preferring local changes.'
    $pullOk = $false
}

if (-not $pullOk) {
    while ($true) {
        $conflicts = git diff --name-only --diff-filter=U
        if (-not $conflicts) { break }
        foreach ($f in $conflicts) {
            if ($f -like 'Documentação*') {
                Write-Output "Auto-resolving conflict in $f by keeping local version"
                git checkout --ours -- "$f"
                git add "$f"
            } else {
                Write-Output "Found conflict in $f (outside Documentação). Aborting. Resolve manually."
                exit 1
            }
        }
        # continue rebase
        git rebase --continue
    }
}

Write-Output 'Pushing to origin HEAD...'
git push origin HEAD
Write-Output 'Push completed.'
