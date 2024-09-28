--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local DraconicKnightClientArchetype = {
  ID = 3;
  name = "Draconic Knight";
  description = "Fly above the enemy and let the vengence flow";
  iconImage = "rbxassetid://18584519829";

  actionIDs = {6, 7, 8, 9, 10};

  type = "Defender" :: "Defender";
};

function DraconicKnightClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = DraconicKnightClientArchetype.ID;
    iconImage = DraconicKnightClientArchetype.iconImage;
    name = DraconicKnightClientArchetype.name;
    description = DraconicKnightClientArchetype.description;
    actionIDs = DraconicKnightClientArchetype.actionIDs;
    type = DraconicKnightClientArchetype.type;
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return DraconicKnightClientArchetype;