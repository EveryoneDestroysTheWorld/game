--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type ActionProperties = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;
  
  user: Player?;
  
};

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

export type ActionMethods<ExtendedAction> = {
  activate: (self: ExtendedAction) -> ();
  initialize: (self: ExtendedAction) -> ();
  breakdown: (self: ExtendedAction) -> ();
}

local Action = {
  __index = {} :: ActionProperties;
};

export type Action = typeof(setmetatable({}, Action));

local events: {[any]: {[string]: BindableEvent}} = {};

function Action.new<T>(properties: ActionProperties): Action

  local action = properties;

  events[action] = {};
  for _, eventName in ipairs({"onActivate", "onHoldRelease"}) do

    events[action][eventName] = Instance.new("BindableEvent");
    (action :: {})[eventName] = events[action][eventName].Event;

  end

  return setmetatable(action, Action);
  
end

return Action;