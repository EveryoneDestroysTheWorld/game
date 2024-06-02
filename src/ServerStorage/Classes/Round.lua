--!strict
-- Writer: Christian Toney (Sudobeast)
-- This module represents a Round.
local HttpService = game:GetService("HttpService");
export type RoundProperties = {  
  -- This round's unique ID.
  ID: string?;

  gameMode: "Turf War";
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  timeEnded: number?;

  participants: {Player};
};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
  onHoldRelease: RBXScriptSignal;
}

export type RoundMethods = {
  start: (self: Round, duration: number) -> ();
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

function Round.__index:start(duration: number)

  assert(not self.timeStarted, "The round has already started.");

  self.timeStarted = DateTime.now().UnixTimestampMillis;

  -- Start a timer.
  local timer = task.spawn(function()
  
    task.wait(duration);
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

  self.timeEnded = DateTime.now().UnixTimestampMillis;
  
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