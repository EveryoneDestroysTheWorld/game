local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local filterTable = require(ReplicatedStorage.Shared.Modules.FilterTable);
local PersonalStatsFrame = require(script.Parent.PersonalStatsFrame);
local TeamFrame = require(script.Parent.TeamFrame);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

export type RoundResultsContentFrameProperties = {
  round: ClientRound;
}

local function RoundResultsContentFrame(props: RoundResultsContentFrameProperties)

  local round = props.round;
  
  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    LayoutOrder = 2;
    Size = UDim2.new(1, 0, 0, 0);
    AutomaticSize = Enum.AutomaticSize.Y;
  }, {
    UIFlexItem = React.createElement("UIFlexItem", {
      FlexMode = Enum.UIFlexMode.Fill;
    });
    PersonalStatsFrame = React.createElement(PersonalStatsFrame);
    LeaderboardFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new();
      AutomaticSize = Enum.AutomaticSize.XY;
    }, {
      AllyTeamFrame = React.createElement(TeamFrame, {
        teamID = 1;
        contestants = filterTable(round.contestants, function(contestant) return contestant.teamID == 1 end);
      });
      EnemyTeamFrame = React.createElement(TeamFrame, {
        teamID = 2;
        contestants = filterTable(round.contestants, function(contestant) return contestant.teamID == 2 end);
      });
    });
  })

end;

return RoundResultsContentFrame;