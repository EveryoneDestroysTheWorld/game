--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local DestructionBar = require(ReplicatedStorage.Client.ReactComponents.DestructionBar);
local StatBarContainer = require(ReplicatedStorage.Client.ReactComponents.StatBarContainer);
local PreRoundTimer = require(ReplicatedStorage.Client.ReactComponents.PreRoundTimer);
local RoundTimer = require(ReplicatedStorage.Client.ReactComponents.RoundTimer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

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

    local round = ClientRound.fromServerRound();
  
    local root = ReactRoblox.createRoot(popupContainer);
    root:render(React.createElement(React.Fragment, {}, {
      PreRoundTimer = React.createElement(PreRoundTimer, {round = round});
      DestructionBar = React.createElement(DestructionBar, {round = round});
      StatBarContainer = React.createElement(StatBarContainer);
      RoundTimer = React.createElement(RoundTimer, {round = round});
    }));

  end;

end;

player.CharacterAdded:Connect(function()

  task.delay(1, setupGUI);

end);