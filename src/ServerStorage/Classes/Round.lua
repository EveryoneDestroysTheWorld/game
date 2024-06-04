--!strict
-- Writer: Christian Toney (Sudobeast)
-- This module represents a Round.
local HttpService = game:GetService("HttpService");
local GameMode = require(script.Parent.GameMode);
local DataStoreService = game:GetService("DataStoreService");
export type RoundProperties = {  
  -- This round's unique ID.
  ID: string?;

  gameMode: GameMode.GameMode<any, any>;
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  timeEnded: number?;

  participantIDs: {number};

  stats: {any}?;
};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
  onHoldRelease: RBXScriptSignal;
}

export type RoundMethods = {
  start: (self: Round, duration: number, stageModel: Model) -> ();
  stop: (self: Round) -> ();
  toString: (self: Round) -> string;
  getParticipantIDs: (self: Round) -> {number};
}

local Round = {
  __index = {} :: RoundMethods;
};

export type Round = typeof(setmetatable({}, {__index = Round.__index})) & RoundProperties & RoundEvents & RoundMethods;

local events: {[any]: {[string]: BindableEvent}} = {};

function Round.new(properties: RoundProperties): Round

  local round = setmetatable(properties :: {}, {__index = Round.__index}) :: Round;

  events[round] = {};
  for _, eventName in ipairs({"onEnded", "onHoldRelease"}) do

    events[round][eventName] = Instance.new("BindableEvent");
    (round :: {})[eventName] = events[round][eventName].Event;

  end

  return round;
  
end

function Round.__index:start(duration: number, stageModel: Model)

  assert(not self.timeStarted, "The round has already started.");

  self.timeStarted = DateTime.now().UnixTimestampMillis;

  -- Run the game mode.
  task.spawn(function()
  
    self.gameMode:start(stageModel);

  end);

  -- Start a timer.
  local timer = task.delay(duration, function()
  
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

  -- Save the round info in the database.
  self.timeEnded = DateTime.now().UnixTimestampMillis;
  self.ID = HttpService:GenerateGUID();
  DataStoreService:GetDataStore("RoundMetadata"):SetAsync(self.ID, self:toString(), self.participantIDs);
  events[self].onEnded:Fire();

end;

function Round.__index:toString()

  return HttpService:JSONEncode({
    ID = self.ID;
    stageID = self.stageID;
    timeStarted = self.timeStarted;
    timeEnded = self.timeEnded;
    participantIDs = self.participantIDs;
    gameMode = self.gameMode:toString();
  });
  
end;

return Round;