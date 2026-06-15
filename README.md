# w2f-permanent id

Every player gets a numeric ID the first time they connect, locked to their identifier and
kept forever. Standalone, but auto-detects QBCore, ESX, and QBox for notifications.

## Install / Uninstall

- Install: drop `permanent-id` into `resources`, add `ensure permanent-id` after `oxmysql`, restart. The table builds itself on first start.
- Uninstall: delete the folder. No migrations, no leftover config, only dependency is oxmysql.

Requires [oxmysql](https://github.com/overextended/oxmysql).

## Structure

```
permanent-id/
├── fxmanifest.lua
├── config/config.lua      everything you'd ever tune
├── shared/functions.lua   FormatId, identifier list
├── server/
│   ├── utils.lua          logging, discord, notify, hooks
│   ├── ids.lua            assign/fetch/reassign + events
│   ├── commands.lua       /myid /findid /setid
│   └── main.lua           table auto-create
├── client/main.lua        statebag reader + notify dispatch
└── sql/permanent_id.sql   manual schema (optional)
```

## Config highlights

- Rename the table and every column.
- Identifier priority list (`license` first, then fallbacks).
- Toggle/rename/re-permission each command.
- Notify backend: `chat`, `ox_lib`, `esx`, `qbcore`, or `custom`.
- ID display formatting (`#0007`).
- Console + Discord webhook logging.
- Server hooks: `onLoad`, `onAssign`, `onReassign`.

## Commands

- `/myid` — your ID.
- `/idview` — toggle the on-screen ID viewer (also bound to **F7** by default; rebind in Settings > Keybinds).
- `/findid <serverId>` — look up a player (ace `command.findid`).
- `/setid <currentId> <newId>` — reassign an ID (ace `command.setid`).

## API

```lua
exports['permanent-id']:GetPermanentId(src)   -- server
Player(src).state.permanentId                 -- server, statebag
exports['permanent-id']:GetMyPermanentId()    -- client
exports['permanent-id']:FormatId(id)          -- both
```
