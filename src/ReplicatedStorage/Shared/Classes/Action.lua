--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type ActionProperties = {
  ID: number;
  name: string;
  description: string;
  activate: (self: Action) -> ();
  initialize: (self: Action) -> ();
  breakdown: (self: Action) -> ();
};

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

local Action = {
  __index = {};
};

export type Action = typeof(setmetatable({} :: ActionProperties, Action)) & ActionEvents;

function Action.new(properties: ActionProperties): Action

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate", "onHoldRelease"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return setmetatable(action, Action) :: Action;
  
end

return Action;