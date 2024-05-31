--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Power.
type PowerProperties = {
  
  -- The stage's unique ID.
  ID: string;
  
  name: string;

  description: string?;

  initialize: (self: Power, events: {[string]: BindableEvent}) -> ();

  breakdown: (self: Power) -> ();
  
}

type PowerEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

local Power = {
  __index = {};
};

export type Power = typeof(setmetatable({}, {__index = Power.__index})) & PowerProperties & PowerEvents;

local events: {[any]: {[string]: BindableEvent}} = {};

function Power.new(properties: PowerProperties): Power

  local power = properties;

  events[power] = {};
  for _, eventName in ipairs({"onActivate", "onHoldRelease"}) do

    events[power][eventName] = Instance.new("BindableEvent");
    power[eventName] = events[power][eventName].Event;

  end

  -- Fill in the events.
  power.initialize = function(self)

    properties.initialize(self, events[power]);

  end;

  return setmetatable(properties, {__index = Power.__index}) :: Power
  
end



return Power;