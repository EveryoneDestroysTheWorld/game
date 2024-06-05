--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.

export type ActionProperties = {
  ID: number;
  name: string;
  description: string;
  activate: (self: Action) -> ();
  breakdown: (self: Action) -> ();
};

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

local Action = {};
export type Action = ActionProperties & ActionEvents;

function Action.new(properties: ActionProperties): Action

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate", "onHoldRelease"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: Action;
  
end

function Action.get(actionID: number): Action

  for _, instance in ipairs(script.Parent.Actions:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local action = require(instance) :: any;
      if action.ID == actionID then
  
        return action.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find action from ID {actionID}.`);

end;

return Action;