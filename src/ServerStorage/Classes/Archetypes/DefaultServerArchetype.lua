--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local DefaultClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.DefaultClientArchetype);
local types = require(ServerStorage.Modules.types);

local DefaultServerArchetype = {
  id = DefaultClientArchetype.id;
  name = DefaultClientArchetype.name;
  description = DefaultClientArchetype.description;
  actionIDs = DefaultClientArchetype.actionIDs;
  type = DefaultClientArchetype.type;
  __index = {} :: types.DefaultServerArchetype;
};

function DefaultServerArchetype.new(properties: types.UndeadConsciousnessServerArchetypeConstructorProperties): types.DefaultServerArchetype

  local archetype = (setmetatable({}, DefaultServerArchetype) :: any) :: types.DefaultServerArchetype;
  archetype.id = DefaultClientArchetype.id;
  archetype.name = DefaultClientArchetype.name;
  archetype.description = DefaultClientArchetype.description;
  archetype.actionIDs = DefaultClientArchetype.actionIDs;
  archetype.type = DefaultClientArchetype.type;
  archetype.events = {};
  archetype.contestant = properties.contestant;
  archetype.actions = {};

  if properties.contestant.player then

    task.spawn(function()
      
      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(archetype.contestant.player, archetype.id);
    
    end);

  end;

  return archetype;

end;

function DefaultServerArchetype.__index:breakdown()

  if self.ragdollClone then

    self.ragdollClone:Destroy();

  end;

  for _, event in self.events do

    event:Disconnect();

  end;

end;

return DefaultServerArchetype;