--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local UndeadConsciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConsciousnessClientArchetype);
local ServerEffect = require(script.Parent.Parent.ServerEffect);
local types = require(ServerStorage.Modules.types);

local initializeArchetypeActions = require(ServerStorage.Modules.initializeArchetypeActions);

local UndeadConsciousnessServerArchetype = {
  id = UndeadConsciousnessClientArchetype.id;
  name = UndeadConsciousnessClientArchetype.name;
  description = UndeadConsciousnessClientArchetype.description;
  actionIDs = UndeadConsciousnessClientArchetype.actionIDs;
  type = UndeadConsciousnessClientArchetype.type;
  __index = {} :: types.UndeadConsciousnessServerArchetype;
};

function UndeadConsciousnessServerArchetype.new(properties: types.UndeadConsciousnessServerArchetypeConstructorProperties): types.UndeadConsciousnessServerArchetype

  local archetype = (setmetatable({}, UndeadConsciousnessServerArchetype) :: any) :: types.UndeadConsciousnessServerArchetype;
  archetype.id = UndeadConsciousnessServerArchetype.id;
  archetype.name = UndeadConsciousnessServerArchetype.name;
  archetype.description = UndeadConsciousnessServerArchetype.description;
  archetype.actionIDs = UndeadConsciousnessServerArchetype.actionIDs;
  archetype.type = UndeadConsciousnessServerArchetype.type;
  archetype.contestant = properties.contestant;
  archetype.round = properties.round;
  archetype.undeadEffect = ServerEffect.get("Undead").new({
    contestant = properties.contestant;
  });
  archetype.events = {};

  if archetype.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(archetype.contestant.player, archetype.id);

  end;

  archetype.contestant:addEffect(archetype.undeadEffect);

  archetype.actions = initializeArchetypeActions(archetype.actionIDs, archetype.contestant);

  return archetype;

end;

function UndeadConsciousnessServerArchetype.__index:breakdown()

  if self.ragdollClone then

    self.ragdollClone:Destroy();

  end;

  for _, event in self.events do

    event:Disconnect();

  end;

  for _, action in self.actions do

    task.spawn(function()
    
      action:breakdown();

    end);

  end;

  self.contestant:removeEffect(self.undeadEffect);

end;

return UndeadConsciousnessServerArchetype;