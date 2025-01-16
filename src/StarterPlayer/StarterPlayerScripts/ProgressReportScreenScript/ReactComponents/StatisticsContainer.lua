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

  local totalPartCount, setTotalPartCount = React.useState(0);
  
  React.useEffect(function()
  
    task.spawn(function()
    
      setTotalPartCount(ReplicatedStorage.Shared.Functions.GetTotalStagePartCount:InvokeServer());

    end);

  end, {});
  
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
      totalValue = totalPartCount;
    });
    DestructionsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 2;
      name = "Destructions";
      value = properties.statistics.partsDestroyed;
      totalValue = 0;
    });
    RestorationsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 3;
      name = "Restorations";
      value = properties.statistics.partsRestored;
      totalValue = 0;
    });
    EliminationsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 4;
      name = "Eliminations";
      value = properties.statistics.eliminationCount;
      totalValue = 0;
    });
    RecoveriesContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 5;
      name = "Recoveries";
      value = properties.statistics.recoveryCount;
      totalValue = 0;
    });
    DeathsContainer = React.createElement(StatisticContainer, {
      LayoutOrder = 6;
      name = "Deaths";
      value = properties.statistics.deathCount;
      totalValue = 0;
    });
  });

end;

return StatisticsContainer;