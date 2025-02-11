--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);
local types = require(ReplicatedStorage.Client.Modules.types);

local id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
local name = "Change Ball Type";
local description = "Do a change-up";
local iconImage = "rbxassetid://75206024784140";

local ChangeBallTypeClientAction = {
  id = id;
  name = name;
  description = description;
  iconImage = iconImage;
  __index = {
    id = id;
    name = name;
    iconImage = iconImage;
    description = description;
  } :: types.ChangeBallTypeClientAction;
};

local player = Players.LocalPlayer;

function ChangeBallTypeClientAction.new(): types.ChangeBallTypeClientAction

  local remoteName = `{player.UserId}_{ChangeBallTypeClientAction.id}`;
  local action = (setmetatable({}, ChangeBallTypeClientAction) :: any) :: types.ChangeBallTypeClientAction;
  action.remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    -- shortcutCharacter = "0 - 9";
    description = action.name;
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = iconImage;
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

        action:activate(ballType);

      end;

    end;

  end;

  ContextActionService:BindAction("ActivateChangeBallType", checkKey, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four)

  return action;

end

function ChangeBallTypeClientAction.__index:activate(ballType: types.BallType?)

  if ballType then

    if self.gui then

      self.gui:Destroy();
      self.gui = nil;

    end;

    self.remoteFunction:InvokeServer(ballType);

  else

    local gui = self.gui or Instance.new("ScreenGui");
    self.gui = gui;
    gui.ScreenInsets = Enum.ScreenInsets.None;
    gui.Parent = player.PlayerGui;

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
        self.gui = nil;
        self.remoteFunction:InvokeServer(selection.key);

      end;
    }));

  end;

end

function ChangeBallTypeClientAction.__index:breakdown()
    
  ContextActionService:UnbindAction("ActivateChangeBallType");
  HUDService:removeHUDButton("Action", self.id);

end;

return ChangeBallTypeClientAction;
