--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);
local types = require(ReplicatedStorage.Client.Modules.types);

local ChangeBallTypeClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Change Ball Type";
  description = "Do a change-up";
  iconImage = "rbxassetid://18464513809";
  __index = {} :: types.ChangeBallTypeClientAction;
};

local player = Players.LocalPlayer;

function ChangeBallTypeClientAction.new(): types.ChangeBallTypeClientAction

  local overwrittenProperties = {
    id = ChangeBallTypeClientAction.id;
    name = ChangeBallTypeClientAction.name;
    iconImage = ChangeBallTypeClientAction.iconImage;
    description = ChangeBallTypeClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(`{player.UserId}_{ChangeBallTypeClientAction.id}`);
  };

  local action = (setmetatable(overwrittenProperties, ChangeBallTypeClientAction) :: any) :: types.ChangeBallTypeClientAction;

  ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
    type = "Action";
    key = action.id;
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = "rbxassetid://75206024784140";
  }));

  return action;

end

function ChangeBallTypeClientAction.__index:activate()

  local gui = self.gui or Instance.new("ScreenGui");
  self.gui = gui;
  gui.ScreenInsets = Enum.ScreenInsets.None;
  gui.Parent = player.PlayerGui;

  local reactRoot = self.reactRoot or ReactRoblox.createRoot(gui);
  self.reactRoot = reactRoot;
  reactRoot:render(React.createElement(QuickSelectionMenu, {
    options = {
      {
        key = "Regular";
        labelText = "Regular Ball";
        iconImage = "rbxassetid://139648735745838"
      };
    };
    onSelectionConfirmed = function(selection)

      reactRoot:unmount();
      gui:Destroy();
      self.gui = nil;
      self.remoteFunction:InvokeServer(selection.key);

    end;
  }));

end

function ChangeBallTypeClientAction.__index:breakdown()
    
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end;

return ChangeBallTypeClientAction;
