--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local ReplicatedStorage = game:GetService("ReplicatedStorage");

export type RoundProperties = {
  ID: string;
}

local Round = {
  __index = {};
};

export type RoundEvents = {
  onEnded: RBXScriptSignal;
}

export type Round = typeof(setmetatable({} :: RoundProperties, Round)) & RoundEvents;

function Round.new(properties: RoundProperties): Round

  local round = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onEnded"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    round[eventName] = events[eventName].Event;

  end

  ReplicatedStorage.Shared.Events.RoundEnded:Connect(function(roundID: string)
  
    if roundID == round.ID then

      events.onEnded:Fire();

    end;

  end);

  return setmetatable(properties, Round) :: Round;
  
end

return Round;