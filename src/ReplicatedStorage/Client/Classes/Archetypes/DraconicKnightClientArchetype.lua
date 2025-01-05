--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local DraconicKnightClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Draconic Knight";
  description = "Fly above the enemy and let the vengence flow";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {"DKFlight", "DKDiveBomb", "DKMelee", "DKTarBomb", "DKFireBeam"};
  type = "Defender" :: "Defender";
};

function DraconicKnightClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    id = DraconicKnightClientArchetype.id;
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