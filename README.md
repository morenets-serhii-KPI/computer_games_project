# Block Puzzle Game
<img width="1061" height="166" alt="зображення" src="https://github.com/user-attachments/assets/6e1bb4a3-ef5e-404a-b94f-31fa17989bb8" />

## Overview
Block Puzzle Game is a grid-based puzzle game developed using the Godot Engine. The player places randomly generated shapes on an 8×8 board to form complete rows or columns, which are then cleared to earn points. The game continues until no valid moves remain.

This project demonstrates core game development concepts including grid systems, drag-and-drop interaction, procedural content generation, and basic UI management.

---

## Gameplay

### Core Mechanics
- The game is played on an **8×8 grid**.
- The player is given **3 random shapes** at a time.
- Shapes can be **dragged and dropped** onto the board.
- When a **row or column is completely filled**, it is cleared.
- The player earns points for:
  - placing blocks
  - clearing lines
  - achieving combos
- The game ends when **none of the available shapes can be placed**.

  ![Gameplay Demo](Gameplay.gif)

---

### Controls
- **Mouse (Drag & Drop)**:
  - Click and hold a shape to pick it up
  - Drag it over the board
  - Release to place

---

## Features

### Smart Snap System
Shapes automatically snap to the most suitable position on the grid based on:
- proximity to cells
- neighboring blocks
- valid placement

This improves usability and reduces placement errors.

---

### Playable Shape Generation
The game ensures fairness by generating only those sets of shapes that can be placed on the current board.

- Multiple attempts are made to find valid combinations
- Prevents unwinnable situations caused by randomness

---

### Combo System
- Clearing lines consecutively increases a combo multiplier
- Higher combos grant additional score bonuses

---

### Scoring System
- **+10 points per placed block**
- Line clear rewards:
  - 1 line → 100
  - 2 lines → 250
  - 3 lines → 400
  - 4+ lines → 600+
- Combo bonuses applied on consecutive clears

---

### Persistent High Score
- Best score is saved locally
- Automatically loaded on game start
- Storage path: `user://save.dat`

---

## Game Flow

1. Start screen is displayed
2. Player presses **Play**
3. Board is generated
4. Three shapes are spawned
5. Player places shapes:
   - board updates
   - score increases
   - lines may clear
6. When all shapes are used → new shapes appear
7. If no moves are possible → **Game Over**
8. Player can restart via **Replay**

---

## Project Structure
<img width="543" height="1059" alt="зображення" src="https://github.com/user-attachments/assets/c68c199f-33f2-48ec-89bd-802d931dc203" />



---

## Scripts Overview

### [`board.gd`](scripts/board.gd)
Main game controller:
- grid management (8×8 array)
- shape placement validation
- line clearing logic
- scoring system
- combo tracking
- game over detection
- shape generation

---

### [`piece.gd`](scripts/piece.gd)
Handles individual shape behavior:
- drag & drop interaction
- collision detection
- visual feedback
- communication with the board

---

### [`piece_block.gd`](scripts/piece_block.gd)
Represents a single block inside a shape:
- visual representation
- positioning inside shape

---

### [`shapes.gd`](scripts/shapes.gd)
Defines all available shapes:
- static data structure
- includes rotations and variations

---

## Technologies Used
- **Engine:** Godot
- **Language:** GDScript
- **Architecture:** Scene-based (Node system)

---

## How to Run

### Option 1: Run in Godot
1. Open the project in Godot Engine
2. Load the main scene (`Main`)
3. Press **Play**

---

### Option 2: Export (if available)
- Run the exported [`.exe`](Game.exe) file

---

## Design Notes

- The project follows a **centralized architecture**, where `Board` acts as the main controller.
- Game entities (`Piece`) are lightweight and delegate logic to the board.
- Emphasis is placed on:
  - usability (snap system)
  - fairness (shape validation)
  - responsiveness (drag feedback)

---

## Possible Improvements
- Refactor Board into smaller systems (Grid, Score, Effects)
- Replace hardcoded node paths with signals or references
- Add animations polish (particles, transitions)
- Introduce sound effects
- Add difficulty progression

---

## Author
Morenets Serhii, Hryshchukova Dariia

---

## License
This project is created for educational purposes.
