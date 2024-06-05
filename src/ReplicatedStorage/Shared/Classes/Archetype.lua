--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ArchetypeProperties = {
  
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  actionIDs: {number};
  
  initializeEffects: (self: Archetype) -> ();

  breakdownEffects: (self: Archetype) -> ();
  
}

local Archetype = {
  __index = {};
};

export type Archetype = typeof(setmetatable({} :: ArchetypeProperties, Archetype));

function Archetype.new(properties: ArchetypeProperties): Archetype

  return setmetatable(properties, Archetype);
  
end

function Archetype.get(archetypeID: number): Archetype?

  return nil;

end;

return Archetype;