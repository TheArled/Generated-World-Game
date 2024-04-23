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
  [array]$Frame = @()

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
        else { $this.Map += $this._NewPatch() }
      }
    }
  }

  [string]_NewChunk() {
    $Chunk = ''
    for ($i = 0; $i -lt $this.Width; $i++) {
      $Chunk += $this._NewPatch()
    }
    return $Chunk
  }

  [string]_NewPatch() {
    $r = Get-Random -Minimum 0 -Maximum 100
    if ($r -lt 60) { return 0 }
    else { return (Get-Random -Minimum 1 -Maximum ($this.Terrain.Count - 1)) }
  }

  [void]Draw() {
    $this._RenderFrame()
    $this._DrawFrame()
  }

  [void]_RenderFrame() {
    $RenderRow = $this.Position - $this.RenderX - ($this.Width * $this.RenderY)
    $RenderPosition = $RenderRow
    $this.Frame = @()
    for ($y = 0; $y -lt $this.RenderHeight; $y++) {
      $this.Frame += ''
      for ($x = 0; $x -lt $this.RenderWidth; $x++) {
        if ($RenderPosition -eq $this.Position) { $this.Frame[$y] += ' X ' }
        else { $this.Frame[$y] += $this.Terrain[[string]$this.Map[$RenderPosition]] }
        $RenderPosition++
      }
      $RenderRow = $RenderRow + $this.Width
      $RenderPosition = $RenderRow
    }
  }

  [void]_DrawFrame() {
    Clear-Host
    foreach ($Line in $this.Frame) {
      foreach ($Part in $Line -Split '(X)') {
        if ($Part -eq 'X') { Write-Host $Part -ForegroundColor Blue -NoNewline }
        else { Write-Host $Part -ForegroundColor Gray -NoNewline }
      }
      Write-Host ''
    }
  }

  [int]MoveUp() {
    if ($this.Map[$this.Position - $this.Width] -ne [string]0) { return 2 }
    $this.Position -= $this.Width
    $this._DetectTopEdge()
    return 0
  }
  [int]MoveDown() {
    if ($this.Map[$this.Position + $this.Width] -ne [string]0) { return 2 }
    $this.Position += $this.Width
    $this._DetectBottomEdge()
    return 0
  }
  [int]MoveLeft() {
    if ($this.Map[$this.Position - 1] -ne [string]0) { return 2 }
    $this.Position--
    $this._DetectLeftEdge()
    return 0
  }
  [int]MoveRight() {
    if ($this.Map[$this.Position + 1] -ne [string]0) { return 2 }
    $this.Position++
    $this._DetectRightEdge()
    return 0
  }
  
  # Calculate distance to edges relative to player
  [int]_GetTopEdge() { return [Math]::Floor($this.Position / $this.Width) }
  [int]_GetBottomEdge() { return [Math]::Floor(($this.Width * $this.Height - $this.Position - 1) / $this.Width) }
  [int]_GetLeftEdge() { return $this.Position - $this._GetTopEdge() * $this.Width }
  [int]_GetRightEdge() { return ($this._GetTopEdge() + 1) * $this.Width - $this.Position - 1 }

  [void]_DetectTopEdge() {
    if ($this._GetTopEdge() -lt $this.RenderY) {
      $this.Map = $this._NewChunk() + $this.Map
      $this.Height++
      $this.Position += $this.Width
    }
  }
  [void]_DetectBottomEdge() {
    if ($this._GetBottomEdge() -lt $this.RenderY) {
      $this.Map = $this.Map + $this._NewChunk()
      $this.Height++
    }
  }
  [void]_DetectLeftEdge() {
    if ($this._GetLeftEdge() -lt $this.RenderX) {
      $newMap = ''
      for ($i = 0; $i -lt $this.Height; $i++) {
        $newMap += $this._NewPatch()
        $newMap += $this.Map.Substring($i * $this.Width, $this.Width)
      }
      $this.Width++
      $this.Position = $this.Position + $this._GetTopEdge() + 1
      $this.Map = $newMap
    }
  }
  [void]_DetectRightEdge() {
    if ($this._GetRightEdge() -lt $this.RenderX) {
      $newMap = ''
      for ($i = 0; $i -lt $this.Height; $i++) {
        $newMap += $this.Map.Substring($i * $this.Width, $this.Width)
        $newMap += $this._NewPatch()
      }
      $this.Width++
      $this.Position = $this.Position + $this._GetTopEdge()
      $this.Map = $newMap
    }
  }
}

Function NewMap() {
  return [Map]::new()
}

Export-ModuleMember -Function NewMap