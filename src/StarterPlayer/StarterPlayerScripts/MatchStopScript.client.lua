local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local MatchStoppagePopup = require(ReplicatedStorage.Client.ReactComponents.MatchStoppagePopup);

local popupContainer = nil;

local function setupGUI()

  if not popupContainer then

    local player = Players.LocalPlayer;
    popupContainer = Instance.new("ScreenGui");
    popupContainer.Name = "MatchStoppageNotificationGUI";
    popupContainer.Parent = player:WaitForChild("PlayerGui");
    popupContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    popupContainer.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
    popupContainer.ResetOnSpawn = false;
    popupContainer.DisplayOrder = 1;
    popupContainer.Enabled = true;
  
    local root = ReactRoblox.createRoot(popupContainer);
    root:render(React.createElement(MatchStoppagePopup));

  end;

end;

ReplicatedStorage.Shared.Events.RoundStopped.OnClientEvent:Connect(function()

  setupGUI();

end)