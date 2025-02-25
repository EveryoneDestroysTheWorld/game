--!strict
-- Written by Christian Toney (Christian_Toney)
-- This module represents an Archetype, which contains a list of powers.

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local BatterUpDemonClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.BatterUpDemonClientArchetype);
local DefaultClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DefaultClientArchetype);
local DraconicKnightClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DraconicKnightClientArchetype);
local ExplosiveMimicClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.ExplosiveMimicClientArchetype);
local UndeadConsciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConsciousnessClientArchetype);
local ClientArchetypeFactoryTypes = require(script.types);

local ClientArchetypeFactory = {}

function ClientArchetypeFactory.get(archetypeID: string): ClientArchetypeFactoryTypes.ClientArchetypeClass

  local archetypes = {
    BatterUpDemon = BatterUpDemonClientArchetype;
    Default = DefaultClientArchetype;
    DraconicKnight = DraconicKnightClientArchetype;
    ExplosiveMimic = ExplosiveMimicClientArchetype;
    UndeadConsciousness = UndeadConsciousnessClientArchetype;
  };

  local action = archetypes[archetypeID];
  
  if not action then

    error(`{archetypeID} client archetype couldn't be found.`);

  end;

  return action;

end;

return ClientArchetypeFactory;