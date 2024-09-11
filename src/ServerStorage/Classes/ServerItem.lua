--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an item on the server side.

export type ServerItemProperties = {
  ID: number;
  name: string;
  description: string;
  activate: (self: ServerItem, ...any) -> ();
  breakdown: (self: ServerItem) -> ();
};

export type ServerItemEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
}

local ServerItem = {};
export type ServerItem = ServerItemProperties & ServerItemEvents;

function ServerItem.new(properties: ServerItemProperties): ServerItem

  local item = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    item[eventName] = events[eventName].Event;

  end

  return item :: ServerItem;
  
end

function ServerItem.get(itemID: number): ServerItem

  for _, instance in ipairs(script.Parent.Items:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local item = require(instance) :: any;
      if item.ID == itemID then
  
        return item.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find item from ID {itemID}.`);

end;

function ServerItem.random(): ServerItem

  local children = script.Parent.Items:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local item = require(selectedChild) :: any;
  return item.new();

end;

return ServerItem;
