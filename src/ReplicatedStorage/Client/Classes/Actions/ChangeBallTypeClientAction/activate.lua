--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local React = require(ReplicatedStorage.Shared.Packages.react);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);

local function activate(self: SharedTypes.ChangeBallTypeClientAction)

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

return activate;