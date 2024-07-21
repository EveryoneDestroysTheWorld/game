--!strict
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local DraconicKnightClientArchetype = {
  ID = 3;
  name = "Draconic Knight";
  description = "Fly above the enemy and let the vengence flow";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {};
  type = "Defender" :: "Defender";
};

function DraconicKnightClientArchetype.new(contestant: ClientContestant): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = DraconicKnightClientArchetype.ID;
    iconImage = DraconicKnightClientArchetype.iconImage;
    name = DraconicKnightClientArchetype.name;
    description = DraconicKnightClientArchetype.description;
    actionIDs = DraconicKnightClientArchetype.actionIDs;
    type = DraconicKnightClientArchetype.type;
    breakdown = breakdown;
  });

end;

return DraconicKnightClientArchetype;