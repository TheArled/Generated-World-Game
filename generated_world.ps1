# Initialize variables
$map = ""
$render = 9 # Has to be uneven number for center position to work
$patches = $render * $render
$pos = ($patches - 1) / 2
$terrain = "   ", "[#]", "[o]", "[+]", "[*]", "Null" # Random number generator never returns last element, so it's unused
$key = $null

# Generate map function
function GenerateMap($pos, $patches, $terrain) {
    $map = ""
    for ($i = 0; $i -lt $patches; $i++) {
        if ($i -eq $pos) { $map += 0 }
        else { $map += GeneratePatch $terrain }
    }
    return $map
}

# Generate patch function
function GeneratePatch($terrain) {
    $r = Get-Random -Minimum 0 -Maximum 100
    if ($r -lt 60) { return 0 }
    else { return (Get-Random -Minimum 1 -Maximum ($terrain.Count - 1)) }
}

# Draw map function
function DrawMap($map, $render, $patches, $pos, $terrain) {
    Clear-Host
    $line = ""
    for ($i = 0; $i -lt $patches; ) {
        if ($i -eq $pos) { $line += " X " }
        else { $line += $terrain[[string]$map[$i]] }
        if (++$i % $render -eq 0) {
            Write-Host $line
            $line = ""
        }
    }
}

# Move up function
function MoveUp($map, $render, $pos) {
    if ($map[$pos - $render] -ne "0") { continue }
    $chunk = ""
    for ($i = 0; $i -lt $render; $i++) { $chunk += GeneratePatch $terrain }
    return $chunk + $map.Substring(0, $patches - $render)
}

# Move down function
function MoveDown($map, $render, $pos) {
    if ($map[$pos + $render] -ne "0") { continue }
    $chunk = ""
    for ($i = 0; $i -lt $render; $i++) { $chunk += GeneratePatch $terrain }
    return $map.Substring($render, $patches - $render) + $chunk
}

# Move left function
function MoveLeft($map, $render, $pos) {
    if ($map[$pos - 1] -ne "0") { continue }
    $newMap = ""
    for ($i = 0; $i -lt $render; $i++) {
        $newMap += GeneratePatch $terrain
        $newMap += $map.Substring($i * $render, $render - 1)
    }
    return $newMap
}

# Move right function
function MoveRight($map, $render, $pos) {
    if ($map[$pos + 1] -ne "0") { continue }
    $newMap = ""
    for ($i = 0; $i -lt $render; $i++) {
        $newMap += $map.Substring($i * $render + 1, $render - 1)
        $newMap += GeneratePatch $terrain
    }
    return $newMap
}

function LoadGame($pos, $patches, $terrain) {
    if (Test-Path -Path "./save.txt") {
        return Get-Content -Path "./save.txt"
    }
    return GenerateMap $pos $patches $terrain
}

# Save game function
function SaveGame($map) {
    Set-Content -Path "./save.txt" -Value $map
}

# Prompt user to start
Write-Host "Press Enter to start"
do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
    
    if ($key -eq 27 -or $key -eq 81) { exit }
} until ($key -eq 13)

# Generate map
$map = GenerateMap $pos $patches $terrain

# Game loop
do {
    # Draw the map
    DrawMap $map $render $patches $pos $terrain

    # Prompt user for next action
    Write-Host "Press w,a,s,d to move or q to quit"
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

    # Regenerate the map
    if ($key -eq 82) { $map = GenerateMap $pos $patches $terrain }

    # Load save
    if ($key -eq 73) { $map = LoadGame $pos $patches $terrain }
    
    # Save game
    if ($key -eq 69) { SaveGame $map }

    # Move up
    if ($key -eq 87 -or $key -eq 38) { $map = MoveUp $map $render $pos }

    # Move down
    if ($key -eq 83 -or $key -eq 40) { $map = MoveDown $map $render $pos }

    # Move left
    if ($key -eq 65 -or $key -eq 37) { $map = MoveLeft $map $render $pos }

    # Move right
    if ($key -eq 68 -or $key -eq 39) { $map = MoveRight $map $render $pos }

    # Quit game
} until ($key -eq 27 -or $key -eq 81)

# Game end message
Write-Host "Thank you for exploring!"