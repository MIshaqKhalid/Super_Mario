<div align="center">
### 🍄 SUPER MARIO

### COAL Semester Project · 8086 Assembly · DOSBox

**A classic platform-game experience, built from the ground up in 16-bit
NASM assembly.**
</div>
<p align="center">
  <img src="https://img.shields.io/badge/Architecture-Intel%208086-2563EB?style=for-the-badge" alt="Intel 8086">
  <img src="https://img.shields.io/badge/Language-NASM%20Assembly-7C3AED?style=for-the-badge" alt="NASM Assembly">
  <img src="https://img.shields.io/badge/Platform-DOS%20Real%20Mode-16A34A?style=for-the-badge" alt="DOS Real Mode">
  <img src="https://img.shields.io/badge/Runtime-DOSBox-F59E0B?style=for-the-badge" alt="DOSBox">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Graphics-VGA%20Mode%2013h-E11D48?style=flat-square" alt="VGA Mode 13h">
  <img src="https://img.shields.io/badge/Executable-.COM-0F766E?style=flat-square" alt="COM executable">
  <img src="https://img.shields.io/badge/Assembler-DOS%20NASM%200.98.38-334155?style=flat-square" alt="DOS NASM 0.98.38">
</p>

------------------------------------------------------------------------

**Jump in. Collect coins. Dodge enemies. Reach the flagpole!**
:::

## 🎮 About the Game

A **Super Mario-style 2D platformer** developed for the **Computer
Organization and Assembly Language (COAL)** semester project.

Built with **16-bit NASM assembly**, original **Intel 8086-compatible
instructions**, and **DOS real-mode programming**, the game compiles
into a single `.COM` executable and runs inside DOSBox.

The project brings together low-level concepts such as segmented memory,
interrupts, hardware ports, fixed-point arithmetic, graphics rendering,
and state-based program flow---all in a playable platform game.

## 👥 Team

  Team member                  Roll number
  --------------------------- -------------
  **Muhammad Taha**            `25F-0755`
  **Muhammad Ishaq Khalid**    `25F-0653`
  **Asad Ali**                 `25F-0698`

