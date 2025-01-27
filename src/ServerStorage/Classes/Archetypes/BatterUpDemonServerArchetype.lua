--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local BatterUpDemonClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.BatterUpDemonClientArchetype);

local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);

local types = require(ServerStorage.Classes.types);

local BatterUpDemonServerArchetype = {
  id = BatterUpDemonClientArchetype.id;
  name = BatterUpDemonClientArchetype.name;
  description = BatterUpDemonClientArchetype.description;
  actionIDs = BatterUpDemonClientArchetype.actionIDs;
  type = BatterUpDemonClientArchetype.type;
  __index = {} :: types.BatterUpDemonServerArchetype;
};

function BatterUpDemonServerArchetype.new(properties: types.BatterUpDemonServerArchetypeConstructorProperties): types.BatterUpDemonServerArchetype

  local overwrittenProperties = {
    id = BatterUpDemonServerArchetype.id;
    name = BatterUpDemonServerArchetype.name;
    description = BatterUpDemonServerArchetype.description;
    actionIDs = BatterUpDemonServerArchetype.actionIDs;
    type = BatterUpDemonServerArchetype.type;
    contestant = properties.contestant;
    events = {};
  };

  local archetype = (setmetatable(overwrittenProperties, BatterUpDemonServerArchetype) :: any) :: types.BatterUpDemonServerArchetype;

  if properties.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(archetype.contestant, archetype.id);

  end;

  table.insert(overwrittenProperties.events, archetype.contestant.onHealthUpdated:Connect(function()
  
    if archetype.isContestantDowned and archetype.contestant.currentHealth > 0 then
      
      if archetype.ragdollClone then

        archetype.ragdollClone:Destroy();

      end;

    elseif not archetype.isContestantDowned and archetype.contestant.currentHealth <= 0 then

      archetype.isContestantDowned = true;

      if archetype.contestant.character then

        archetype.ragdollClone = createRagdollClone(archetype.contestant.character);

      end;

      downContestant(archetype.contestant);

    end;

  end));

  return archetype;

end;

function BatterUpDemonServerArchetype.__index:breakdown()

  for _, event in self.events do

    event:Disconnect();

  end;

  if self.ragdollClone then

    self.ragdollClone:Destroy();
    
  end;

end;

return BatterUpDemonServerArchetype;