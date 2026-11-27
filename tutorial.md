# Command Guide
## List of commands
- [`auto-start`](tutorial.md#auto-start)
- [`get-random`](tutorial.md#get-random)
- [`get-help`](tutorial.md#get-help)
- [`set-time`](tutorial.md#set-time)
- [`spawn-attack`](tutorial.md#spawn-attack)
- [`start-game`](tutorial.md#start-game)
- [`stop-computer`](tutorial.md#stop-computer)
- [`terminate-player`](tutorial.md#terminate-player)
- [`write-output`](tutorial.md#write-output)

**Note:** commands are case-sensitive, and mustn't have extra spaces

## `auto-start`
### Overview
[`auto-start`](tutorial.md#auto-start) starts the game and makes it so that, whenever you restart the game, the game will automatically start after 3 seconds. Note that you will be unable to type any command unless you hit `space` key while the game is starting. However doing so will stop the game from automatically starting until you enter this command again.
## Syntax
`auto-start`

## `get-random`
### Overview
[`get-random`](tutorial.md#get-random) outputs a random number. If provided with no arguments, it will output an integer x where 0 \< x \< 2147483647.
### Syntax
`get-random [-min minimum] [-max maximum]`
- `minimum`: the lower bound for the number (inclusive)<br>`int`
- `maximum`: the upper bound for the number (exclusive)<br>`int`

## `get-help`
### Overview
[`get-help`](tutorial.md#get-help) outputs a link to this webpage.
### Syntax
`get-help`

## `set-time`
### Overview
[`set-time`](tutorial.md#set-time) sets the amount of time until the win screen appears. If provided with the argument "infinite", the win screen will not appear.
### Syntax
`set-time time`
- `time`: the amount of time until the win screen appears \(in seconds\)<br>`"infinite" || int`

## `spawn-attack`
### Overview
[`spawn-attack`](tutorial.md#spawn-attack) spawns an attack, based on the provided type, and, if the type is `mine`, an amount. It is possible to use [`spawn-attack`](tutorial.md#spawn-attack) to achieve a run of 0 seconds, however it is better to use [`terminate-player`](tutorial.md#terminate-player) to do this.
### Syntax
`spawn-attack -t type [-a amount]`
- `type`: the type of attack to spawn<br>`"double" || "single" || "bounce" || "laser" || "mine"`
- `amount`: amount of mines to spawn \(only valid if `type` is `mine`\)<br>`int`

## `start-game`
### Overview
[`start-game`](tutorial.md#start-game) starts the game. Note that once you start the game, you cannot use the terminal until the game is restarted from the death menu.
### Syntax
`start-game`

## `stop-computer`
### Overview
[`stop-computer`](tutorial.md#stop-computer) terminates the game. Unlike [`terminate-player`](tutorial.md#terminate-player), which opens the endscreen, [`stop-computer`](tutorial.md#stop-computer) closes the window \(on the desktop edition\) or stops the processing of the game \(on the web edition\)
### Syntax
`stop-computer`

## `terminate-player`
### Overview
[`terminate-player`](tutorial.md#terminate-player) terminates the player. Unlike [`stop-computer`](tutorial.md#stop-computer), which terminates the game, [`terminate-player`](tutorial.md#terminate-player) opens the endscreen.
### Syntax
`terminate-player`

## `write-output`
### Overview
[`write-output`](tutorial.md#write-output) outputs some text. The specified text will appear on the next line, and spans only one line.
### Syntax
`write-output text`
- `text`: the text to output<br>`String`

## Troubleshoot
If entering the command yeilds no result, it means that my ~~high-quality~~ *primitive* command processing system didn't identify it as any of the previous commands. Make sure the command is spelt with lowercase charcters and doesn't contain any extra spaces.