--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- This module represents a ClientItem.
-- © 2024 Beastslash

export type ClientItemProperties = {
  ID: number;
  name: string;
  iconImage: string;
  description: string;
  activate: (self: ClientItem, ...any) -> ();
  breakdown: (self: ClientItem) -> ();
};

export type ClientItemEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
}

local ClientItem = {};
export type ClientItem = ClientItemProperties & ClientItemEvents;

function ClientItem.new(properties: ClientItemProperties): ClientItem

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: ClientItem;
  
end

function ClientItem.get(itemID: number): ClientItem

  for _, instance in ipairs(script.Parent.Actions:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local action = require(instance) :: any;
      if action.ID == itemID then
  
        return action.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find action from ID {itemID}.`);

end;

return ClientItem;