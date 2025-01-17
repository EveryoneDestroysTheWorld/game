--!strict
-- This module represents an item on the server side.
-- As some items don't have meshes, the ServerItem doesn't have an equip function.
-- Equip functions should be manually handled on a case-by-case basis.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local types = require(script.Parent.types);

local ServerItem = {};

-- Returns a new ServerItem.
function ServerItem.new(properties: types.ServerItemProperties): types.ServerItem

  local item = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    item[eventName] = events[eventName].Event;

  end

  return item :: types.ServerItem;
  
end

-- Returns a ServerItem based on the ID.
function ServerItem.get(itemID: string): types.ServerItem

  for _, instance in ipairs(script.Parent.Items:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local item = require(instance) :: any;
      if item.id == itemID then
  
        return item.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find item from ID {itemID}.`);

end;

-- Returns a random ServerItem.
function ServerItem.random(): types.ServerItem

  local children = script.Parent.Items:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local item = require(selectedChild) :: any;
  return item.new();

end;

return ServerItem;
