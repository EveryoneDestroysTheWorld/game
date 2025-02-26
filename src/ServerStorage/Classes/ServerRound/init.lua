--!strict
-- This module represents a server round.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local HttpService = game:GetService("HttpService");
local MemoryStoreService = game:GetService("MemoryStoreService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local GameMode = require(script.Parent.GameMode);
local Autopilot = require(ServerStorage.Classes.Autopilot);
local types = require(script.types);

local ClientRound = require(ReplicatedStorage.Client.Interfaces.ClientRound);

local ServerRound = {};

function ServerRound.new(properties: types.ServerRoundProperties): types.ServerRound

  local function start(self: types.ServerRound): ()

    assert(not self.timeStarted, "The round has already started.");

    self.timeStarted = DateTime.now().UnixTimestampMillis;

    if self.duration then

      -- Start a timer.
      local timer = task.delay(self.duration, function()
      
        self:stop();

      end);

      local onEndedEvent;
      onEndedEvent = ServerStorage.Events.RoundStatusChanged:Connect(function(roundID: string, newStatus: types.RoundStatus)
      
        if roundID == self.id and (newStatus == "Stopped" or newStatus == "ForceStopped") then

          onEndedEvent:Disconnect();
          if coroutine.status(timer) == "running" then

            task.cancel(timer);

          end;

        end;

      end);

    end;

    ServerStorage.Events.RoundStarted:Fire(self.id, self.timeStarted);
    ReplicatedStorage.Shared.Events.RoundStarted:FireAllClients(self.id, self.timeStarted);

  end;

  local function addContestant(self: types.ServerRound, contestantID: number): ()

    table.insert(self.contestantIDs, contestantID);
    ServerStorage.Events.ContestantAdded:Fire(self.id, contestantID);
    ReplicatedStorage.Shared.Events.ContestantAdded:FireAllClients(self.id, contestantID);

  end;

  local function convertToClientRound(self: types.ServerRound): ClientRound.ClientRound

    return {
      id = self.id;
      contestantIDs = self.contestantIDs;
      gameModeID = self.gameModeID;
      status = self.status;
      duration = self.duration;
      timeStarted = self.timeStarted;
      stageID = self.stageID;
    };

  end;

  local function setStatus(self: types.ServerRound, status: types.RoundStatus)

    local oldStatus = self.status;
    self.status = status;
    ServerStorage.Events.RoundStatusChanged:Fire(self.id, status, oldStatus);
    ReplicatedStorage.Shared.Events.RoundStatusChanged:FireAllClients(self.id, status, oldStatus);

  end;

  local function setGameModeID(self: types.ServerRound, gameModeID: string)

    self.gameModeID = gameModeID;

  end;

  local function stop(self: types.ServerRound, isForced: boolean?): ()

    assert(not self.timeEnded, "The round has already ended.");
  
    -- Break down the game mode.
    self:setStatus(if isForced then "ForceStopped" else "Stopped");
  
    -- Save the round info in the database.
    self.timeEnded = DateTime.now().UnixTimestampMillis;
  
  end

  local round = {
    contestantIDs = properties.contestantIDs;
    gameModeID = properties.gameModeID;
    id = properties.id;
    status = properties.status;
    start = start;
    addContestant = addContestant;
    convertToClientRound = convertToClientRound;
    setStatus = setStatus;
    setGameModeID = setGameModeID;
    stop = stop;
  }

  return round;
  
end;

function ServerRound.fromPrivateServerID(privateServerID: number): types.ServerRound

  -- Verify metadata integrity.
  local roundMetadataEncoded = MemoryStoreService:GetHashMap("PrivateServerRoundMetadata"):GetAsync(privateServerID);
  assert(typeof(roundMetadataEncoded) == "string", "Couldn't find a round metadata.");
  local roundMetadata = HttpService:JSONDecode(roundMetadataEncoded);
  assert(typeof(roundMetadata) == "table", "Round metadata isn't a table.");
  assert(typeof(roundMetadata.id) == "string", "Round ID isn't a string.");
  assert(typeof(roundMetadata.stageID) == "string", "Stage ID isn't a string.");
  assert(typeof(roundMetadata.gameModeID) == "string", "Game mode ID isn't a string.");
  assert(typeof(roundMetadata.contestantIDs) == "table", "Round contestant IDs isn't a table.");
  assert(not roundMetadata.duration or typeof(roundMetadata.duration) == "number", "Round duration must be a number.");

  for index, possibleContestantID in pairs(roundMetadata.contestantIDs) do

    assert(tonumber(index, 10), "Contestant ID list should not have non-integer indexes.");
    assert(typeof(possibleContestantID) == "number", `Contestant at index {index} isn't a number.`);

  end;

  -- Return the new round.
  return ServerRound.new({
    id = roundMetadata.id;
    stageID = roundMetadata.stageID;
    gameModeID = roundMetadata.gameModeID;
    duration = roundMetadata.duration;
    contestantIDs = roundMetadata.contestantIDs;
    status = "Waiting for players" :: types.RoundStatus;
  });

end;

return ServerRound;