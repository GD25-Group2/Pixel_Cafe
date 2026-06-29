# ☕ Pixel Cafe

## 📖 About the Project
Pixel Cafe is a cozy, high-pressure, slice-of-life management simulator. Players operate a bustling roadside cafe in a vibrant pixel-art city, balancing the zen of coffee-making with the frantic demands of hungry commuters. The game focuses on the "flow state" of preparation—dragging ingredients, timing machine cycles, and managing limited counter space—while slowly growing a small business through daily upgrades and equipment unlocks.

---

## ✨ Core Mechanics

*   **State-Driven Customer Lifecycle:** Customers move through a linear path from Arrival to Waiting, Payment, and Exit. Their satisfaction is tied to a decaying Patience Bar, which directly impacts the financial reward (tips).
*   **Drag-and-Drop Assembly:** Items aren't just clicked; they are physically moved. Players must drag loaves to plates, slices to sandwich boards, and finished products to customers.
*   **Thermal/Processing Timers:** Machines (like the Coffee Machine) require a "work duration" during which they are locked, requiring the player to multi-task while the animation plays.
*   **Economic Progression:** A persistent save system tracks earnings. Players transition from a single coffee stall to a full kitchen by purchasing new machine unlocks via the Shop Menu.
*   **Daily Cycles:** Gameplay is segmented into "Days". Each day ends with a financial summary and a save-point, creating a "one more day" loop.

---

## 🛠️ Tech Stack

| Component | Technology / Detail |
| :--- | :--- |
| **Language** | Lua |
| **Engine** | LÖVE2D |
| **Libraries** | SUIT, Class, Push, StateMachine, StateStack, dkjson, Animation, Util |
| **Constraints** | 2D only, Single-player, Keyboard/Mouse input |
| **Non-Goals**| Multiplayer, Server Authority |

---

## 🎮 Controls & Player Capabilities

The game utilizes a hybrid input model handled primarily through `main.lua` and `BaseState.lua`:

### Mouse (Primary)
*   **Interaction:** The Cursor is the player's primary tool to "hook" onto items and carry them across the screen. Players can hold one item at a time, deciding whether to deliver it, place it on a preparation surface, or "void" it if it’s the wrong order.
*   **Tracking:** Global `mouseX` and `mouseY` variables are updated every frame via `push:toReal`.
*   **Scrolling:** `gWheelY` tracks vertical scroll offsets for list navigation in menus and shops.

### Keyboard (Secondary/Utility)
*   **Pause:** Press `p` or `ESC` to trigger the Pause Menu.
*   **Developer Terminal:** Press `k` to open the InputBox for string-based command parsing. Advanced players can manipulate time and space (e.g., `\dev skip` to skip days, `\dev money <number>` to add money).
*   **Shortcuts:** Press `d` to instantly skip a day during the prototype phase.

---

## 📂 Project Structure

The project is structured into modular components and states:

*   **`src/`**: Core utilities including `DataManager.lua`, `StockManager.lua`, `Signal.lua`, and animation configs.
*   **`src/libs/`**: External and structural libraries like SUIT, push, and StateStack.
*   **`src/states/game/`**: High-level game loops (`PlayState.lua`, `DayEndState.lua`, `ShopMenu.lua`, etc.).
*   **`src/states/entity/`**: Interactive game objects like `CoffeeMachine.lua`, `CustomerManager.lua`, and `ReputationBar.lua`.
*   **`src/states/GUI/`**: Interface rendering scripts like `PauseMenuCard.lua` and various background handlers.