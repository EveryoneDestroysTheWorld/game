--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local StatisticContainer = require(script.Parent.StatisticContainer);
local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type ProgressReportScreenProperties = {
  statistics: TurfWarContestantStatistics;
}

local function StatisticsContainer(properties: ProgressReportScreenProperties)

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    LayoutOrder = 3;
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 1);
    });
    ClaimsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 1;
      name = "Claims";
      value = properties.statistics.partsClaimed;
    });
    DestructionsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 2;
      name = "Destructions";
      value = properties.statistics.partsDestroyed;
    });
    RestorationsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 3;
      name = "Restorations";
      value = properties.statistics.partsRestored;
    });
    EliminationsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 4;
      name = "Eliminations";
      value = properties.statistics.eliminationCount;
    });
    RecoveriesContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 5;
      name = "Recoveries";
      value = properties.statistics.recoveryCount;
    });
    DeathsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 6;
      name = "Deaths";
      value = properties.statistics.deathCount;
    });
  });

end;

return StatisticsContainer;