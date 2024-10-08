--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
local ServerContestant = require(script.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;

export type ActionProperties = {
  ID: number;
  name: string;
  description: string;
  activate: (self: ServerAction, ...any) -> ();
  breakdown: (self: ServerAction) -> ();
  initialize: (self: ServerAction, ...any) -> ();
};

export type ActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
}

local ServerAction = {};
export type ServerAction = ActionProperties & ActionEvents;

function ServerAction.new(properties: ActionProperties): ServerAction

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: ServerAction;
  
end

function ServerAction.get(actionID: number): ServerAction

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

return ServerAction;
