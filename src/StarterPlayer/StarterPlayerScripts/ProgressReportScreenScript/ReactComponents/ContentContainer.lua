--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ProgressBarContainer = require(script.Parent.ProgressBarContainer);
local PlayerSelectionContainer = require(script.Parent.PlayerSelectionContainer);
local StatisticsContainer = require(script.Parent.StatisticsContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local types = require(ReplicatedStorage.Client.Modules.types);
local CameraService = require(ReplicatedStorage.Client.Modules.CameraService);

export type ContentContainerProperties = {
  round: ClientRound;
}

local function ContentContainer(properties: ContentContainerProperties)

  local selectedContestant: types.ClientContestant?, setSelectedContestant = React.useState(nil :: types.ClientContestant?);

  local teams, setTeams = React.useState({});

  React.useEffect(function()
  
    CameraService.lockMouse = false;

    return function()

      CameraService.lockMouse = true;

    end;

  end, {});

  React.useEffect(function()
  
    local newTeams = {};

    local newSelectedContestant = nil;
    local contestants = properties.round:getContestants();
    for _, contestant in contestants do

      newTeams[contestant.teamID] = newTeams[contestant.teamID] or {};
      table.insert(newTeams[contestant.teamID], contestant);

      if not newSelectedContestant and contestant.player == Players.LocalPlayer then

        newSelectedContestant = contestant;

      end;

    end;

    if not newSelectedContestant then

      newSelectedContestant = contestants[1];

    end;

    setSelectedContestant(newSelectedContestant);
    setTeams(newTeams);

  end, {properties.round});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    LayoutOrder = 1;
    Size = UDim2.new(1, 0, 0, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 10);
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    UIFlexItem = React.createElement("UIFlexItem", {
      FlexMode = Enum.UIFlexMode.Fill;
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(720, math.huge);
    });
    ProgressBarContainer = React.createElement(ProgressBarContainer, {teams = teams});
    PlayerSelectionContainer = React.createElement(PlayerSelectionContainer, {
      teams = teams; 
      selectedContestant = selectedContestant;
      onSelectedContestantChanged = function(contestant)

        setSelectedContestant(contestant);

      end;
    });
    StatisticsContainer = if selectedContestant then
      React.createElement(StatisticsContainer, {
        selectedContestant = selectedContestant;
        teams = teams;
      })
    else nil;
  });

end;

return ContentContainer;