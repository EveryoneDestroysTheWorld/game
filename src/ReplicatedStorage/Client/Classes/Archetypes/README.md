# ClientActions
See [ClientArchetype.lua](../ClientArchetype.lua) for more information on what ClientArchetypes are.

## Template
```luau
--!strict
-- Programmers: [Name of programmer] ([Roblox username of programmer])
-- Designers: [Name of designer] ([Roblox username of designer])
-- © [current year] Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local UnnamedClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Unnamed Archetype";
  description = "This archetype is so good, it doesn't even need a description.";
  actionIDs = {"ActionID1", "ActionID2"};
  iconImage = "rbxassetid://130983727429334";
  type = "Supporter" :: "Supporter"; -- Replace both with "Destroyer", "Fighter", "Defender", or "Supporter".
};

function UnnamedClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = UnnamedClientArchetype.id;
    name = UnnamedClientArchetype.name;
    description = UnnamedClientArchetype.description;
    actionIDs = UnnamedClientArchetype.actionIDs;
    type = UnnamedClientArchetype.type;
    iconImage = UnnamedClientArchetype.iconImage;
    breakdown = function(self: ClientArchetype)

    end;
  };

  return archetype;

end;

return UnnamedClientArchetype;
```
