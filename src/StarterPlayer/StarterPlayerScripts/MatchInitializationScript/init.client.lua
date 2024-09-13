--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local MatchInitializationScreen = require(script.ReactComponents.MatchInitializationScreen);

-- Set up the UI.
local player = Players.LocalPlayer;
local screenGUI = Instance.new("ScreenGui");
screenGUI.Name = "MatchInitializationScreenGUI";
screenGUI.Parent = player:WaitForChild("PlayerGui");
screenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
screenGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
screenGUI.ResetOnSpawn = false;
screenGUI.DisplayOrder = 1;
screenGUI.Enabled = true;

local root = ReactRoblox.createRoot(screenGUI);
root:render(React.createElement(MatchInitializationScreen));
