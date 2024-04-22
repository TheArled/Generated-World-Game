class Game {
  Game() {
    $this.Map = NewMap
  }

  $Map = $null
  [int]$Key = $null
  [int]$Message = $null

  [void]Run($h) {
    # Prompt user to start
    Write-Host "Press Enter to start" -ForegroundColor Green
    do {
      $this.ReadKey($h)
      if ($this.Key -eq [Keymap]::ESC -or $this.Key -eq [Keymap]::Q) { exit }
    } until ($this.Key -eq [Keymap]::Enter)

    # Game Loop
    do {
      $this.Map.Draw()
      $this.WriteMessage()
      Write-Host 'Press w,a,s,d to move or h for help' -ForegroundColor White
      $this.ReadKey($h)

      if ($this.Key -eq [Keymap]::N) { $this.Map.Generate() }
      if ($this.Key -eq [Keymap]::R) { $this.Map.Load() }
      if ($this.Key -eq [Keymap]::S) { $this.Map.Save() }
      if ($this.Key -eq [Keymap]::H) { $this.Message = 1 }

    } until ($this.Key -eq [Keymap]::ESC -or $this.Key -eq [Keymap]::Q)

    $this.Map.Save()

    # Game end message
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

enum Keymap {
  ENTER = 13
  ESC = 27
  Q = 81
  N = 78
  E = 69
  R = 82
  H = 72
  UP = 38
  DOWN = 40
  LEFT = 37
  RIGHT = 39
  W = 87
  S = 83
  A = 65
  D = 68
}

Function NewGame() {
  return [Game]::new()
}

Export-ModuleMember -Function NewGame