--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.

export type ActionProperties = {
  ID: number;
  name: string;
  iconImage: string;
  description: string;
  activate: (self: ClientAction, ...any) -> ();
  breakdown: (self: ClientAction) -> ();
};

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
  onHoldRelease: RBXScriptSignal;
}

local ClientAction = {};
export type ClientAction = ActionProperties & ActionEvents;

function ClientAction.new(properties: ActionProperties): ClientAction

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate", "onHoldRelease"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: ClientAction;
  
end

function ClientAction.get(actionID: number): ClientAction

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

return ClientAction;