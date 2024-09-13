--!strict
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local BatterUpDemonClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.BatterUpDemonClientArchetype);
local ServerRound = require(script.Parent.Parent.ServerRound);
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerRound = ServerRound.ServerRound;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;
local downContestant = require(ServerStorage.Modules.downContestant);
local createRagdollClone = require(ServerStorage.Modules.createRagdollClone);

local BatterUpDemonServerArchetype = {
  ID = BatterUpDemonClientArchetype.ID;
  name = BatterUpDemonClientArchetype.name;
  description = BatterUpDemonClientArchetype.description;
  actionIDs = BatterUpDemonClientArchetype.actionIDs;
  type = BatterUpDemonClientArchetype.type;
};

function BatterUpDemonServerArchetype.new(): ServerArchetype

  local contestant: ServerContestant;
  local round: ServerRound;
  local events: {RBXScriptConnection} = {};

  local function breakdown(self: ServerArchetype)

    for _, event in events do

      event:Disconnect();

    end;

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  local function initialize(self: ServerArchetype, newContestant: ServerContestant, newRound: ServerRound)

    contestant = newContestant;
    round = newRound;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.ID);

    end;

    local isDowned = false;
    table.insert(events, contestant.onHealthUpdated:Connect(function()
    
      if isDowned and contestant.currentHealth > 0 then
        
        isDowned = false;

      elseif not isDowned and contestant.currentHealth <= 0 then

        isDowned = true;
        downContestant(contestant);

        if contestant.character then

          createRagdollClone(contestant.character);

        end;

      end;

    end));

  end;

  return ServerArchetype.new({
    ID = BatterUpDemonServerArchetype.ID;
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