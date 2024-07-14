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

export type ServerRoundProperties = {  
  -- This round's unique ID.
  ID: string;

  gameMode: GameMode?;
  
  -- This stage's ID.
  stageID: string;

  status: RoundStatus;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  archetypes: {ServerArchetype}?;

  actions: {ServerAction}?;

  contestants: {ServerContestant};

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

function ServerRound.new(properties: ServerRoundProperties): ServerRound

  local round = setmetatable(properties, ServerRound) :: ServerRound;

  events[round] = {};
  for _, eventName in ipairs({"onStopped", "onEnded", "onHoldRelease", "onContestantAdded", "onContestantRemoved", "onStatusChanged"}) do

    events[round][eventName] = Instance.new("BindableEvent");
    (round :: {})[eventName] = events[round][eventName].Event;

  end

  return round;
  
end;

function ServerRound.__index:start(stageModel: Model): ()

  assert(not self.timeStarted, "The round has already started.");
  assert(self.gameMode, "This round has no game mode.");

  -- Run the game mode.
  self.gameMode:start(stageModel);

  -- Ready the archetypes and actions.
  self.archetypes = {};
  self.actions = {};
  for _, contestant in ipairs(self.contestants) do

    task.spawn(function()

      if contestant.archetypeID then

        local archetype = ServerArchetype.get(contestant.archetypeID).new(contestant, self, stageModel);

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