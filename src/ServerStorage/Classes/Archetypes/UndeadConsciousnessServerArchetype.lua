--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local UndeadConsciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConsciousnessClientArchetype);
local ServerEffect = require(script.Parent.Parent.ServerEffect);
local types = require(ServerStorage.Modules.types);

local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);
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

  local isDowned = false;
  local function checkHealth()

    if isDowned and archetype.contestant.currentHealth > 0 then
      
      isDowned = false;
      if archetype.ragdollClone then

        archetype.ragdollClone:Destroy();

      end;

      archetype.contestant:removeEffect(archetype.undeadEffect);

    elseif not isDowned and archetype.contestant.currentHealth <= 0 then

      isDowned = true;

      if archetype.contestant.character then

        archetype.ragdollClone = createRagdollClone(archetype.contestant.character);

      end;

      downContestant(archetype.contestant);

      archetype.contestant:addEffect(archetype.undeadEffect);

    end;

  end;

  table.insert(archetype.events, archetype.contestant.onHealthUpdated:Connect(checkHealth));
  checkHealth();
  
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