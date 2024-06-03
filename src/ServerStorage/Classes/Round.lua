--!strict
-- Writer: Christian Toney (Sudobeast)
-- This module represents a Round.
local HttpService = game:GetService("HttpService");
local GameMode = require(script.Parent.GameMode);
local TurfWarGameMode = require(script.Parent.GameModes.TurfWarGameMode);
export type RoundProperties = {  
  -- This round's unique ID.
  ID: string?;

  gameMode: GameMode;
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  timeEnded: number?;

  participants: {Player};

  stats: TurfWarGameMode.TurfWarStats?;
};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
  onHoldRelease: RBXScriptSignal;
}

export type RoundMethods = {
  start: (self: Round, duration: number, stageModel: Model) -> ();
  stop: (self: Round) -> ();
  toString: (self: Round) -> string;
}

local Round = {
  __index = {} :: RoundMethods;
};

export type Round = typeof(setmetatable({}, {__index = Round.__index})) & RoundProperties & RoundEvents & RoundMethods;

local events: {[any]: {[string]: BindableEvent}} = {};

function Round.new(properties: RoundProperties): Round

  local action = properties;

  events[action] = {};
  for _, eventName in ipairs({"onEnded", "onHoldRelease"}) do

    events[action][eventName] = Instance.new("BindableEvent");
    (action :: {})[eventName] = events[action][eventName].Event;

  end

  return setmetatable(action :: {}, {__index = Round.__index}) :: Round;
  
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

  -- Update the time ended stat.
  self.timeEnded = DateTime.now().UnixTimestampMillis;
  
  -- Get the stats from the game mode.


end;

function Round.__index:toString()

  local participantIDs = {};
  for _, participant in ipairs(self.participants) do

    table.insert(participantIDs, participant.UserId);

  end;

  return HttpService:JSONEncode({
    ID = self.ID;
    stageID = self.stageID;
    timeStarted = self.timeStarted;
    timeEnded = self.timeEnded;
    participants = participantIDs;
  });
  
end;

return Round;