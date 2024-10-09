--!strict
-- This module represents an item on the server side.
-- As some items don't have meshes, the ServerItem doesn't have an equip function.
-- Equip functions should be manually handled on a case-by-case basis.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

export type ServerItemProperties = {

  -- The ID of the item. Keep this unique.
  ID: number;
  name: string;

  -- The description of the item. 
  description: string;

  -- The function to activate the item on the server side.
  -- You can manually activate the item some other way too.
  activate: (self: ServerItem, ...any) -> ();

  -- The function to "break down" the item. This usually runs after the round ends and sometimes after item use.
  -- You can manually break down the item some other way too.
  breakdown: (self: ServerItem, ...any) -> ();

  -- The function to initialize the item. This usually runs after the player receives an item. 
  -- This function does not mean the player activated the item. Use :activate() instead.
  initialize: (self: ServerItem, ...any) -> ();

};

export type ServerItemEvents = {

  -- Called when the item activates.
  onActivate: RBXScriptSignal<"Press" | "Hold">;

}

local ServerItem = {};
export type ServerItem = ServerItemProperties & ServerItemEvents;

-- Returns a new ServerItem.
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

-- Returns a ServerItem based on the ID.
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

-- Returns a random ServerItem.
function ServerItem.random(): ServerItem

  local children = script.Parent.Items:GetChildren();
  local selectedChild = children[math.random(1, #children)];
  local item = require(selectedChild) :: any;
  return item.new();

end;

return ServerItem;
