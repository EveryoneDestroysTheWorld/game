--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;
local UndeadConciousnessClientArchetype = {
  ID = 4;
  name = "Undead Conciousness";
  description = "You can be unfortunate enough that no one would save you while downed, but with undead yourself, you can hunt down your enemies for vengeance!";
  actionIDs = {};
  type = "Supporter" :: "Supporter";
};
function UndeadConciousnessClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = UndeadConciousnessClientArchetype.ID;
    name = UndeadConciousnessClientArchetype.name;
    description = UndeadConciousnessClientArchetype.description;
    actionIDs = UndeadConciousnessClientArchetype.actionIDs;
    type = UndeadConciousnessClientArchetype.type;
    iconImage = "rbxassetid://130983727429334";
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return UndeadConciousnessClientArchetype;