--!strict
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
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
};

function BatterUpDemonServerArchetype.new(): types.ServerArchetype

  local contestant: types.ServerContestant;
  local round: types.ServerRound;
  local events: {RBXScriptConnection} = {};

  local ragdollClone;
  local function breakdown(self: types.ServerArchetype)

    for _, event in events do

      event:Disconnect();

    end;

    if ragdollClone then

      ragdollClone:Destroy();
      
    end;

  end;

  local function runAutoPilot(self: types.ServerArchetype, actions: {types.ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  local function initialize(self: types.ServerArchetype, newContestant: types.ServerContestant, newRound: types.ServerRound)

    contestant = newContestant;
    round = newRound;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.id);

    end;

    local isDowned = false;
    table.insert(events, contestant.onHealthUpdated:Connect(function()
    
      if isDowned and contestant.currentHealth > 0 then
        
        isDowned = false;
        if ragdollClone then

          ragdollClone:Destroy();

        end;

      elseif not isDowned and contestant.currentHealth <= 0 then

        isDowned = true;

        if contestant.character then

          ragdollClone = createRagdollClone(contestant.character);

        end;

        downContestant(contestant);

      end;

    end));

  end;

  return ServerArchetype.new({
    id = BatterUpDemonServerArchetype.id;
    name = BatterUpDemonServerArchetype.name;
    description = BatterUpDemonServerArchetype.description;
    actionIDs = BatterUpDemonServerArchetype.actionIDs;
    type = BatterUpDemonServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
    initialize = initialize;
  });

end;

return BatterUpDemonServerArchetype;