--!strict
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local BatterUpDemonClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.BatterUpDemonClientArchetype);
local ServerRound = require(script.Parent.Parent.ServerRound);
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerRound = ServerRound.ServerRound;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;

local BatterUpDemonServerArchetype = {
  ID = BatterUpDemonClientArchetype.ID;
  name = BatterUpDemonClientArchetype.name;
  description = BatterUpDemonClientArchetype.description;
  actionIDs = BatterUpDemonClientArchetype.actionIDs;
  type = BatterUpDemonClientArchetype.type;
};

function BatterUpDemonServerArchetype.new(contestant: ServerContestant, round: ServerRound, stageModel: Model): ServerArchetype

  local function breakdown(self: ServerArchetype)

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  return ServerArchetype.new({
    ID = BatterUpDemonServerArchetype.ID;
    name = BatterUpDemonServerArchetype.name;
    description = BatterUpDemonServerArchetype.description;
    actionIDs = BatterUpDemonServerArchetype.actionIDs;
    type = BatterUpDemonServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
  });

end;

return BatterUpDemonServerArchetype;