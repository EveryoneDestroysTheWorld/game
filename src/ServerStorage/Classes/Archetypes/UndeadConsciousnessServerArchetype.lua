--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local UndeadConsciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConsciousnessClientArchetype);
local ServerItem = require(script.Parent.Parent.ServerItem);
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

  local overwrittenProperties = {
    id = UndeadConsciousnessServerArchetype.id;
    name = UndeadConsciousnessServerArchetype.name;
    description = UndeadConsciousnessServerArchetype.description;
    actionIDs = UndeadConsciousnessServerArchetype.actionIDs;
    type = UndeadConsciousnessServerArchetype.type;
    contestant = properties.contestant;
    round = properties.round;
    undeadEffect = ServerEffect.get("Undead").new({
      contestant = properties.contestant;
    });
    events = {};
  };

  local archetype = (setmetatable(overwrittenProperties, UndeadConsciousnessServerArchetype) :: any) :: types.UndeadConsciousnessServerArchetype;

  -- Give the player a random item. 
  local randomItem = ServerItem.random(); -- TODO: Uncomment before merging PR
  randomItem:initialize(archetype.contestant, archetype.round);
  archetype.contestant:addItem(randomItem);

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