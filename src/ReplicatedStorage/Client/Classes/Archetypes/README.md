# Client archetypes
Client archetypes are meant to let the server know when the player does something that the server wouldn't know by itself. For example, when the player presses a key on their keyboard or moves their mouse. Client archetypes are typically not designed to handle actions because all archetypes must be compatible with bot players. Bots cannot access client archetypes.

## Creating an archetype
Raise an issue in the design repository before creating an official archetype.

## Implementing an archetype
### Metadata
Archetypes only require names, IDs, and types. Descriptions and action IDs are optional. The client manages this information, while the server pulls it from ReplicatedStorage.

Archetypes require unique IDs to help the server identify archetypes with duplicate or modified names. IDs also help reduce the size of match records. Players can see these IDs in developer mode.

### Functions
> [!IMPORTANT]
> For security, the client can only modify what the player sees; but, it's important to remember that client perspectives can be misleading. Consider the server the sole arbiter of truth and never trust the client, especially with sensitive information.

The `new` constructor typically runs when the player is about to participate in a round. `contestant.player` should be equivalant to the local player.

The `breakdown` function in the constructor is for disconnecting events. It is separated for readability, so do not simplify it.

### Archetype template
```lua
--!strict
-- This is an archetype designed for the DemoDemons game.
-- Programmers: [Who programmed this? Example: Christian Toney <christiantoney.com>]
-- Designer: [Who designed this? Example: InkyTheBlue <bio.link/inkytheblue>]
-- © 2024 Beastslash
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local Contestant = require(script.Parent.Parent.Contestant);
type Contestant = Contestant.Contestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local Archetype = {
  ID = 1; -- Replace with an unused ID.
  name = "Archetype Name"; -- The player will see this.
  description = ""; -- The player will see this in the shop and when they open their inventory.
  actionIDs = {1, 2, 3, 4}; -- These actions will automatically be loaded when this archetype is loaded. 
  type = ""; 
};

function Archetype.new(contestant: Contestant): ClientArchetype

  -- Runs when the round ends.
  local function breakdown(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = Archetype.ID;
    name = Archetype.name;
    description = Archetype.description;
    actionIDs = Archetype.actionIDs;
    type = Archetype.type;
    breakdown = breakdown;
  });

end;

return Archetype;
```
