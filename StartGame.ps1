Import-Module "$PSScriptRoot\Game.psm1"
Import-Module "$PSScriptRoot\Map.psm1" -Global

$Game = NewGame
$Game.Run($host)