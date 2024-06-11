--!strict
-- Writer: Christian Toney (Sudobeast)
-- This module represents a Round.
local HttpService = game:GetService("HttpService");
local GameMode = require(script.Parent.GameMode);
type GameMode = GameMode.GameMode;
local DataStoreService = game:GetService("DataStoreService");
local ServerContestant = require(script.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerArchetype = require(script.Parent.ServerArchetype);
type ServerArchetype = ServerArchetype.ServerArchetype;
local ServerAction = require(script.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;

export type RoundProperties = {  
  -- This round's unique ID.
  ID: string?;

  gameMode: GameMode;
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  archetypes: {ServerArchetype}?;

  actions: {ServerAction}?;

  contestants: {ServerContestant};

};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
  onHoldRelease: RBXScriptSignal;
}

export type RoundMethods = {
  start: (self: Round, stageModel: Model) -> ();
  stop: (self: Round) -> ();
  toString: (self: Round) -> string;
}

local Round = {
  __index = {} :: RoundMethods;
};

export type Round = typeof(setmetatable({}, Round)) & RoundProperties & RoundEvents & RoundMethods;

local events: {[any]: {[string]: BindableEvent}} = {};

function Round.new(properties: RoundProperties): Round

  local round = setmetatable(properties, Round) :: Round;

  events[round] = {};
  for _, eventName in ipairs({"onEnded", "onHoldRelease"}) do

    events[round][eventName] = Instance.new("BindableEvent");
    (round :: {})[eventName] = events[round][eventName].Event;

  end

  return round;
  
end

function Round.__index:start(stageModel: Model)

  assert(not self.timeStarted, "The round has already started.");

  -- Run the game mode.
  self.gameMode:start(stageModel);

  -- Ready the archetypes and actions.
  self.archetypes = {};
  self.actions = {};
  for _, contestant in ipairs(self.contestants) do

    task.spawn(function()
    
      local archetype = ServerArchetype.get(contestant.archetypeID, contestant, self, stageModel);

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

function Round.__index:stop()

  assert(not self.timeEnded, "The round has already ended.");

  -- Break down the game mode.
  self.gameMode:breakdown();

  -- Disable the actions.
  for _, archetype in ipairs(self.archetypes :: {ServerArchetype}) do

    task.spawn(function() 
      
      archetype:breakdown(); 
    
    end);

  end;

  for _, action in ipairs(self.actions :: {ServerAction}) do

    task.spawn(function() 
      
      action:breakdown(); 
    
    end)

  end;

  -- Save the round info in the database.
  self.timeEnded = DateTime.now().UnixTimestampMillis;
  self.ID = HttpService:GenerateGUID();

  local contestantIDs = {};
  for _, contestant in ipairs(self.contestants) do

    if contestant.ID > 0 then

      table.insert(contestantIDs, contestant.ID);

    end;

  end;

  DataStoreService:GetDataStore("RoundMetadata"):SetAsync(self.ID, self:toString(), contestantIDs);
  events[self].onEnded:Fire();

end;

function Round.__index:toString()

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
    gameMode = self.gameMode:toString();
  });
  
end;

return Round;