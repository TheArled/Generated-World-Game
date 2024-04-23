class Map {
  Map() {
    $this.Path = Join-Path $PSScriptRoot 'save'
    $this.RenderWidth = $this.RenderX * 2 + 1
    $this.RenderHeight = $this.RenderY * 2 + 1
    $this.Load()
  }

  [string]$Path = $null
  [string]$Separator = ' '

  [string]$Map = $null
  [int]$Width = $null
  [int]$Height = $null
  [int]$Position = $null
  [int]$RenderWidth = $null
  [int]$RenderHeight = $null

  [int]$RenderX = 5
  [int]$RenderY = 4
  [array]$Terrain = '   ', '[#]', '[o]', '[+]', '[*]', 'Null' # Random number generator never returns last element, so it's unused

  [void]Load() {
    if (Test-Path -Path $this.Path) {
      $Data = (Get-Content -Path $this.Path) -Split $this.Separator
      $this.Width = $Data[0]
      $this.Height = $Data[1]
      $this.Position = $Data[2]
      $this.Map = $Data[3]
    }
    else { $this.New() }
  }
  [void]Save() {
    Set-Content -Path $this.Path -Value ($this.Width, $this.Height, $this.Position, $this.Map -Join $this.Separator) 
  }

  [void]New() {
    $this.Map = ''
    $this.Width = $this.RenderWidth
    $this.Height = $this.RenderHeight
    $this.Position = ($this.Width * $this.Height - 1) / 2
    for ($y = 0; $y -lt $this.Height; $y++) {
      for ($x = 0; $x -lt $this.Width; $x++) {
        if (($x * $y - 1) / 2 -eq $this.Position) { $this.Map += 0 }
        else { $this.Map += $this.NewPatch() }
      }
    }
  }

  [string]NewChunk() {
    $Chunk = ''
    for ($i = 0; $i -lt $this.Width; $i++) {
      $Chunk += $this.NewPatch()
    }
    return $Chunk
  }

  [string]NewPatch() {
    $r = Get-Random -Minimum 0 -Maximum 100
    if ($r -lt 60) { return 0 }
    else { return (Get-Random -Minimum 1 -Maximum ($this.Terrain.Count - 1)) }
  }

  [void]Draw() {
    $this.DetectEdges()

    $RenderRow = $this.Position - $this.RenderX - ($this.Width * $this.RenderY)
    $RenderPosition = $RenderRow
    Clear-Host
    for ($y = 0; $y -lt $this.RenderHeight; $y++) {
      $Line = ''
      for ($x = 0; $x -lt $this.RenderWidth; $x++) {
        if ($RenderPosition -eq $this.Position) { $Line += ' X ' }
        else { $Line += $this.Terrain[[string]$this.Map[$RenderPosition]] }
        $RenderPosition++
      }
      foreach ($Part in $Line -Split '(X)') {
        if ($Part -eq 'X') { Write-Host $Part -ForegroundColor Blue -NoNewline }
        else { Write-Host $Part -ForegroundColor Gray -NoNewline }
      }
      Write-Host ''
      $RenderRow = $RenderRow + $this.Width
      $RenderPosition = $RenderRow
    }
  }

  # Calculate distance to edges relative to player
  [int]GetTopEdge() { return [Math]::Floor($this.Position / $this.Width) }
  [int]GetBottomEdge() { return [Math]::Floor(($this.Width * $this.Height - $this.Position - 1) / $this.Width) }
  [int]GetLeftEdge() { return $this.Position - $this.GetTopEdge() * $this.Width }
  [int]GetRightEdge() { return ($this.GetTopEdge() + 1) * $this.Width - $this.Position - 1 }

  [void]DetectEdges() {
    $this.DetectTopEdge()
    $this.DetectBottomEdge()
    $this.DetectLeftEdge()
    $this.DetectRightEdge()
  }

  [void]DetectTopEdge() {
    if ($this.GetTopEdge() -lt $this.RenderY) {
      $this.Map = $this.NewChunk() + $this.Map
      $this.Height++
      $this.Position += $this.Width
    }
  }
  [void]DetectBottomEdge() {
    if ($this.GetBottomEdge() -lt $this.RenderY) {
      $this.Map = $this.Map + $this.NewChunk()
      $this.Height++
    }
  }
  [void]DetectLeftEdge() {
    if ($this.GetLeftEdge() -lt $this.RenderX) {
      $newMap = ''
      for ($i = 0; $i -lt $this.Height; $i++) {
        $newMap += $this.NewPatch()
        $newMap += $this.Map.Substring($i * $this.Width, $this.Width)
      }
      $this.Width++
      $this.Position = $this.Position + $this.GetTopEdge() + 1
      $this.Map = $newMap
    }
  }
  [void]DetectRightEdge() {
    if ($this.GetRightEdge() -lt $this.RenderX) {
      $newMap = ''
      for ($i = 0; $i -lt $this.Height; $i++) {
        $newMap += $this.Map.Substring($i * $this.Width, $this.Width)
        $newMap += $this.NewPatch()
      }
      $this.Width++
      $this.Position = $this.Position + $this.GetTopEdge()
      $this.Map = $newMap
    }
  }

  [void]MoveUp() { $this.Position -= $this.Width }
  [void]MoveDown() { $this.Position += $this.Width }
  [void]MoveLeft() { $this.Position-- }
  [void]MoveRight() { $this.Position++ }
}

Function NewMap() {
  return [Map]::new()
}

Export-ModuleMember -Function NewMap