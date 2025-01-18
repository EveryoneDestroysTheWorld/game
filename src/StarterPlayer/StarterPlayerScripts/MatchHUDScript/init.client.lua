--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local RoundTimer = require(script.ReactComponents.RoundTimer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local BottomCenterSection = require(script.ReactComponents.BottomCenterSection);

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

    local contestant: ClientContestant?;
    for _, possibleContestant in round.contestants do

      if possibleContestant.id == player.UserId then

        contestant = possibleContestant;
        break;

      end;

    end;

    assert(contestant);
  
    local root = ReactRoblox.createRoot(popupContainer);
    root:render(React.createElement(React.Fragment, {}, {
      RoundTimer = React.createElement(RoundTimer, {round = round});
      BottomCenterSection = React.createElement(BottomCenterSection, {round = round});
    }));

    ReplicatedStorage.Client.Functions.ToggleHUD.OnInvoke = function(shouldEnable: boolean?)

      popupContainer.Enabled = if typeof(shouldEnable) == "boolean" then shouldEnable else not popupContainer.Enabled;

    end;

  end;

end;

player.CharacterAdded:Connect(setupGUI);