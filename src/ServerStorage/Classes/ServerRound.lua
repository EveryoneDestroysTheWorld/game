--!strict
-- Writer: Christian Toney (Sudobeast)
-- This module represents a ServerRound.
local HttpService = game:GetService("HttpService");
local GameMode = require(script.Parent.GameMode);
type GameMode = GameMode.GameMode;
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local DataStoreService = game:GetService("DataStoreService");
local ServerContestant = require(script.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerArchetype = require(script.Parent.ServerArchetype);
type ServerArchetype = ServerArchetype.ServerArchetype;
local ServerAction = require(script.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
type RoundStatus = ClientRound.RoundStatus;
local Stage = require(script.Parent.Stage);
type Stage = Stage.Stage;

export type ServerRoundConstructorProperties = {

  -- This round's unique ID.
  ID: string;

  gameModeID: number;
  
  -- This stage's ID.
  stageID: string;

  status: RoundStatus;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  contestantIDs: {number};

}

export type ServerRoundProperties = ServerRoundConstructorProperties & {  

  stage: Stage;

  archetypes: {ServerArchetype};

  actions: {ServerAction};

  contestants: {ServerContestant};

  gameMode: GameMode?;

};

export type ServerRoundEvents = {
  onStopped: RBXScriptSignal;
  onEnded: RBXScriptSignal;
  onHoldRelease: RBXScriptSignal;
  onStatusChanged: RBXScriptSignal;
  onContestantAdded: RBXScriptSignal;
  onContestantRemoved: RBXScriptSignal;
}

export type ServerRoundMethods = {
  addContestant: (self: ServerRound, contestant: ServerContestant) -> ();
  getClientConstructorProperties: (self: ServerRound) -> any;
  setStatus: (self: ServerRound, newStatus: RoundStatus) -> ();
  start: (self: ServerRound, stageModel: Model) -> ();
  stop: (self: ServerRound, forced: boolean?) -> ();
  setGameMode: (self: ServerRound, gameMode: GameMode) -> ();
  toString: (self: ServerRound) -> string;
}

local ServerRound = {
  __index = {} :: ServerRoundMethods;
};

export type ServerRound = typeof(setmetatable({}, ServerRound)) & ServerRoundProperties & ServerRoundEvents & ServerRoundMethods;

local events: {[any]: {[string]: BindableEvent}} = {};

function ServerRound.new(properties: ServerRoundConstructorProperties & {stage: Stage?}): ServerRound

  local round = setmetatable(properties, ServerRound) :: ServerRound;
  round.contestants = {};
  round.actions = {};
  round.archetypes = {};
  round.stage = properties.stage or Stage.fromID(properties.stageID);

  events[round] = {};
  for _, eventName in ipairs({"onStopped", "onEnded", "onHoldRelease", "onContestantAdded", "onContestantRemoved", "onStatusChanged"}) do

    events[round][eventName] = Instance.new("BindableEvent");
    (round :: {})[eventName] = events[round][eventName].Event;

  end

  return round;
  
end;

function ServerRound.fromPrivateServerID(privateServerID: number): ServerRound

  -- Verify metadata integrity.
  local roundMetadataEncoded = DataStoreService:GetDataStore("PrivateServerRoundMetadata"):GetAsync(privateServerID);
  assert(typeof(roundMetadataEncoded) == "string", "Couldn't find a round metadata.");
  local roundMetadata = HttpService:JSONDecode(roundMetadataEncoded);
  assert(typeof(roundMetadata) == "table", "Round metadata isn't a table.");
  assert(typeof(roundMetadata.ID) == "string", "Round ID isn't a string.");
  assert(typeof(roundMetadata.stageID) == "string", "Stage ID isn't a string.");
  assert(typeof(roundMetadata.gameModeID) == "number", "Game mode ID isn't a number.");
  assert(typeof(roundMetadata.contestantIDs) == "table", "Round contestant IDs isn't a table.");

  for index, possibleContestantID in pairs(roundMetadata.contestantIDs) do

    assert(tonumber(index, 10), "Contestant ID list should not have non-integer indexes.");
    assert(typeof(possibleContestantID) == "number", `Contestant at index {index} isn't a number.`);

  end;

  -- Return the new round.
  return ServerRound.new({
    ID = roundMetadata.ID;
    stageID = roundMetadata.stageID;
    gameModeID = roundMetadata.gameModeID;
    contestantIDs = roundMetadata.contestantIDs;
    status = "Waiting for players" :: RoundStatus;
  });

end;

function ServerRound.__index:start(): ()

  assert(not self.timeStarted, "The round has already started.");

  -- Run the game mode.
  self.gameMode = GameMode.get(self.gameModeID).new(self);
  (self.gameMode :: GameMode):start();

  -- Ready the archetypes and actions.
  self.archetypes = {};
  self.actions = {};
  for _, contestant in ipairs(self.contestants) do

    task.spawn(function()

      if contestant.archetypeID then

        local archetype = ServerArchetype.get(contestant.archetypeID).new(contestant, self, self.stage.model);

        local actions = {};
        for _, actionID in ipairs(archetype.actionIDs) do

          local action = ServerAction.get(actionID, contestant, self);
          table.insert(self.actions :: {ServerAction}, action);
          actions[actionID] = action;

        end;

        table.insert(self.archetypes :: {ServerArchetype}, archetype);
        
        if contestant.ID < 1 then
            
          archetype:runAutoPilot(actions);

        end;

      else

        contestant:disqualify();
        warn(`Disqualified {contestant.name} ({contestant.ID}) because they don't have an archetype.`);

      end;

    end);

  end;

  self.timeStarted = DateTime.now().UnixTimestampMillis;

  -- Start a timer.
  local timer = task.delay(self.duration, function()
  
    self:stop();

  end);

  local onEndedEvent;
  onEndedEvent = self.onEnded:Connect(function()
  
    onEndedEvent:Disconnect();
    task.cancel(timer);

  end);

end;

-- Add a contestant to the round.
function ServerRound.__index:addContestant(contestant: ServerContestant): ()

  table.insert(self.contestants, contestant);
  events[self].onContestantAdded:Fire(contestant);
  ReplicatedStorage.Shared.Events.ContestantAdded:FireAllClients(self.ID, contestant:convertToClient());

end;

function ServerRound.__index:getClientConstructorProperties(): any

  -- Convert ServerContestants to ClientContestants.
  local contestants = {};
  for _, contestant in ipairs(self.contestants) do

    table.insert(contestants, contestant:convertToClient());

  end;

  return {
    ID = self.ID;
    contestants = contestants;
    status = self.status;
    duration = self.duration;
    timeStarted = self.timeStarted;
    stageID = self.stageID;
  };

end;

function ServerRound.__index:setStatus(newStatus: RoundStatus): ()

  local oldStatus = self.status;
  self.status = newStatus;
  events[self].onStatusChanged:Fire(newStatus, oldStatus);
  ReplicatedStorage.Shared.Events.RoundStatusChanged:FireAllClients(self.ID, newStatus, oldStatus);

end;

function ServerRound.__index:setGameMode(gameMode: GameMode): ()

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

    for _, action in ipairs(self.actions :: {ServerAction}) do

      task.spawn(function() 
        
        action:breakdown(); 
      
      end)

    end;

  end;

  -- Save the round info in the database.
  self.timeEnded = DateTime.now().UnixTimestampMillis;

  local contestantIDs = {};
  for _, contestant in ipairs(self.contestants) do

    if contestant.ID > 0 then

      table.insert(contestantIDs, contestant.ID);

    end;

  end;

  -- DataStoreService:GetDataStore("RoundMetadata"):SetAsync(self.ID, self:toString(), contestantIDs);
  events[self][if forced then "onStopped" else "onEnded"]:Fire();
  ReplicatedStorage.Shared.Events[if forced then "RoundStopped" else "RoundEnded"]:FireAllClients(self.ID);

end;

function ServerRound.__index:toString()

  local serverContestantStringList = {};
  for _, contestant in ipairs(self.contestants) do

    table.insert(serverContestantStringList, contestant:toString());

  end;

  return HttpService:JSONEncode({
    ID = self.ID;
    stageID = self.stageID;
    timeStarted = self.timeStarted;
    timeEnded = self.timeEnded;
    contestants = HttpService:JSONEncode(serverContestantStringList);
    gameMode = if self.gameMode then self.gameMode:toString() else nil;
  });
  
end;

return ServerRound;