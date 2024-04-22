$map = ""
$square = 5
$plots = $square * $square
$pos = ($plots - 1) / 2
$lands = "[ ]", "[#]", "[o]", "[+]", "[*]", "Null"

Read-Host "Press Enter to start"

for ($i = 0; $i -lt $plots; $i++) {
    $randomNumber = Get-Random -Minimum 0 -Maximum 100
    if ($randomNumber -lt 60) {
        $map += 0
    }
    else {
        $map += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
    }
}

for (; ; ) {
    Clear-Host

    for ($i = 0; $i -lt $plots; ) {
        if ($i -eq $pos) {
            Write-Host " X " -NoNewline
        }
        else {
            Write-Host $lands[[string]$map[$i]] -NoNewline
        }
        
        if (++$i % $square -eq 0) {
            Write-Host ""
        }
    }

    Write-Host ""
    $move = Read-Host "Move (w, a, s, d, q, r)"
    
    if ($move -eq "q") { break }

    if ($move -eq "r") {
        $map = ""
        for ($i = 0; $i -lt $plots; $i++) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 100
            if ($randomNumber -lt 60) {
                $map += 0
            }
            else {
                $map += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
            }
        }
    }

    if ($move -eq "w") {
        if ($map[$pos - $square] -ne "0") {
            continue
        }

        $chunk = ''
        for ($i = 0; $i -lt $square; $i++) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 100
            if ($randomNumber -lt 60) {
                $chunk += 0
            }
            else {
                $chunk += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
            }
        }
        $map = $chunk + $map.Substring(0, $plots - $square)
    }

    if ($move -eq "s") {
        if ($map[$pos + $square] -ne "0") {
            continue
        }

        $chunk = ''
        for ($i = 0; $i -lt $square; $i++) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 100
            if ($randomNumber -lt 60) {
                $chunk += 0
            }
            else {
                $chunk += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
            }
        }
        $map = $map.Substring($square, $plots - $square) + $chunk
    }

    if ($move -eq "a") {
        if ($map[$pos - 1] -ne "0") {
            continue
        }

        $newMap = ''
        for ($i = 0; $i -lt $square; $i++) {
            $randomNumber = Get-Random -Minimum 0 -Maximum 100
            if ($randomNumber -lt 60) {
                $newMap += 0
            }
            else {
                $newMap += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
            }
            $newMap += $map.Substring($i * $square, $square - 1)
        }
        $map = $newMap
    }

    if ($move -eq "d") {
        if ($map[$pos + 1] -ne "0") {
            continue
        }

        $newMap = ''
        for ($i = 0; $i -lt $square; $i++) {
            $newMap += $map.Substring($i * $square + 1, $square - 1)
            $randomNumber = Get-Random -Minimum 0 -Maximum 100
            if ($randomNumber -lt 70) {
                $newMap += 0
            }
            else {
                $newMap += (Get-Random -Minimum 1 -Maximum ($lands.Count - 1))
            }
        }

        $map = $newMap
    }
}

Write-Host "Thanks for exploring!"