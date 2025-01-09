--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local PreRoundLoadoutScreen = require(script.ReactComponents.PreRoundLoadoutScreen);

-- Set up the UI.
local player = Players.LocalPlayer;
local screenGUI = Instance.new("ScreenGui");
screenGUI.Name = "PreRoundLoadoutScreenGUI";
screenGUI.Parent = player:WaitForChild("PlayerGui");
screenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
screenGUI.ScreenInsets = Enum.ScreenInsets.None;
screenGUI.ResetOnSpawn = false;
screenGUI.DisplayOrder = 1;
screenGUI.Enabled = true;

local root = ReactRoblox.createRoot(screenGUI);
root:render(React.createElement(PreRoundLoadoutScreen));
