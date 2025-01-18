--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
local types = require(script.Parent.types);

local ServerAction = {};

function ServerAction.new(properties: types.ServerActionProperties): types.ServerAction

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: types.ServerAction;
  
end

function ServerAction.get(actionID: string): types.ServerAction

  for _, instance in ipairs(script.Parent.Actions:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local action = require(instance) :: any;
      if action.id == actionID then
  
        return action.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find action from ID {actionID}.`);

end;

return ServerAction;
