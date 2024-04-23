Join-Path $PSScriptRoot 'Entities\Game.psm1' | Import-Module
Join-Path $PSScriptRoot 'Entities\Map.psm1' | Import-Module -Global

$Game = NewGame
$Game.Run($host)