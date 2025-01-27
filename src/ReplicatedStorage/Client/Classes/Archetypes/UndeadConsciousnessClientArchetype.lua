--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;
local UndeadConsciousnessClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Undead Consciousness";
  description = "You can be unfortunate enough that no one would save you while downed, but with undead yourself, you can hunt down your enemies for vengeance!";
  actionIDs = {};
  type = "Supporter" :: "Supporter";
};
function UndeadConsciousnessClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    id = UndeadConsciousnessClientArchetype.id;
    name = UndeadConsciousnessClientArchetype.name;
    description = UndeadConsciousnessClientArchetype.description;
    actionIDs = UndeadConsciousnessClientArchetype.actionIDs;
    type = UndeadConsciousnessClientArchetype.type;
    iconImage = "rbxassetid://130983727429334";
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return UndeadConsciousnessClientArchetype;