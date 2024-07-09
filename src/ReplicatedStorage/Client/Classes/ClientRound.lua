--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientContestant = require(script.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type RoundProperties = {
  ID: string;  
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  contestants: {ClientContestant};
}

local ClientRound = {
  __index = {};
};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
}

export type ClientRound = typeof(setmetatable({}, ClientRound)) & RoundProperties & RoundEvents;

function ClientRound.new(properties: RoundProperties): ClientRound

  local round = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onEnded"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    round[eventName] = events[eventName].Event;

  end

  ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function(roundID: string)
  
    if roundID == round.ID then

      events.onEnded:Fire();

    end;

  end);

  return setmetatable(round, ClientRound) :: ClientRound;
  
end

return ClientRound;