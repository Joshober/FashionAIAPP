<#
.SYNOPSIS
  Creates Fashion AI roadmap labels and GitHub issues from docs/gh-issues/*.md

.DESCRIPTION
  Requires GitHub CLI (gh) and authentication (`gh auth login` or GH_TOKEN with repo scope).
  Does not read .env and does not embed API keys in issue bodies.

.PARAMETER Repo
  Optional "owner/name" override. Default: parsed from `git remote get-url origin`.
#>
param(
  [string] $Repo = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$IssuesDir = Join-Path $RepoRoot "docs/gh-issues"

if (-not (Test-Path $IssuesDir)) {
  throw "Missing issues directory: $IssuesDir"
}

Push-Location $RepoRoot
try {
  if (-not $Repo) {
    $origin = (git remote get-url origin 2>$null).Trim()
    if ($origin -match "github\.com[:/](?<owner>[^/]+)/(?<name>[^/.]+)(\.git)?$") {
      $Repo = "$($Matches['owner'])/$($Matches['name'])"
    }
  }
  if (-not $Repo) {
    throw "Could not determine GitHub repo. Pass -Repo owner/name or set origin to a github.com URL."
  }

  $labels = @(
    @{ Name = "area:backend"; Color = "0E8A16"; Description = "Express/Mongo/HF/OpenRouter" },
    @{ Name = "area:flutter"; Color = "1D76DB"; Description = "Flutter client" },
    @{ Name = "type:chore"; Color = "FBCA04"; Description = "Scaffold/docs/tests" }
  )

  foreach ($l in $labels) {
    gh label create $l.Name --color $l.Color --description $l.Description -R $Repo 2>$null | Out-Null
  }

  $issues = @(
    @{ Title = "Backend: scaffold Express API under backend/"; File = "01-backend-skeleton.md"; Labels = @("area:backend") },
    @{ Title = "Backend: Mongoose models + Auth0 JWT + user scoping"; File = "02-mongo-auth.md"; Labels = @("area:backend") },
    @{ Title = "Backend: HF Space classify (multipart + vit-base64)"; File = "03-classify-hf.md"; Labels = @("area:backend") },
    @{ Title = "Backend: Prendas CRUD + upload pipeline"; File = "04-prendas-crud.md"; Labels = @("area:backend") },
    @{ Title = "Backend: Outfits recommend/save/list + GET/PATCH /api/me"; File = "05-outfits-me.md"; Labels = @("area:backend") },
    @{ Title = "Backend: Mirror + chat via OpenRouter (optional audio)"; File = "06-mirror-chat.md"; Labels = @("area:backend") },
    @{ Title = "Backend: contract docs + mocked integration tests"; File = "07-backend-tests-docs.md"; Labels = @("area:backend", "type:chore") },
    @{ Title = "Flutter: API client, Auth0, dart-define for API_BASE_URL"; File = "08-flutter-integration.md"; Labels = @("area:flutter") },
    @{ Title = "Flutter: screens wired to backend until SPA parity"; File = "09-flutter-ui.md"; Labels = @("area:flutter") }
  )

  foreach ($i in $issues) {
    $bodyFile = Join-Path $IssuesDir $i.File
    if (-not (Test-Path $bodyFile)) {
      throw "Missing body file: $bodyFile"
    }
    $ghArgs = @("issue", "create", "-R", $Repo, "--title", $i.Title, "--body-file", $bodyFile)
    foreach ($lb in $i.Labels) {
      $ghArgs += "--label"
      $ghArgs += $lb
    }
    Write-Host "Creating: $($i.Title)"
    & gh @ghArgs
  }

  Write-Host "Done. Verify with: gh issue list -R $Repo --label `"area:backend`""
  Write-Host "              and: gh issue list -R $Repo --label `"area:flutter`""
}
finally {
  Pop-Location
}
