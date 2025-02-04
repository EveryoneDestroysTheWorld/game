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
local ServerArchetype = require(script.Parent.ServerArchetype);
local ServerAction = require(script.Parent.ServerAction);
local Stage = require(ServerStorage.Packages.Stage);
local Autopilot = require(ServerStorage.Classes.Autopilot);
local types = require(ServerStorage.Modules.types);

local events: {[any]: {[string]: BindableEvent}} = {};

local ServerRound = {
  __index = {} :: types.ServerRound;
};

function ServerRound.new(properties: types.ServerRoundConstructorProperties): types.ServerRound

  local round = setmetatable(properties :: types.ServerRoundProperties, ServerRound) :: types.ServerRound;
  round.contestants = {};
  round.actions = {};
  round.archetypes = {};
  round.autopilotTasks = {};
  round.stage = properties.stage or Stage.fromID(properties.stageID);

  events[round] = {};
  for _, eventName in ipairs({"onTimeStartedChanged", "onStopped", "onEnded", "onContestantAdded", "onContestantRemoved", "onStatusChanged"}) do

    events[round][eventName] = Instance.new("BindableEvent");
    (round :: {})[eventName] = events[round][eventName].Event;

  end

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

function ServerRound.__index:start(): ()

  assert(not self.timeStarted, "The round has already started.");

  -- Run the game mode.
  self.gameMode = GameMode.get(self.gameModeID).new(self);
  (self.gameMode :: types.GameMode):start();

  -- Ready the archetypes and actions.
  self.archetypes = {};
  self.actions = {};
  for _, contestant in ipairs(self.contestants) do

    local oldArchetype: types.ServerArchetype?;
    local oldActions: {types.ServerAction} = {};

    local function updateArchetype()

      local isSuccess, errorObject = xpcall(function()

        if not oldArchetype or oldArchetype.id ~= contestant.archetypeID then

          if oldArchetype then

            oldArchetype:breakdown();

          end;

          for _, action in oldActions do

            action:breakdown();

          end;

          if contestant.archetypeID then

            local archetype = ServerArchetype.get(contestant.archetypeID).new({
              contestant = contestant;
              round = self;
            });
            table.insert(self.archetypes, archetype);
            oldArchetype = archetype;

            for _, actionID in ipairs(archetype.actionIDs) do

              local action = ServerAction.get(actionID).new({
                contestant = contestant;
              });
              table.insert(self.actions, action);
              table.insert(oldActions, action);

            end;

          end;

        end;

      end, function(errorMessage)
      
        self:stop(true);
        warn(`[Round] Round stopped due to an error: {errorMessage}\n{debug.traceback()}`);

      end);

      if not isSuccess then

        error(errorObject)

      end;

    end;

    contestant.onArchetypeUpdated:Connect(updateArchetype);
    task.spawn(updateArchetype);

    if not contestant.player then

      local function runAutopilot()

        local autopilot = Autopilot.random().new({
          contestant = contestant;
        });

        while task.wait() do

          autopilot:run();

        end;

      end;

      table.insert(self.autopilotTasks, task.spawn(runAutopilot));
      
    end;

  end;

  self.timeStarted = DateTime.now().UnixTimestampMillis;
  events[self].onTimeStartedChanged:Fire();

  if self.duration then

    -- Start a timer.
    local timer = task.delay(self.duration, function()
    
      self:stop();

    end);

    local onEndedEvent;
    onEndedEvent = self.onEnded:Connect(function()
    
      onEndedEvent:Disconnect();
      if coroutine.status(timer) == "running" then

        task.cancel(timer);

      end;

    end);

  end;

  ReplicatedStorage.Shared.Events.RoundStarted:FireAllClients(self.id, self.timeStarted);

end;

function ServerRound.__index:addContestant(contestant: types.ServerContestant): ()

  table.insert(self.contestants, contestant);
  events[self].onContestantAdded:Fire(contestant.id);
  ReplicatedStorage.Shared.Events.ContestantAdded:FireAllClients(self.id, contestant.id);

end;

function ServerRound.__index:getClientConstructorProperties(): any

  -- Convert ServerContestants to ClientContestants.
  local contestants = {};
  for _, contestant in ipairs(self.contestants) do

    table.insert(contestants, contestant:convertToClient());

  end;

  return {
    id = self.id;
    contestants = contestants;
    status = self.status;
    duration = self.duration;
    timeStarted = self.timeStarted;
    stageID = self.stageID;
  };

end;

function ServerRound.__index:setStatus(newStatus: types.RoundStatus): ()

  local oldStatus = self.status;
  self.status = newStatus;
  events[self].onStatusChanged:Fire(newStatus, oldStatus);
  ReplicatedStorage.Shared.Events.RoundStatusChanged:FireAllClients(self.id, newStatus, oldStatus);

end;

function ServerRound.__index:setGameMode(gameMode: types.GameMode): ()

  self.gameMode = gameMode;

end;

function ServerRound.__index:stop(forced: boolean?): ()

  assert(not self.timeEnded, "The round has already ended.");

  -- Break down the game mode.
  if self.gameMode then

    self.gameMode:breakdown();

  end;

  -- Disable the actions.
  if self.archetypes then

    for _, archetype in ipairs(self.archetypes) do

      task.spawn(function() 
        
        archetype:breakdown(); 
      
      end);

    end;

  end;

  if self.actions then

    for _, action in ipairs(self.actions :: {types.ServerAction}) do

      task.spawn(function() 
        
        action:breakdown(); 
      
      end)

    end;

  end;

  -- Save the round info in the database.
  self.timeEnded = DateTime.now().UnixTimestampMillis;

  local contestantIDs = {};
  for _, contestant in ipairs(self.contestants) do

    if contestant.id > 0 then

      table.insert(contestantIDs, contestant.id);

    end;

  end;

  -- DataStoreService:GetDataStore("RoundMetadata"):SetAsync(self.id, self:toString(), contestantIDs);
  events[self][if forced then "onStopped" else "onEnded"]:Fire();
  ReplicatedStorage.Shared.Events[if forced then "RoundStopped" else "RoundEnded"]:FireAllClients(self.id);

end;

function ServerRound.__index:toString()

  local serverContestantStringList = {};
  for _, contestant in ipairs(self.contestants) do

    table.insert(serverContestantStringList, contestant:toString());

  end;

  return HttpService:JSONEncode({
    id = self.id;
    stageID = self.stageID;
    timeStarted = self.timeStarted;
    timeEnded = self.timeEnded;
    contestants = HttpService:JSONEncode(serverContestantStringList);
    gameMode = if self.gameMode then self.gameMode:toString() else nil;
  });
  
end;

return ServerRound;