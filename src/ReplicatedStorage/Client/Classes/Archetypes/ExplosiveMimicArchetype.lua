--!strict
local Archetype = require(script.Parent.Parent.Archetype);
type Archetype = Archetype.Archetype;
local ExplosiveMimicArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "";
  actionIDs = {};
};
function ExplosiveMimicArchetype.new(): Archetype

  local function breakdown(self: Archetype)

  end;

  return Archetype.new({
    ID = ExplosiveMimicArchetype.ID;
    name = ExplosiveMimicArchetype.name;
    description = ExplosiveMimicArchetype.description;
    actionIDs = ExplosiveMimicArchetype.actionIDs;
    type = "Destroyer";
    breakdown = breakdown;
  });

end;

return ExplosiveMimicArchetype;