--!strict
-- This module represents a server round.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local HttpService = game:GetService("HttpService");
local MemoryStoreService = game:GetService("MemoryStoreService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ServerContestant = require(ServerStorage.Classes.ServerContestant);
local IClientRound = require(ReplicatedStorage.Client.Interfaces.IClientRound);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

type ClientRound = IClientRound.ClientRound;
type ServerRound = IServerRound.ServerRound;
type RoundStatus = IServerRound.RoundStatus;
type ServerContestant = IServerContestant.ServerContestant;

local ServerRound = {};

function ServerRound.new(properties: IServerRound.ServerRoundProperties): ServerRound

  local contestants: {ServerContestant} = {};

  local function addContestant(self: ServerRound, contestantID: number): ()

    table.insert(self.contestantIDs, contestantID);

    local contestant = ServerContestant.new({
      id = contestantID;
    });

    table.insert(contestants, contestant);

    ServerStorage.Events.ContestantAdded:Fire(self.id, contestantID);
    ReplicatedStorage.Shared.Events.ContestantAdded:FireAllClients(self.id, contestantID);

  end;

  local function convertToClientRound(self: ServerRound): ClientRound

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

  local function setStatus(self: ServerRound, status: RoundStatus)

    if status == "Active" then

      if not self.timeStarted then

        self.timeStarted = DateTime.now().UnixTimestampMillis;

        if self.duration then

          -- Start a timer.
          local timer = task.delay(self.duration, function()
          
            self:setStatus("Stopped");

          end);

          local onEndedEvent;
          onEndedEvent = ServerStorage.Events.RoundStatusChanged:Connect(function(roundID: string, newStatus: IServerRound.RoundStatus)
          
            if roundID == self.id and (newStatus == "Stopped" or newStatus == "Stopped by administrator") then

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

    elseif status == "Stopped by administrator" or status == "Stopped" then

      if not self.timeEnded then

        self.timeEnded = DateTime.now().UnixTimestampMillis;

      end;

    end;

    local oldStatus = self.status;
    self.status = status;
    ServerStorage.Events.RoundStatusChanged:Fire(self.id, status, oldStatus);
    ReplicatedStorage.Shared.Events.RoundStatusChanged:FireAllClients(self.id, status, oldStatus);

  end;

  local function setGameModeID(self: ServerRound, gameModeID: string)

    self.gameModeID = gameModeID;

  end;

  local function getContestants(self: ServerRound): {ServerContestant}

    return contestants;

  end;

  local round = {
    contestantIDs = properties.contestantIDs;
    gameModeID = properties.gameModeID;
    id = properties.id;
    status = properties.status;
    addContestant = addContestant;
    getContestants = getContestants;
    convertToClientRound = convertToClientRound;
    setStatus = setStatus;
    setGameModeID = setGameModeID;
  }

  for _, contestantID in properties.contestantIDs do

    round:addContestant(contestantID);

  end;

  return round;
  
end;

function ServerRound.fromPrivateServerID(privateServerID: number): ServerRound

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
    status = "Waiting for players" :: IServerRound.RoundStatus;
  });

end;

return ServerRound;