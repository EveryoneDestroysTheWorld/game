--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local TeleportService = game:GetService("TeleportService");
local Stage = require(ServerStorage.Classes.Stage);
local Round = require(ServerStorage.Classes.Round);
local TurfWarGameMode = require(ServerStorage.Classes.GameModes.TurfWarGameMode);

-- Get the match info.
local expectedPlayerIDs = {};
local participants: {Player} = {};

local playerCheck = task.delay(10, function()

  -- The round hasn't started, so kick everyone back to the lobby.
  TeleportService:TeleportAsync(15555144468, Players:GetPlayers());

end);

local function startRound()

  -- Disable the player check.
  task.cancel(playerCheck);

  -- Download a random stage from the stage list.
  local stage = Stage.random();
  local stageModel = stage:download();
  stageMoodel.Parent = workspace;

  -- Show the results when the round ends.
  local participantIDs = {};
  for _, participant in ipairs(participants) do

    table.insert(participantIDs, participant.UserId);

  end;

  local round = Round.new({
    stageID = stage.ID :: string;
    gameMode = TurfWarGameMode.new(participantIDs);
    participantIDs = participantIDs;
  });

  round.onEnded:Connect(function()

    ReplicatedStorage.Shared.Events.RoundEnded:FireAllClients(round);

  end);

  -- Start the round.
  round:start(120, stageModel);
  ReplicatedStorage.Shared.Events.RoundStarted:FireAllClients(120);

end;


Players.PlayerAdded:Connect(function(player)

  for _, playerID in ipairs(expectedPlayerIDs) do

    if playerID == player.UserId then

      table.insert(participants, player);

    end;

    -- Check if we should start the round.
    local playerIDFound = false;
    for _, player in ipairs(participants) do

      if playerID == player.UserId then
        
        playerIDFound = true;
        break;

      end;

    end;

    if not playerIDFound then

      return;

    end;

  end;

  startRound();

end);