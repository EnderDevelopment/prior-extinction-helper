# Roblox Script: Prior Extinction Helper

Prior Extinction Helper is a server-authoritative Roblox script for your own Roblox Studio experience. It provides a fossil collection system with ProximityPrompts, teleport commands, leaderboard tracking, server-side distance validation, and DataStore persistence.

## Install

1. Open your Roblox experience in Roblox Studio.
2. Create a `Script` inside `ServerScriptService`.
3. Copy the contents of `ServerScriptService/FossilSystem.server.lua` into the new script.
4. In `Workspace`, create a folder named `Fossils`.
5. Add each collectible fossil as a `BasePart` or mesh part inside `Workspace/Fossils`.
6. Alternatively, tag collectible `BasePart` objects with the `Fossil` tag using `CollectionService`.
7. Publish the experience before testing DataStore saving.
8. For Studio DataStore testing, enable `Game Settings > Security > Enable Studio Access to API Services`.

## Use

1. Place visible collectible parts in the `Workspace/Fossils` folder.
2. Start the game. The script automatically adds a `CollectFossilPrompt` to each fossil.
3. Use the prompt near a fossil to collect it.
4. Type `!fossil` in chat to teleport to the nearest available fossil.
5. Type `!collectfossil` in chat to collect a nearby fossil without using the prompt.
6. View the saved collection total in the player's `Fossils` leaderboard value.
7. Adjust the constants at the top of the script to change the chat commands, collection distance, teleport cooldown, teleport offset, or DataStore name.

The collection distance is checked on the server. Collected fossils are hidden for the current server session, while the player's fossil count is saved using DataStore.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/2e5dda6c-1204-4923-b0f0-e41cc0888daa?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=2e5dda6c-1204-4923-b0f0-e41cc0888daa
