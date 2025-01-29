--!strict
-- This module represents an Archetype, which contains a list of powers.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local ServerArchetype = {}

function ServerArchetype.get(archetypeID: string): types.ServerArchetypeClass

  local instance = script.Parent.Archetypes:FindFirstChild(`{archetypeID}ServerArchetype`);
  if instance and instance:IsA("ModuleScript") then

    local effect = require(instance) :: any;
    return effect;

  end

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