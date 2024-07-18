local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local DestructionBar = require(ReplicatedStorage.Client.ReactComponents.DestructionBar);
local StatBarContainer = require(ReplicatedStorage.Client.ReactComponents.StatBarContainer);

local popupContainer = nil;
local player = Players.LocalPlayer;

local function setupGUI()

  if not popupContainer then

    popupContainer = Instance.new("ScreenGui");
    popupContainer.Name = "MatchHUD";
    popupContainer.Parent = player:WaitForChild("PlayerGui");
    popupContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    popupContainer.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
    popupContainer.ResetOnSpawn = false;
    popupContainer.DisplayOrder = 1;
    popupContainer.Enabled = true;
  
    local root = ReactRoblox.createRoot(popupContainer);
    root:render(React.createElement(React.Fragment, {}, {
      DestructionBar = React.createElement(DestructionBar);
      StatBarContainer = React.createElement(StatBarContainer);
    }));

  end;

end;

player.CharacterAdded:Connect(function()

  task.delay(1, setupGUI);

end);