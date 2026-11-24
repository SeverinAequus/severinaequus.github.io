param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BaseName
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot

$Locations = @(
    @{
        Source = "C:\Users\adam\OneDrive\Documents\My Writing\_Essays\Occult"
        Dest   = Join-Path $RepoRoot "_media"
        Tag    = "media"
    },
    @{
        Source = "C:\Users\adam\OneDrive\Documents\My Writing\_Essays\Psychology & Sexuality"
        Dest   = Join-Path $RepoRoot "_extra"
        Tag    = "extra"
    }
)

function Normalize-BaseName {
    param([string]$Name)

    # Treat spaces and underscores as equivalent for matching.
    return ($Name -replace '_', ' ').Trim()
}

$RequestedName = Normalize-BaseName $BaseName

$SelectedLocation = $null
$MatchedFiles = @()

#
# Search media first, then extra.
#
foreach ($Location in $Locations) {

    $Matches = @(
        Get-ChildItem -LiteralPath $Location.Source -File |
        Where-Object {
            (Normalize-BaseName $_.BaseName) -eq $RequestedName
        }
    )

    if ($Matches.Count -gt 0) {
        $SelectedLocation = $Location
        $MatchedFiles = $Matches
        break
    }
}

if (-not $SelectedLocation) {
    Write-Error "No files found matching base name '$BaseName'."
    exit 1
}

Write-Host ""
Write-Host "Found in: $($SelectedLocation.Source)"
Write-Host "Release tag: $($SelectedLocation.Tag)"
Write-Host ""

#
# Documents (.md, .pdf, .txt) go into the subpage's directory in the repo,
# which you then commit. Media (.mp4, .m4a) is too large for the repo and
# goes to the release instead, by way of a temporary staging directory.
# Anything else is skipped.
#
$DocumentExtensions = @('.md', '.pdf', '.txt')
$MediaExtensions    = @('.mp4', '.m4a')

$StagingDir = Join-Path ([System.IO.Path]::GetTempPath()) "deploy-$($SelectedLocation.Tag)"

New-Item -ItemType Directory -Force -Path $SelectedLocation.Dest | Out-Null
New-Item -ItemType Directory -Force -Path $StagingDir | Out-Null

$CopiedFiles = @()
$UploadFiles = @()

foreach ($File in $MatchedFiles) {

    #
    # Canonicalize the filename: spaces in the basename become underscores.
    #
    $DestinationName = ($File.BaseName -replace ' ', '_') + $File.Extension
    $Extension = $File.Extension.ToLowerInvariant()

    if ($DocumentExtensions -contains $Extension) {
        $DestinationPath = Join-Path $SelectedLocation.Dest $DestinationName
        $CopiedFiles += $DestinationPath
    }
    elseif ($MediaExtensions -contains $Extension) {
        $DestinationPath = Join-Path $StagingDir $DestinationName
        $UploadFiles += $DestinationPath
    }
    else {
        Write-Host "Skipping $($File.Name) (not a document or media file)"
        continue
    }

    Write-Host "Copying:"
    Write-Host "  $($File.FullName)"
    Write-Host "  -> $DestinationPath"

    Copy-Item `
        -LiteralPath $File.FullName `
        -Destination $DestinationPath `
        -Force
}

Write-Host ""
Write-Host "Uploading release assets..."
Write-Host ""

foreach ($File in $UploadFiles) {

    Write-Host "Uploading $(Split-Path $File -Leaf)..."

    gh release upload `
        $SelectedLocation.Tag `
        $File `
        --clobber

    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub upload failed for '$File'."
        exit $LASTEXITCODE
    }
}

Remove-Item -LiteralPath $StagingDir -Recurse -Force

Write-Host ""
Write-Host "Deployment complete."
Write-Host ""
Write-Host "Uploaded to release '$($SelectedLocation.Tag)':"
foreach ($File in $UploadFiles) {
    Write-Host "  $(Split-Path $File -Leaf)"
}
Write-Host "Copied into the repo (commit and push these):"
foreach ($File in $CopiedFiles) {
    Write-Host "  $File"
}
