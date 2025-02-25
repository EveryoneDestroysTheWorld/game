--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local React = require(ReplicatedStorage.Shared.Packages.react);
local KeybindNotificationService = require(ReplicatedStorage.Client.Modules.KeybindNotificationService);
local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local LocalTypes = require(script.types);

local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);

local ChangeBallTypeClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Change Ball Type";
  description = "Do a change-up";
  iconImage = "rbxassetid://75206024784140";
};

function ChangeBallTypeClientAction.new(): LocalTypes.ChangeBallTypeClientAction

  local remoteName = `{Players.LocalPlayer.UserId}_{ChangeBallTypeClientAction.id}`;
  local action: LocalTypes.ChangeBallTypeClientAction = {
    id = ChangeBallTypeClientAction.id;
    name = ChangeBallTypeClientAction.name;
    description = ChangeBallTypeClientAction.description;
    iconImage = ChangeBallTypeClientAction.iconImage;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    activate = function(self: LocalTypes.ChangeBallTypeClientAction)

      local gui = self.attributes.gui or Instance.new("ScreenGui");
      self.attributes.gui = gui;
      gui.ScreenInsets = Enum.ScreenInsets.None;
      gui.Parent = Players.LocalPlayer.PlayerGui;
    
      local reactRoot = ReactRoblox.createRoot(gui);
      reactRoot:render(React.createElement(QuickSelectionMenu, {
        options = {
          {
            key = "Regular";
            labelText = "Regular Ball";
            iconImage = "rbxassetid://139648735745838"
          };
          {
            key = "Explosive";
            labelText = "Explosive Ball";
            iconImage = "rbxassetid://73246050129377"
          };
          {
            key = "Electric";
            labelText = "Electric Ball";
            iconImage = "rbxassetid://84087555822097"
          };
          {
            key = "Poison";
            labelText = "Poison Ball";
            iconImage = "rbxassetid://89838520119073"
          };
        };
        onSelectionConfirmed = function(selection)
    
          reactRoot:unmount();
          gui:Destroy();
          self.attributes.gui = nil;
          self.remoteFunction:InvokeServer(selection.key);
    
        end;
      }));
    
    end;
    breakdown = function(self: LocalTypes.ChangeBallTypeClientAction)

      if self.attributes.gui then
    
        self.attributes.gui:Destroy();
        self.attributes.gui = nil;
    
      end;
    
      ContextActionService:UnbindAction("ActivateChangeBallTypeAction");
      HUDService:removeHUDButton("Action", self.id);
    
    end;
    attributes = {}
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    -- shortcutCharacter = "0 - 9";
    description = action.name;
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = action.iconImage;
  });

  local function checkKey(_, inputState: Enum.UserInputState, inputObject: InputObject)

    if inputState == Enum.UserInputState.Begin then

      local map = {
        [Enum.KeyCode.One] = "Regular";
        [Enum.KeyCode.Two] = "Explosive";
        [Enum.KeyCode.Three] = "Electric";
        [Enum.KeyCode.Four] = "Poison";
      };

      local ballType = map[inputObject.KeyCode];
      if ballType then

        if action.attributes.gui then

          action.attributes.gui:Destroy();
          action.attributes.gui = nil;
    
        end;
    
        action.remoteFunction:InvokeServer(ballType);

        KeybindNotificationService:setMessage(`{ballType} Ball`);

      end;

    end;

  end;

  ContextActionService:BindAction("ActivateChangeBallTypeAction", checkKey, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four);

  return action;

end

return ChangeBallTypeClientAction;
