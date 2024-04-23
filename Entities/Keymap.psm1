class Keymap {
  # Keycodes of pressed keys
  static [hashtable]$Keymap = @{
    ENTER = 13
    ESC   = 27
    Q     = 81
    N     = 78
    E     = 69
    R     = 82
    L     = 76
    H     = 72
    UP    = 38
    DOWN  = 40
    LEFT  = 37
    RIGHT = 39
    W     = 87
    S     = 83
    A     = 65
    D     = 68
    HAT   = 220 # Used to get new keycode
  }
}

Function GetKeymap() {
  return [Keymap]::Keymap
}

Export-ModuleMember -Function GetKeymap