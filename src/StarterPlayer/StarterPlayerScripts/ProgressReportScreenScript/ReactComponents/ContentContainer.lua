--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ProgressBarContainer = require(script.Parent.ProgressBarContainer);
local PlayerSelectionContainer = require(script.Parent.PlayerSelectionContainer);
local StatisticsContainer = require(script.Parent.StatisticsContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local Players = game:GetService("Players");

export type ContentContainerProperties = {
  round: ClientRound;
}

local function ContentContainer(properties: ContentContainerProperties)

  local selectedContestant: ClientContestant?, setSelectedContestant = React.useState(nil :: ClientContestant?);

  local teams, setTeams = React.useState({});

  React.useEffect(function()
  
    local newTeams = {};

    local newSelectedContestant = nil;
    for _, contestant in properties.round.contestants do

      newTeams[contestant.teamID] = newTeams[contestant.teamID] or {};
      table.insert(newTeams[contestant.teamID], contestant);

      if not newSelectedContestant and contestant.player == Players.LocalPlayer then

        newSelectedContestant = contestant;

      end;

    end;

    if not newSelectedContestant then

      newSelectedContestant = properties.round.contestants[1];

    end;

    setSelectedContestant(newSelectedContestant);
    setTeams(newTeams);

  end, {properties.round});

  print(selectedContestant and selectedContestant.statistics);

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
    ProgressBarContainer = React.createElement(ProgressBarContainer, {teams = teams});
    PlayerSelectionContainer = React.createElement(PlayerSelectionContainer, {
      teams = teams; 
      selectedContestant = selectedContestant;
      onSelectedContestantChanged = function(contestant)

        setSelectedContestant(contestant);

      end;
    });
    StatisticsContainer = if selectedContestant and selectedContestant.statistics then
      React.createElement(StatisticsContainer, {
        statistics = selectedContestant.statistics
      })
    else nil;
  });

end;

return ContentContainer;