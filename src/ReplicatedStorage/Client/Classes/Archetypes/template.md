```lua
--!strict
-- Programmers: [Name of programmer] ([Roblox username of programmer])
-- Designers: [Name of designer] ([Roblox username of designer])
-- © [current year] Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local ExtendedClientArchetype = {
  ID = 0; -- Replace this. Very important.
  name = "Extended";
  description = "This is an example archetype.";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {6}; -- Replace with action IDs.
  type = "Defender" :: "Defender"; -- Replace both with "Destroyer", "Fighter", "Defender", or "Supporter".
};

function ExtendedClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = ExtendedClientArchetype.ID;
    iconImage = ExtendedClientArchetype.iconImage;
    name = ExtendedClientArchetype.name;
    description = ExtendedClientArchetype.description;
    actionIDs = ExtendedClientArchetype.actionIDs;
    type = ExtendedClientArchetype.type;
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return ExtendedClientArchetype;
```
