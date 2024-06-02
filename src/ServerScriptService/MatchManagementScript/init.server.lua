local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local TeleportService = game:GetService("TeleportService");
local Round = require(ServerStorage.Classes.Round);

-- Get the match info.
local expectedPlayerIDs = {};
local participants = {};

local playerCheck = task.delay(10, function()

  -- The round hasn't started, so kick everyone back to the lobby.
  TeleportService:TeleportAsync(15555144468, participants);

end);

local function startRound()

  -- Disable the player check.
  task.cancel(playerCheck);

  -- Download a random stage from the stage list.
  local stage = Stage.random();

  -- Start the round.
  local round = Round.new({
    ID = "Test";
    stage = stage.ID;
    gameMode = "Turf War";
    participants = participants;
  });

  round.onEnded:Connect(function()

    -- Show the results.
    ReplicatedStorage.Shared.Events.RoundEnded:FireAllClients(round);

  end);

  round:start(120);

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