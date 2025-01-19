--!strict
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local UndeadConciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConciousnessClientArchetype);
local ServerItem = require(script.Parent.Parent.ServerItem);
local ServerEffect = require(script.Parent.Parent.ServerEffect);
local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);
local types = require(ServerStorage.Classes.types);

local UndeadConciousnessServerArchetype = {
  id = UndeadConciousnessClientArchetype.id;
  name = UndeadConciousnessClientArchetype.name;
  description = UndeadConciousnessClientArchetype.description;
  actionIDs = UndeadConciousnessClientArchetype.actionIDs;
  type = UndeadConciousnessClientArchetype.type;
};

function UndeadConciousnessServerArchetype.new(): types.ServerArchetype

  local contestant: types.ServerContestant;
  local round: types.ServerRound;
  local healthCheckEvent;

  local ragdollClone;
  local undeadEffect: types.ServerEffect;

  local function breakdown(self: types.ServerArchetype)

    if ragdollClone then

      ragdollClone:Destroy();

    end;

    if healthCheckEvent then

      healthCheckEvent:Disconnect();

    end;

    contestant:removeEffect(undeadEffect);

  end;

  local function initialize(self: types.ServerArchetype, newContestant: types.ServerContestant, newRound: types.ServerRound)

    contestant = newContestant;
    round = newRound;

    local isDowned = false;

    undeadEffect = ServerEffect.get("Undead").new({
      contestant = contestant;
    });
    
    local function checkHealth()

      if isDowned and contestant.currentHealth > 0 then
        
        isDowned = false;
        if ragdollClone then

          ragdollClone:Destroy();

        end;

        contestant:removeEffect(undeadEffect);

      elseif not isDowned and contestant.currentHealth <= 0 then

        isDowned = true;

        if contestant.character then

          ragdollClone = createRagdollClone(contestant.character);

        end;

        downContestant(contestant);

        

        contestant:addEffect(undeadEffect);

      end;

    end;

    healthCheckEvent = contestant.onHealthUpdated:Connect(checkHealth);
    checkHealth();

    -- Give the player a random item. 
    local randomItem = ServerItem.random(); -- TODO: Uncomment before merging PR
    randomItem:initialize(contestant, round);
    contestant:addItem(randomItem);

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.id);

    end;

  end;

  return ServerArchetype.new({
    id = UndeadConciousnessServerArchetype.id;
    name = UndeadConciousnessServerArchetype.name;
    description = UndeadConciousnessServerArchetype.description;
    actionIDs = UndeadConciousnessServerArchetype.actionIDs;
    type = UndeadConciousnessServerArchetype.type;
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return UndeadConciousnessServerArchetype;