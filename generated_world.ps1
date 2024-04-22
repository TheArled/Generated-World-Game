$render = 9
$terrain = '   ', '[#]', '[o]', '[+]', '[*]', 'Null' # Random number generator never returns last element, so it's unused
$key = $null

function LoadMap ($render, $terrain) {
    if (Test-Path -Path './save') {
        return (Get-Content -Path './save') -Split ' '
    }
    return GenerateMap $render $terrain
}

function SaveMap($width, $pos, $map) {
    Set-Content -Path "./save" -Value $width$pos$map
}

function GenerateMap($render, $terrain) {
    $patches = $render * $render
    $width = $render
    $pos = ($patches - 1) / 2
    $map = ''
    for ($i = 0; $i -lt $patches; $i++) {
        if ($i -eq $pos) { $map += 0 }
        else { $map += GeneratePatch $terrain }
    }
    return $width, $pos, $map
}

function GeneratePatch($terrain) {
    $r = Get-Random -Minimum 0 -Maximum 100
    if ($r -lt 60) { return 0 }
    else { return (Get-Random -Minimum 1 -Maximum ($terrain.Count - 1)) }
}

function DrawMap($render, $width, $pos, $map, $terrain) {
    $p = $pos + ((1 - $render - $width * $render + $width) / 2)
    $s = $p
    Clear-Host
    for ($y = 0; $y -lt $render; $y++) {
        $l = ''
        for ($x = 0; $x -lt $render; $x++) {
            if ($p -eq $pos) { $l += ' X ' } else { $l += $terrain[[string]$map[$p]] }
            $p++
        }
        if ($l -Match 'X') {
            foreach ($w in $l -Split '(X)') {
                if ($w -eq 'X') { Write-Host $w -ForegroundColor Blue -NoNewline }
                else { Write-Host $w -ForegroundColor Gray -NoNewline }
            }
            Write-Host ''
        }
        else { Write-Host $l -ForegroundColor Gray }
        $p = $s + $width
        $s = $p
    }
}

function WriteMessage($m) {
    if ($m -eq 0) {
        Write-Host 'Move: w, a, s, d' -ForegroundColor Yellow
        Write-Host 'Quit/New: q, n' -ForegroundColor Yellow
        Write-Host 'Save/Load: e, r' -ForegroundColor Yellow
        Write-Host 'Help: h' -ForegroundColor Yellow
    }
    elseif ($m -eq 1) {
        Write-Host 'You ran into a wall; Ouch!' -ForegroundColor Yellow
    }
}

function MoveUp($width, $pos, $map, $terrain) {
    if ($map[$pos - $width] -ne '0') {
        return $width, $pos, $map, 1
    }
    $chunk = ''
    for ($i = 0; $i -lt $width; $i++) {
        $chunk += GeneratePatch $terrain
    }
    $map = $chunk + $map
    return $width, $pos, $map
}

function MoveDown($width, $pos, $map, $terrain) {
    if ($map[$pos + $width] -ne '0') {
        return $width, $pos, $map, 1
    }
    $chunk = ''
    for ($i = 0; $i -lt $width; $i++) {
        $chunk += GeneratePatch $terrain
    }
    $pos += $width
    $map += $chunk
    return $width, $pos, $map
}

function MoveLeft($width, $pos, $map, $terrain) {
    if ($map[$pos - 1] -ne '0') {
        return $width, $pos, $map, 1
    }
    $height = $map.Length / $width
    $newMap = ''
    for ($i = 0; $i -lt $height; $i++) {
        $newMap += GeneratePatch $terrain
        $newMap += $map.Substring($i * $width, $width)
    }
    $pos += [math]::Floor($pos / $width)
    $width++
    return $width, $pos, $newMap
}

function MoveRight($width, $pos, $map, $terrain) {
    if ($map[$pos + 1] -ne '0') {
        return $width, $pos, $map, 1
    }
    $height = $map.Length / $width
    $newMap = ''
    for ($i = 0; $i -lt $height; $i++) {
        $newMap += $map.Substring($i * $width, $width)
        $newMap += GeneratePatch $terrain
    }
    $pos += [math]::Floor($pos / $width) + 1
    $width++
    return $width, $pos, $newMap
}

$data = LoadMap $render $terrain

# Prompt user to start
Write-Host "Press Enter to start" -ForegroundColor Green
do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
    
    if ($key -eq 27 -or $key -eq 81) { exit }
} until ($key -eq 13)

# Game loop
do {
    # Apply data
    $width = [int]$data[0]
    $pos = [int]$data[1]
    $map = [string]$data[2]

    # Draw the map
    DrawMap $render $width $pos $map $terrain

    # Write Message
    if ($null -ne $data[3]) {
        WriteMessage $data[3]
    }

    # Prompt user for next action
    Write-Host "Press w,a,s,d to move or h for help" -ForegroundColor White
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

    # Regenerate map
    if ($key -eq 78) {
        $data = GenerateMap $render $terrain
        $width = $data[0]
        $pos = $data[1]
        $map = $data[2]
    }

    # Help
    if ($key -eq 72) { $data = $width, $pos, $map, 0 }

    # Load save
    if ($key -eq 82) { $map = LoadMap }

    # Save map
    if ($key -eq 69) { SaveMap $width, $pos, $map }

    # Move up
    if ($key -eq 87 -or $key -eq 38) { $data = MoveUp $width $pos $map $terrain }

    # Move down
    if ($key -eq 83 -or $key -eq 40) { $data = MoveDown $width $pos $map $terrain }

    # Move left
    if ($key -eq 65 -or $key -eq 37) { $data = MoveLeft $width $pos $map $terrain }

    # Move right
    if ($key -eq 68 -or $key -eq 39) { $data = MoveRight $width $pos $map $terrain }

    # Quit game
} until ($key -eq 27 -or $key -eq 81)

# Save Game Progress
SaveMap $width, $pos, $map

# Game end message
Write-Host "Thank you for exploring!" -ForegroundColor Green