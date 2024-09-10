--!strict
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;
local ExplosiveMimicClientArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  iconImage = "rbxassetid://18463752295";
  actionIDs = {1, 2, 3, 4};
  type = "Destroyer" :: "Destroyer";
};
function ExplosiveMimicClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;
  
  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = ExplosiveMimicClientArchetype.ID;
    iconImage = ExplosiveMimicClientArchetype.iconImage;
    name = ExplosiveMimicClientArchetype.name;
    description = ExplosiveMimicClientArchetype.description;
    actionIDs = ExplosiveMimicClientArchetype.actionIDs;
    type = ExplosiveMimicClientArchetype.type;
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return ExplosiveMimicClientArchetype;