![Section](https://img.shields.io/badge/Section-BCS--3B-2563EB?style=flat-square)
![Course](https://img.shields.io/badge/Course-COAL-7C3AED?style=flat-square)

The same team details are available through **Credits** on the main
menu.

## ✨ Features

  -----------------------------------------------------------------------
  Category                            Highlights
  ----------------------------------- -----------------------------------
  🕹️ **Main menu**                    Start Game, Credits, and Exit

  🌍 **World**                        Scrolling tile-based level with
                                      platforms, pipes, stairs, and a
                                      flagpole

  🏃 **Movement**                     Walking, running, variable-height
                                      jumps, gravity, and collision
                                      detection

  🍄 **Power-ups**                    Small and Super Mario forms,
                                      mushroom power-ups, and damage
                                      protection

  👾 **Enemies**                      Goombas, Koopas, stomping, and
                                      shell interactions

  🪙 **Collectibles**                 Coins, question blocks, scoring,
                                      lives, and countdown timer

  🎨 **Animation**                    Eight-frame running animation with
                                      rounded foot motion and separated
                                      legs

  🌤️ **Scenery**                      Clouds, bushes, and a castle;
                                      background mountains are currently
                                      disabled

  🏁 **Level finish**                 Flag and cloth slide down together,
                                      followed by a victory walk and
                                      time-bonus scoring

  🔁 **Game flow**                    Pause/resume, death and life
                                      transitions, game-over, and
                                      level-complete screens

  🔊 **Audio**                        PC-speaker background music and
                                      sound effects, with separate music
                                      and master-sound controls
  -----------------------------------------------------------------------

## 🧰 Technology Stack

  ----------------------------------------------------------------------------------------------------------------------
  Technology                                                                         Purpose
  ---------------------------------------------------------------------------------- -----------------------------------
  ![NASM](https://img.shields.io/badge/NASM-Assembly-7C3AED?style=flat-square)       Game logic and low-level routines

  ![Intel](https://img.shields.io/badge/Intel-8086-2563EB?style=flat-square)         Target instruction set

  ![DOS](https://img.shields.io/badge/DOS-Real%20Mode-16A34A?style=flat-square)      Execution environment

  ![DOSBox](https://img.shields.io/badge/DOSBox-Emulator-F59E0B?style=flat-square)   Running and testing the game

  ![VGA](https://img.shields.io/badge/VGA-Mode%2013h-E11D48?style=flat-square)       320 × 200, 256-colour graphics
  ----------------------------------------------------------------------------------------------------------------------

## 💻 Requirements

-   **DOSBox** or a compatible DOS environment.
-   **NASM for DOS**, targeting DOS NASM **0.98.38** compatibility.
-   All **16 `.asm` modules** kept together in one folder.

The game embeds its artwork, font, level, music, and sound-effect tables
in assembly. No external image or audio assets, linker, or additional
libraries are required.

> **Already have `mario.com`?** You can run it directly in DOSBox. NASM
> is only required when rebuilding from source.

## 🚀 Build & Run

### 1. Open DOSBox and mount the project folder

Replace the example path with the actual folder containing the project
files.

``` dos
mount c "/path/to/project"
c:
```

### 2. Compile the game

Make sure DOS NASM is available in the mounted folder or through the DOS
`PATH`.

``` dos
nasm main.asm -o mario.com
```

### 3. Run it

``` dos
mario.com
```

### Run the included executable

If you only want to play the included compiled version, mount the folder
and run:

``` dos
mario.com
```

**Important:** Keep all source modules in the same directory when
rebuilding. The project uses relative `%include` paths.

## 🎹 Controls

### Main menu and gameplay

  -----------------------------------------------------------------------
  Key                                 Action
  ----------------------------------- -----------------------------------
  `↑` / `↓`                           Change the selected main-menu
                                      button

  `Enter`                             Activate the selected button

  `Enter` / `Esc` on Credits          Return to the main menu

  `←` / `→`                           Move Mario

  `Left Shift` + `←` / `→`            Run

  `Space`                             Jump; release early for a shorter
                                      jump

  `P`                                 Pause or resume gameplay

  `B`                                 Enable or disable background music

  `M`                                 Enable or disable all game sound

  `Esc` during play or pause          Return to the main menu

  `Esc` on the main menu              Exit to DOS

  `Enter` on game-over or             Return to the main menu
  level-complete screen               
  -----------------------------------------------------------------------

Select **Start Game** from the main menu to begin a fresh game.

### 🧪 Demonstration shortcuts

These shortcuts are available during gameplay and can help demonstrate
features during the project presentation or viva.

  Key    Action
  ------ -----------------------------------------------------------
  `F1`   Set the remaining time to five seconds
  `F2`   Set the coin counter to 99
  `F3`   Apply the mushroom power-up effect and award 1,000 points
  `F4`   Move Mario to the staircase near the flagpole
  `F5`   Set one remaining life and trigger the death sequence

## 🗂️ Source Code Structure

The project uses a **flat, single-folder structure**. `main.asm` is the
entry point, while `engine.asm` includes the remaining modules into one
executable.

  -----------------------------------------------------------------------
  File                                Responsibility
  ----------------------------------- -----------------------------------
  `main.asm`                          Program entry, stack setup, main
                                      loop, and exit path

  `engine.asm`                        Includes the shared assembly
                                      modules

  `constant.asm`                      Game constants, state IDs, key
                                      codes, colours, and record offsets

  `data.asm`                          Shared variables, state-handler
                                      table, level map, spawn data, and
                                      text

  `platform.asm`                      DOS memory management, VGA setup,
                                      keyboard/timer interrupts, frame
                                      waiting, and cleanup

  `audio.asm`                         PC-speaker playback, music
                                      sequencing, sound priorities, and
                                      mute controls

  `sounds.asm`                        Embedded music and sound-effect
                                      note tables

  `world.asm`                         Tile queries, level reset, camera
                                      tracking, and overlap helpers

  `physics.asm`                       Player movement, fixed-point
                                      integration, jumping, gravity, and
                                      tile collisions

  `entities.asm`                      Enemy and item updates, stomps,
                                      shells, and mushroom spawning

  `rules.asm`                         Coins, blocks, scoring, health,
                                      lives, countdown, and win/death
                                      triggers

  `states.asm`                        Menu, Credits, gameplay, pause,
                                      death, life, win, and game-over
                                      behaviour

  `art.asm`                           Colour palette,
                                      character/enemy/item sprites, and
                                      running-animation frames

  `font.asm`                          Embedded bitmap font

  `graphics.asm`                      Frame-buffer operations, clipped
                                      drawing, sprites, text, and numbers

  `screens.asm`                       Menu, Credits, world, scenery, HUD,
                                      character animation, and
                                      result-screen composition
  -----------------------------------------------------------------------

## ⚙️ How It Works

The main loop follows this sequence:

``` text
        ┌──────────────────────┐
        │   Wait for game tick │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │   Read keyboard input│
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Dispatch game state  │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Update game and audio│
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Render frame buffer  │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Present frame to VGA │
        └──────────┬───────────┘
                   │
                   └──────────────→ Repeat
```

Gameplay updates occur in the **playing** state. When paused, the
simulation and countdown are frozen.

### 🖥️ Graphics and display

-   Uses **VGA Mode 13h**: 320 × 200 pixels with 256 colours.
-   Uses a custom **32-colour palette**.
-   Draws each frame in an off-screen buffer before copying it to video
    memory at segment `A000h`.

### 🧮 Movement and timing

-   Player movement uses integer arithmetic with **eight fractional
    bits** (8.8 fixed-point representation).
-   Timer and keyboard interrupt handlers provide frame timing and
    input.
-   Collision detection handles interaction with the tile-based world
    and entities.

### 🔔 Sound

-   Uses **PIT channel 2** and the PC speaker.
-   Background music is a **single-voice arrangement**.
-   Sound effects temporarily take priority over the melody.
-   Music and master-sound controls can be toggled independently.

## 🎓 Educational Objectives

This project demonstrates practical use of:

-   8086 registers and instruction set.
-   Segmented memory and real-mode addressing.
-   Stack-based procedure calls and parameter handling.
-   Hardware interrupts and interrupt handlers.
-   Hardware I/O ports and the programmable interval timer.
-   Fixed-point arithmetic and collision detection.
-   VGA graphics and frame-buffer rendering.
-   State-based program flow and modular assembly programming.

## ⚠️ Disclaimer

Super Mario is a property of **Nintendo**. This is an educational fan
project developed for academic purposes and is **not affiliated with,
endorsed by, or associated with Nintendo**.

------------------------------------------------------------------------

### 🍄 Thanks for checking out our project!

**Built with 8086 Assembly · Powered by curiosity · Played in DOSBox**
<div align="center">
<sub>COAL Semester Project · BCS-3B</sub>
</div>
