--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local QuickSelectionMenu = require(ReplicatedStorage.Client.ReactComponents.QuickSelectionMenu);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function activate(self: SharedTypes.DetachLimbClientAction)

  local gui = self.attributes.gui or Instance.new("ScreenGui");
  gui.ScreenInsets = Enum.ScreenInsets.None;
  gui.Parent = Players.LocalPlayer.PlayerGui;
  self.attributes.gui = gui;

  local reactRoot = ReactRoblox.createRoot(gui);
  reactRoot:render(React.createElement(QuickSelectionMenu, {
    options = {
      {
        key = "Head";
        labelText = "Head";
        iconImage = "rbxassetid://136558858062155"
      };
      {
        key = "LeftArm";
        labelText = "Left Arm";
        iconImage = "rbxassetid://136558858062155"
      };
      {
        key = "Torso";
        labelText = "Torso";
        iconImage = "rbxassetid://136558858062155"
      };
      {
        key = "RightArm";
        labelText = "Right Arm";
        iconImage = "rbxassetid://136558858062155"
      };
      {
        key = "LeftLeg";
        labelText = "Left Leg";
        iconImage = "rbxassetid://136558858062155"
      };
      {
        key = "RightLeg";
        labelText = "Right Leg";
        iconImage = "rbxassetid://136558858062155"
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