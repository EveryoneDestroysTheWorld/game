--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type ActionProperties = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string?;
  
}

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

export type ActionMethods = {
  activate: <action>(self: action) -> ();
  initialize: <action>(self: action) -> ();
  breakdown: <action>(self: action) -> ();
}

local Action = {
  __index = {};
};

export type Action = typeof(setmetatable({} :: ActionProperties & ActionEvents & ActionMethods, {__index = Action.__index}));

local events: {[any]: {[string]: BindableEvent}} = {};

function Action.new(properties: ActionProperties): Action

  local power = properties;

  events[power] = {};
  for _, eventName in ipairs({"onActivate", "onHoldRelease"}) do

    events[power][eventName] = Instance.new("BindableEvent");
    power[eventName] = events[power][eventName].Event;

  end

  return setmetatable(properties :: ActionProperties & ActionEvents & ActionMethods, {__index = Action.__index});
  
end

return Action;