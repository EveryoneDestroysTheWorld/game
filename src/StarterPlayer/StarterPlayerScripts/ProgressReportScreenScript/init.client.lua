--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ProgressReportScreen = require(script.ReactComponents.ProgressReportScreen);
local createReactScreenGUI = require(ReplicatedStorage.Client.Modules.createReactScreenGUI);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);

local round = ClientRound.fromServerRound();
round.onEnded:Once(function()

  -- Set up the UI.
  local screenGUI = createReactScreenGUI();
  screenGUI.Name = "ProgressReportScreenGUI";

  local root = ReactRoblox.createRoot(screenGUI);
  root:render(React.createElement(ProgressReportScreen, {
    round = round
  }));

end);
