$MC_VERSION = "116"

$textureMapping = Import-Csv .\mapping.csv -Delimiter ','
$textureSizes = @( "32", "64", "128", "256", "512" )

# Clear old texture work folders
Remove-Item -Recurse -Path .\updated\Sphax* -ErrorAction Ignore
# Clear old built texture packs
if (Test-Path .\output) {
    Remove-Item -Path .\output\*.zip
}

# Create each pack for each size
foreach ($ts in $textureSizes) {
    $referencePath = ".\reference\Sphax_BigReactors_$($ts)x\"
    $updatePath =    ".\updated\Sphax_BiggerReactors_$($ts)x_$($MC_VERSION)\"
    if ((Test-Path $updatePath) -eq $false) {
        New-Item -ItemType Directory -Name $updatePath
    }

    foreach ($tx in $textureMapping) {
        if ([string]::IsNullOrWhiteSpace($tx.Original) -or [string]::IsNullOrWhiteSpace($tx.Renamed)) {
            # Some textures are unused, skip copying them
            continue
        }
        $originalName = $referencePath + $tx.Original
        $updatedName = $updatePath + $tx.Renamed
        # Create destination dir if not existing and copy
        Copy-Item -Path $originalName -Destination "$(New-Item -Path (Split-Path -path $updatedName) -ItemType Directory -Force)\$(Split-Path -path $updatedName -Leaf)" -Force
    }

    # Copy the updated pack data
    Copy-Item -Path .\packInfoFiles\pack.mcmeta -Destination $updatePath
    Copy-Item -Path .\packInfoFiles\pack.png -Destination $updatePath

    <# EXTRAS
    These are things that need to be edited or weren't present in the original texture pack
    #>

    # The debugtool is now in phosphophyllite, so we update the texture for that namespace
    $wrenchSourcePath = ".\reference\Sphax$($ts)x_ExtReactors_MC1.12\assets\bigreactors\textures\items\"
    $wrenchUpdatePath = "$updatePath\assets\phosphophyllite\textures\item"

    if ((Test-Path $wrenchUpdatePath) -eq $false) {
        New-Item -ItemType Directory -Name $wrenchUpdatePath
    }

    # Additionally, there is no texture pack for the wrench in 256 or 512 size, so we use the highest available for those packs (128)
    if ($ts -eq "256" -or $ts -eq "512") {
        Copy-Item -Path .\reference\Sphax128x_ExtReactors_MC1.12\assets\bigreactors\textures\items\wrench.png -Destination $wrenchUpdatePath\debug_tool.png
    } else {
        Copy-Item -Path $wrenchSourcePath\wrench.png -Destination $wrenchUpdatePath\debug_tool.png
    }

    # The turbine controller is not animated anymore, so I cropped the png to one block state. That texture needs to be updated again now
    $turbineControllerSourcePath = ".\reference\_editedFiles\Sphax_BigReactors_$($ts)x\assets\bigreactors\textures\blocks"
    $turbineControllerUpdatePath = "$updatePath\assets\biggerreactors\textures\block"

    Copy-Item -Path $turbineControllerSourcePath\tile.blockTurbinePart.controller.active-cropped.png -Destination $turbineControllerUpdatePath\turbine_terminal_active.png

    # PowerShell's Compress-Archive has something weird with it, Minecraft can't read the textures from the zip if created this way
    # 7z works fine though
    if ((Test-Path .\output) -eq $false) {
        New-Item -Name output -ItemType Directory
    }
    & 'C:\Program Files\7-Zip\7z.exe' a "output\Sphax_BiggerReactors_$($ts)x_$($MC_VERSION).zip" ".\updated\Sphax_BiggerReactors_$($ts)x_$($MC_VERSION)\*"
}