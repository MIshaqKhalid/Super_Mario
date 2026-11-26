# Super Mario — COAL Semester Project

A Super Mario-style platform game developed for the **Computer Organization
and Assembly Language (COAL)** semester project. The game uses 16-bit NASM
assembly, original Intel 8086-compatible instructions, and DOS real mode.
It builds into a single DOS `.COM` executable and runs inside DOSBox.

## Team credits

| Team member | Roll number |
| --- | --- |
| Muhammad Taha | 25F-0755 |
| Muhammad Ishaq Khalid | 25F-0653 |
| Asad Ali | 25F-0698 |

**Section:** BCS-3B  
**Course:** Computer Organization and Assembly Language (COAL)

The same team details are available through **Credits** on the main menu.

## Features

- Three-option main menu: **Start Game**, **Credits**, and **Exit**.
- A scrolling, tile-based level with platforms, pipes, stairs, and a flagpole.
- Walking, running, variable-height jumps, gravity, and collision detection.
- Small and Super Mario forms, mushroom power-ups, and damage protection.
- Goomba and Koopa enemies, stomping, and shell interactions.
- Collectible coins, question blocks, scoring, lives, and a countdown timer.
- An eight-frame running animation with rounded foot motion and separated legs.
- Simple pixel graphics with clouds, bushes, and a castle; background mountains
  are currently disabled.
- A flagpole finish in which Mario and the flag cloth slide down together,
  followed by a victory walk and time-bonus scoring.
- Pause/resume, death and life transitions, game-over, and level-complete screens.
- PC-speaker background music and sound effects, with separate music and
  master-sound controls.

## Requirements

- DOSBox or a compatible DOS environment.
- NASM for DOS; the source targets DOS NASM **0.98.38** compatibility.
- All 16 `.asm` modules kept together in one folder.

The game embeds its artwork, font, level, music, and sound-effect tables in
assembly. No external image or audio assets, linker, or additional libraries
are required. NASM is needed when rebuilding; an existing `main.com` can be
run directly in DOSBox.

## Build and run

Open DOSBox and mount the folder containing the project. Replace the example
path below with the actual project folder on your computer:

```dos
mount c "/path/to/project"
c:
```

With DOS NASM available in that folder or on the DOS path, compile and run:

```dos
nasm main.asm -o main.com
main.com
```

To play the included compiled version, simply run `main.com` after mounting
the folder. Keep the source files in the same directory when rebuilding,
because the modules use relative `%include` paths.

## Controls

| Key | Action |
| --- | --- |
| Up / Down | Change the selected main-menu button |
| Enter | Activate the selected button |
| Enter / Esc on Credits | Return to the main menu |
| Left / Right | Move Mario |
| Left Shift + Left / Right | Run |
| Space | Jump; release early for a shorter jump |
| P | Pause or resume gameplay |
| B | Enable or disable background music |
| M | Enable or disable all game sound |
| Esc during play or pause | Return to the main menu |
| Esc on the main menu | Exit to DOS |
| Enter on game-over or level-complete screen | Return to the main menu |

Select **Start Game** from the main menu to begin a fresh game.

### Demonstration shortcuts

These shortcuts are active during gameplay and can help demonstrate features
during the project presentation or viva.

| Key | Action |
| --- | --- |
| F1 | Set the remaining time to five seconds |
| F2 | Set the coin counter to 99 |
| F3 | Apply the mushroom power-up effect and award 1,000 points |
| F4 | Move Mario to the staircase near the flagpole |
| F5 | Set one remaining life and trigger the death sequence |

## Source files

The project has a flat, single-folder structure. `main.asm` is the entry point;
`engine.asm` includes the remaining modules into one executable.

| File | Responsibility |
| --- | --- |
| `main.asm` | Program entry, stack setup, main loop, and exit path |
| `engine.asm` | Includes the shared assembly modules |
| `constant.asm` | Game constants, state IDs, key codes, colours, and record offsets |
| `data.asm` | Shared variables, state-handler table, level map, spawn data, and text |
| `platform.asm` | DOS memory management, VGA setup, keyboard/timer interrupts, frame waiting, and cleanup |
| `audio.asm` | PC-speaker playback, music sequencing, sound priorities, and mute controls |
| `sounds.asm` | Embedded music and sound-effect note tables |
| `world.asm` | Tile queries, level reset, camera tracking, and overlap helpers |
| `physics.asm` | Player movement, fixed-point integration, jumping, gravity, and tile collisions |
| `entities.asm` | Enemy and item updates, stomps, shells, and mushroom spawning |
| `rules.asm` | Coins, blocks, scoring, health, lives, countdown, and win/death triggers |
| `states.asm` | Menu, Credits, gameplay, pause, death, life, win, and game-over behaviour |
| `art.asm` | Colour palette, character/enemy/item sprites, and running-animation frames |
| `font.asm` | Embedded bitmap font |
| `graphics.asm` | Frame-buffer operations, clipped drawing, sprites, text, and numbers |
| `screens.asm` | Menu, Credits, world, scenery, HUD, character animation, and result-screen composition |

## Implementation overview

The main loop waits for a game tick, reads keyboard input, dispatches the
current game-state handler, updates audio, renders the frame, and presents it
to the screen. Gameplay updates occur in the playing state; pause freezes
the simulation and countdown.

Graphics use **VGA Mode 13h (320 × 200, 256-colour mode)** with a custom
32-colour palette. Drawing happens in an off-screen buffer before the frame
is copied to video memory at segment `A000h`.

Movement uses integer arithmetic with eight fractional bits. Timer and keyboard
interrupt handlers provide frame timing and input. Sound uses PIT channel 2
and the PC speaker; music is a single-voice arrangement, and sound effects
temporarily take priority over the melody.

## Educational purpose

The project demonstrates 8086 registers and instructions, segmented memory,
stack-based procedure calls, interrupts, hardware ports, fixed-point arithmetic,
state-based program flow, and modular assembly programming.

Super Mario is a Nintendo property. This is an educational fan project and
is not affiliated with or endorsed by Nintendo.
