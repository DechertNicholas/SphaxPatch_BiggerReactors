[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $version
)
$packNames = Get-ChildItem .\output
foreach ($pack in $packNames) {
    $bName = $pack.Name.Split('.')[0]
    $vName = "$($bName)_$version"
    Move-Item -Path ".\output\$($pack.Name)" -Destination ".\output\$($vName).zip"
}