class Game {
  Game() {
    $this.Map = NewMap
    $this.Keymap = GetKeymap
  }

  $Map = $null
  [int]$Key = $null
  [int]$Message = $null
  [hashtable]$Keymap = $null

  [void]Run($h) {
    $this._StartScreen($h)
    $this._GameLoop($h)
    $this._EndScreen($h)
  }

  [void]_StartScreen($h) {
    $Start = $False
    Write-Host "Press Enter to start" -ForegroundColor Green
    do {
      $this._ReadKey($h)

      switch ($this.Key) {
        $this.Keymap.HAT {
          Write-Host 'Press any key:'
          $this._ReadKey($h)
          Write-Host ('Keycode: ' + $this.Key) -ForegroundColor Yellow
        }
        $this.Keymap.ESC { exit }
        $this.Keymap.Q { exit }
        $this.Keymap.ENTER { $Start = $True }
      }
    } until ($Start)
  }

  [void]_GameLoop($h) {
    $End = $False
    do {
      $this.Map.Draw()
      $this._WriteMessage()
      Start-Sleep -Milliseconds 1 # Prevents player to pass through walls when moving too fast
      Write-Host 'Press w,a,s,d to move or h for help' -ForegroundColor White
      $this._ReadKey($h)

      switch ($this.Key) {
        $this.Keymap.N { $this.Map.New() }
        $this.Keymap.R { $this.Map.Load() }
        $this.Keymap.L { $this.Map.Load() }
        $this.Keymap.S { $this.Map.Save() }
        $this.Keymap.H { $this.Message = 1 }
        $this.Keymap.UP { $this.Message = $this.Map.MoveUp() }
        $this.Keymap.DOWN { $this.Message = $this.Map.MoveDown() }
        $this.Keymap.LEFT { $this.Message = $this.Map.MoveLeft() }
        $this.Keymap.RIGHT { $this.Message = $this.Map.MoveRight() }
        $this.Keymap.W { $this.Message = $this.Map.MoveUp() }
        $this.Keymap.A { $this.Message = $this.Map.MoveLeft() }
        $this.Keymap.S { $this.Message = $this.Map.MoveDown() }
        $this.Keymap.D { $this.Message = $this.Map.MoveRight() }
        $this.Keymap.ESC { $End = $True }
        $this.Keymap.Q { $End = $True }
      }
    } until ($End)
  }

  [void]_EndScreen($h) {
    $this.Map.Save()
    Write-Host "Thank you for exploring!" -ForegroundColor Green
  }

  [void]_ReadKey($h) {
    $this.Key = $null
    $this.Key = $h.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
  }

  [void]_WriteMessage() {
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