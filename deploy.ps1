param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BaseName
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot

$Locations = @(
    @{
        Source = "C:\Users\adam\OneDrive\Documents\My Writing\_Essays\Occult"
        Dest   = Join-Path $RepoRoot "media"
        Tag    = "media"
    },
    @{
        Source = "C:\Users\adam\OneDrive\Documents\My Writing\_Essays\Psychology & Sexuality"
        Dest   = Join-Path $RepoRoot "extra"
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
# Make sure the local staging directory exists.
#
New-Item `
    -ItemType Directory `
    -Force `
    -Path $SelectedLocation.Dest |
    Out-Null

$UploadFiles = @()

foreach ($File in $MatchedFiles) {

    #
    # Canonicalize the filename for GitHub:
    # spaces in the basename become underscores.
    #
    $DestinationBaseName = $File.BaseName -replace ' ', '_'
    $DestinationName =
        $DestinationBaseName + $File.Extension

    $DestinationPath =
        Join-Path $SelectedLocation.Dest $DestinationName

    Write-Host "Copying:"
    Write-Host "  $($File.FullName)"
    Write-Host "  -> $DestinationPath"

    Copy-Item `
        -LiteralPath $File.FullName `
        -Destination $DestinationPath `
        -Force

    $UploadFiles += $DestinationPath
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

Write-Host ""
Write-Host "Deployment complete."
Write-Host ""

foreach ($File in $UploadFiles) {
    Write-Host "  $(Split-Path $File -Leaf)"
}
