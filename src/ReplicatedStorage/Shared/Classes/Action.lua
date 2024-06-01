--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type ActionProperties<T = {}> = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;
  
} & T;

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

export type ActionMethods<T> = {
  activate: (self: T) -> ();
  initialize: (self: T) -> ();
  breakdown: (self: T) -> ();
}

local Action = {
  __index = {};
};

export type Action<T> = typeof(setmetatable({}, {__index = Action.__index})) & ActionProperties<T> & ActionEvents & ActionMethods<T>;

local events: {[any]: {[string]: BindableEvent}} = {};

function Action.new<T>(properties: ActionProperties<T>): Action<T>

  local action = properties;

  events[action] = {};
  for _, eventName in ipairs({"onActivate", "onHoldRelease"}) do

    events[action][eventName] = Instance.new("BindableEvent");
    (action :: {})[eventName] = events[action][eventName].Event;

  end

  return setmetatable(action :: {}, {__index = Action.__index}) :: Action<T>;
  
end

return Action;