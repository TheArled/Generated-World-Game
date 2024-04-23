class Game {
  Game() {
    $this.Map = NewMap
  }

  $Map = $null
  [int]$Key = $null
  [int]$Message = $null
  [hashtable]$Keymap = @{
    ENTER = 13
    ESC   = 27
    Q     = 81
    N     = 78
    E     = 69
    R     = 82
    L     = 108
    H     = 72
    UP    = 38
    DOWN  = 40
    LEFT  = 37
    RIGHT = 39
    W     = 87
    S     = 83
    A     = 65
    D     = 68
  }

  [void]Run($h) {
    $this.StartScreen($h)
    $this.GameLoop($h)
    $this.EndScreen($h)
  }

  [void]StartScreen($h) {
    Write-Host "Press Enter to start" -ForegroundColor Green
    do {
      $this.ReadKey($h)
      if ($this.Key -eq $this.Keymap.ESC -or $this.Key -eq $this.Keymap.Q) { exit }
    } until ($this.Key -eq $this.Keymap.Enter)
  }

  [void]GameLoop($h) {
    $End = $false
    do {
      $this.Map.Draw()
      $this.WriteMessage()
      Write-Host 'Press w,a,s,d to move or h for help' -ForegroundColor White
      $this.ReadKey($h)

      switch ($this.Key) {
        $this.Keymap.N { $this.Map.New() }
        $this.Keymap.R { $this.Map.Load() }
        $this.Keymap.L { $this.Map.Load() }
        $this.Keymap.S { $this.Map.Save() }
        $this.Keymap.H { $this.Message = 1 }
        $this.Keymap.UP { $this.Map.MoveUp() }
        $this.Keymap.DOWN { $this.Map.MoveDown() }
        $this.Keymap.LEFT { $this.Map.MoveLeft() }
        $this.Keymap.RIGHT { $this.Map.MoveRight() }
        $this.Keymap.W { $this.Map.MoveUp() }
        $this.Keymap.A { $this.Map.MoveLeft() }
        $this.Keymap.S { $this.Map.MoveDown() }
        $this.Keymap.D { $this.Map.MoveRight() }
        $this.Keymap.ESC { $End = $true }
        $this.Keymap.Q { $End = $true }
      }
    } until ($End)
  }

  [void]EndScreen($h) {
    $this.Map.Save()
    Write-Host "Thank you for exploring!" -ForegroundColor Green
  }

  [void]ReadKey($h) {
    $this.Key = $h.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
  }

  [void]WriteMessage() {
    switch ($this.Message) {
      1 {
        Write-Host 'Move: w, a, s, d' -ForegroundColor Yellow
        Write-Host 'Quit/New: q, n' -ForegroundColor Yellow
        Write-Host 'Save/Load: e, r' -ForegroundColor Yellow
        Write-Host 'Help: h' -ForegroundColor Yellow
      }
      2 { Write-Host 'You ran into a wall; Ouch!' -ForegroundColor Yellow }
    }
    $this.Message = $null
  }
}

Function NewGame() {
  return [Game]::new()
}

Export-ModuleMember -Function NewGame