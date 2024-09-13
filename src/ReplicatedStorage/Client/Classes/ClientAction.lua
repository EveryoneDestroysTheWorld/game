--!strict
-- This module represents an action on the client side. 
-- Client actions are intended to only capture real player actions, like mouse location and keybind presses.
-- Do not use a ClientAction to directly handle tasks that are more for the server, like updating scores or contestant health.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

export type ActionProperties = {

  -- The ID of the action. Keep this unique.
  ID: number;

  -- The name of the action.
  name: string;

  -- The Roblox asset link to the action's icon image.
  iconImage: string;

  -- The description of the action.
  description: string;

  -- The function to activate the item on the server side.
  -- You can manually activate the item some other way too.
  activate: (self: ClientAction, ...any) -> ();

  -- The function to "break down" the item. This usually runs after the round ends and sometimes after item use.
  -- You can manually break down the item some other way too.
  breakdown: (self: ClientAction) -> ();

  -- The function to initialize the item. This usually runs after the player receives an item. 
  -- This function does not mean the player activated the item. Use :activate() instead.
  initialize: (self: ClientAction) -> ();
};

export type ActionEvents = {

  -- Fired when the action is activated on the client side.
  onActivate: RBXScriptSignal<"Press" | "Hold">;

}

local ClientAction = {};
export type ClientAction = ActionProperties & ActionEvents;

function ClientAction.new(properties: ActionProperties): ClientAction

  local action = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onActivate"};
  for _, eventName in eventNames do

    events[eventName] = Instance.new("BindableEvent");
    action[eventName] = events[eventName].Event;

  end

  return action :: ClientAction;
  
end

function ClientAction.get(actionID: number): ClientAction

  for _, instance in script.Parent.Actions:GetChildren() do
  
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