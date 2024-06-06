--!strict
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local Contestant = require(script.Parent.Parent.Contestant);
type Contestant = Contestant.Contestant;
type ClientArchetype = ClientArchetype.ClientArchetype;
local ExplosiveMimicClientArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  actionIDs = { 2, 3, 4};
  type = "Destroyer" :: "Destroyer";
};
function ExplosiveMimicClientArchetype.new(contestant: Contestant): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = ExplosiveMimicClientArchetype.ID;
    name = ExplosiveMimicClientArchetype.name;
    description = ExplosiveMimicClientArchetype.description;
    actionIDs = ExplosiveMimicClientArchetype.actionIDs;
    type = ExplosiveMimicClientArchetype.type;
    breakdown = breakdown;
  });

end;

return ExplosiveMimicClientArchetype;