--!strict
-- This module represents an Archetype, which contains a list of powers.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local types = require(script.Parent.types);

local ServerArchetype = {}

function ServerArchetype.new(properties: types.ServerArchetypeProperties): types.ServerArchetype

  return properties :: types.ServerArchetype;
  
end

function ServerArchetype.get(archetypeID: string): types.ServerArchetype

  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      if archetype.id == archetypeID then
  
        return archetype.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find archetype from ID {archetypeID}.`);

end;

function ServerArchetype.getAll(): {types.ServerArchetypeClass}

  local archetypes = {};
  
  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      table.insert(archetypes, archetype);
  
    end
  
  end;

  return archetypes;

end;

return ServerArchetype;