--!strict
local Archetype = require(script.Parent.Parent.Archetype);
type Archetype = Archetype.Archetype;
local ExplosiveMimicArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "";
};
function ExplosiveMimicArchetype.new(contestant: any): Archetype

  local function initializeEffects(self: Archetype)

  end;

  local function breakdownEffects(self: Archetype)

  end;

  return Archetype.new({
    ID = ExplosiveMimicArchetype.ID;
    name = ExplosiveMimicArchetype.name;
    description = ExplosiveMimicArchetype.description;
    actionIDs = {};
    type = "Destroyer";
    initializeEffects = initializeEffects;
    breakdownEffects = breakdownEffects;
  });

end;

return ExplosiveMimicArchetype;