local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local MatchInitializationScreen = require(ReplicatedStorage.Client.ReactComponents.MatchInitializationScreen);

-- Set up the UI.
local player = Players.LocalPlayer;
local actionButtonContainer = Instance.new("ScreenGui");
actionButtonContainer.Name = "MatchInitializationScreenGUI";
actionButtonContainer.Parent = player:WaitForChild("PlayerGui");
actionButtonContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
actionButtonContainer.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
actionButtonContainer.ResetOnSpawn = false;
actionButtonContainer.DisplayOrder = 1;
actionButtonContainer.Enabled = true;

local root = ReactRoblox.createRoot(actionButtonContainer);
root:render(React.createElement(MatchInitializationScreen));

