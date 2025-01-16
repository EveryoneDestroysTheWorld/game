--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ProgressBarContainer = require(script.Parent.ProgressBarContainer);
local PlayerSelectionContainer = require(script.Parent.PlayerSelectionContainer);
local StatsContainer = require(script.Parent.StatsContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

export type ContentContainerProperties = {
  round: ClientRound;
}

local function ContentContainer(properties: ContentContainerProperties)

  local function categorizeContestants()

    local teams = {};

    for _, contestant in properties.round.contestants do

      teams[contestant.teamID] = teams[contestant.teamID] or {};
      table.insert(teams[contestant.teamID], contestant);

    end;

    return teams;

  end;

  local teams, setTeams = React.useState(categorizeContestants());

  React.useEffect(function()
  
    setTeams(categorizeContestants());

  end, {properties.round});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    LayoutOrder = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 10);
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    ProgressBarContainer = React.createElement(ProgressBarContainer, {teams = teams});
    PlayerSelectionContainer = React.createElement(PlayerSelectionContainer);
    StatsContainer = React.createElement(StatsContainer);
  });

end;

return ContentContainer;