extends Node
class_name GlobalVariables

# I'm certain there's a better way to do this and global is an ugly singleton. 
# So tell me when you can LOL -Mimi

# akshually... having a single file like this to aggregate some magic numbers
# is a very okay thing for a project of this scale. It has the advantage of
# being the obvious place write down and look up such values.
# I'm even adding more of these! -Tito

#region 😈 Global Mutable State 🙈
# we happen to have none at the moment 👍
#endregion


#region "Game settings"
# Tweak default game settings here 🔽
const DEFAULT_MAX_AMMO: int = 5;
const DEFAULT_TRAP_COOLDOWN: int = 3

# Use these variables in game code
# (like Globals.match_max_ammo, not GlobalVariables.DEFAULT_MAX_AMMO),
# to possibilitate having an in-game "Match Settings" screen in the future
var match_max_ammo := DEFAULT_MAX_AMMO
var match_trap_cooldown := DEFAULT_TRAP_COOLDOWN
#endregion

#region Animation timings
const DEATHRAY_SPEED: int = 140
#endregion

#region Colors
## Title picture's "almost-black" background color
const COLOR_BG: Color = Color(0.082, 0.102, 0.118)

## Title picture's "BAD" red outline color
const COLOR_ACCENT_RED: Color = Color(0.83, 0.1, 0.3)

## Title picture's "ROBOT" blue outline color
const COLOR_ACCENT_BLUE: Color = Color(0.25, 0.47, 0.87)
#endregion
