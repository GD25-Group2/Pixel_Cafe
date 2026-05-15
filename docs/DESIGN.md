# Design Document

## High-level Concept
- Pixel Cafe is a cozy, high-pressure, slice-of-life management simulator. Players operate a bustling roadside cafe in a vibrant pixel-art city, balancing the zen of coffee-making with the frantic demands of hungry commuters. The game focuses on the "flow state" of preparation—dragging ingredients, timing machine cycles, and managing limited counter space—while slowly growing a small business through daily upgrades and equipment unlocks.
Core Mechanics
    - State-Driven Customer Lifecycle: Customers move through a linear path (Arrival → Waiting → Payment → Exit). Their satisfaction is tied to a decaying Patience Bar, which directly impacts the financial reward (tips)
    - Drag-and-Drop Ingredient Assembly: Items aren't just clicked; they are physically moved. Players must drag loaves to plates, slices to sandwich boards, and finished products to customers.
    - Thermal/Processing Timers: Machines (like the Coffee Machine) require a "work duration" during which they are locked, requiring the player to multi-task while the animation plays.
    - Economic Progression: A persistent save system tracks earnings. Players transition from a single coffee stall to a full kitchen by purchasing new machine "unlocks" via the Shop Menu.
    - Daily Cycles: Gameplay is segmented into "Days." Each day ends with a financial summary and a save-point, creating a "one more day" loop.

## Player Capabilities
- The Cursor (Interacting): The player's primary tool. It can "hook" onto items (holding state) and carry them across the screen.
- Inventory Management: The player can hold one item at a time. They must decide whether to deliver it, place it on a preparation surface (BreadPlate), or "void" it if it’s the wrong order.
- Shop Interaction: Between levels, the player acts as a Manager, navigating a scrollable shop to reinvest profits into the cafe.
- Developer Commands: Advanced players (or testers) can manipulate time and space through a terminal-style input box to skip days or inject capital.

## Constraints
- 2D only
- Single-player
- Keyboard and Mouse input

## Inspirations