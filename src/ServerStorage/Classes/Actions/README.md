# ServerActions
See [ServerAction.lua](../ServerAction.lua) for more information on what ClientActions are.

## Design philosophy
* Design server actions as if any archetype can use them. In v1, users will be able to mix up actions and create custom archetypes.
* Assume bots can use actions too. For example, you should get the character from `contestant.character` instead of `contestant.player.Character` in most cases.

## Template
```lua
--!strict
-- Programmers: PREFERRED_NAME (USER_NAME)
-- Designers: PREFERRED_NAME (USER_NAME)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ACTION_NAMEClientAction = require(ReplicatedStorage.Client.Classes.Actions.ACTION_NAMEClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local ACTION_NAMEServerAction = {
  id = ACTION_NAMEClientAction.id;
  name = ACTION_NAMEClientAction.name;
  description = ACTION_NAMEClientAction.description;
  __index = {
    name = ACTION_NAMEClientAction.name;
    id = ACTION_NAMEClientAction.id;
    description = ACTION_NAMEClientAction.description;
  } :: types.ACTION_NAMEServerAction;
};

function ACTION_NAMEServerAction.new(properties: types.ServerActionConstructorProperties): types.ACTION_NAMEServerAction

  local action = (setmetatable({}, ACTION_NAMEServerAction) :: any) :: types.ACTION_NAMEServerAction;
  action.contestant = properties.contestant;

  local player = action.contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function()

      return action:activate();

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

function ACTION_NAMEServerAction.__index:activate(): ()

  

end;

function ACTION_NAMEServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end;

return ACTION_NAMEServerAction;
```