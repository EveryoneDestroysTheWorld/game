--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local GuiService = game:GetService("GuiService");
local UserInputService = game:GetService("UserInputService");

local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local player = Players.LocalPlayer;
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);

local VirtualController = require(script.Components.VirtualController);

local function initializeVirtualController()

  GuiService.TouchControlsEnabled = false;
  
  local function enableGUI()

    local targetGUI = script.VirtualControllerGUI:Clone();
    targetGUI.Parent = player:WaitForChild("PlayerGui");

    local targetIndicatorRoot = ReactRoblox.createRoot(targetGUI);
    targetIndicatorRoot:render(React.createElement(VirtualController));

  end;

  if UserInputService.TouchEnabled then

    enableGUI();

  else

    UserInputService.TouchStarted:Once(enableGUI);
  
  end;

end;

local round = ClientRound.fromServerRound();
if round.status == "Active" then

  initializeVirtualController();

else

  round.onStarted:Once(initializeVirtualController);

end