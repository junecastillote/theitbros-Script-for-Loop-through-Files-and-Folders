# DeleteFilesByAge.ps1
[CmdletBinding(SupportsShouldProcess)]
param (
    # The top folder path
    [Parameter(Mandatory)]
    [String]
    $Folder,

    # The file age in days as threshold
    [Parameter(Mandatory)]
    [int]
    $FileAgeInDays,

    # Optional file extensions to include
    # eg. *.txt,*.pdf
    [Parameter()]
    [string[]]
    $FileExtension,

    # Switch to do a recursive deletion
    [Parameter()]
    [switch]
    $Recurse
)

# Calculate the date ceiling.
$ceilingDate = (Get-Date).AddDays(-$FileAgeInDays)

# Compose the Get-ChildItem parameters.
$fileSearchParams = @{
    Path    = $Folder
    Recurse = $Recurse
    File    = $true
    Force   = $true
}
if ($FileExtension) { $fileSearchParams += @{Include = $FileExtension } }

# Get files and delete.
Get-ChildItem @fileSearchParams | 
Where-Object {
    $_.CreationTime -lt $ceilingDate
} |
# Process each file
ForEach-Object {
    Try {
        Remove-Item $_.FullName -Force -ErrorAction Stop
        if (!($PSBoundParameters.ContainsKey('WhatIf'))) {
            "Deleted: $($_.FullName)" | Out-Default
        }        
    }
    Catch {
        "Failed: $($_.Exception.Message)" | Out-Default
    }
}

