--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientAction = require(script.Parent.Parent.ClientAction);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;
local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);

local ChangeBallTypeClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Change Ball Type";
  description = "Do a change-up";
  iconImage = "rbxassetid://18464513809";
};

function ChangeBallTypeClientAction.new(): ClientAction

  local player = Players.LocalPlayer;
  local remoteName: string = `{player.UserId}_{ChangeBallTypeClientAction.id}`;
  local _gui: ScreenGui? = nil;
  local root;

  local function breakdown(self: ClientAction)
    
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

  end;

  local function activate(self: ClientAction)

    local gui = _gui or Instance.new("ScreenGui");
    gui.ScreenInsets = Enum.ScreenInsets.None;
    gui.Parent = player.PlayerGui;

    root = ReactRoblox.createRoot(gui);
    root:render(React.createElement(QuickSelectionMenu, {
      options = {
        {
          key = "Regular";
          labelText = "Regular Ball";
          iconImage = "rbxassetid://139648735745838"
        };
        {
          key = "Regular2";
          labelText = "Regular Ball";
          iconImage = "rbxassetid://139648735745838"
        };
      };
      onSelectionConfirmed = function(selection)

        root:unmount();
        gui:Destroy();
        _gui = nil;
        ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer(selection.key);

      end;
    }));

  end;

  local function initialize(self: ClientAction)

    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
      type = "Action";
      key = self.id;
      onActivate = function() 
      
        self:activate();

      end;
      iconImage = "rbxassetid://75206024784140";
    }));

  end;

  local action = ClientAction.new({
    id = ChangeBallTypeClientAction.id;
    name = ChangeBallTypeClientAction.name;
    iconImage = ChangeBallTypeClientAction.iconImage;
    description = ChangeBallTypeClientAction.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });

  return action;

end

return ChangeBallTypeClientAction;
