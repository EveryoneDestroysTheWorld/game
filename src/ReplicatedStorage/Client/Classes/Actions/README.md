# ClientActions
See [ClientAction.lua](../ClientAction.lua) for more information on what ClientActions are.

## Template
```lua
--!strict
-- Programmers: [Name of programmer] ([Roblox username of programmer])
-- Designers: [Name of designer] ([Roblox username of designer])
-- © [current year] Beastslash LLC

local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local ExtendedClientAction = {
  ID = 0; -- Replace this. Very important.
  name = "Extended";
  description = "This is an example of an action.";
  iconImage = "rbxassetid://18464513809";
};

function ExtendedClientAction.new(): ClientAction

  local remoteName: string;

  local function breakdown(self: ClientAction)

    ReplicatedStorage.Client.Functions.RemoveHUDButton:Invoke("Action", self.ID);

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

  end;

  local function initialize(self: ClientAction)

    remoteName = `{player.UserId}_{self.ID}`;

    -- This adds a HUD button. Add as many as you like.
    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
      type = "Action";
      key = self.ID;
      onActivate = function()
  
        self:activate();
  
      end;
      shortcutCharacter = "L";
      iconImage = "rbxassetid://17771917538";
    }));

  end;

  local action = ClientAction.new({
    ID = ExtendedClientAction.ID;
    name = ExtendedClientAction.name;
    iconImage = ExtendedClientAction.iconImage;
    description = ExtendedClientAction.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });

  return action;

end

return ExtendedClientAction;
```
