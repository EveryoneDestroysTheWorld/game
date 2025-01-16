--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local StatisticContainer = require(script.Parent.StatisticContainer);
local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type ProgressReportScreenProperties = {
  selectedContestant: ClientContestant;
  teams: {
    [number]: {ClientContestant}
  };
}

local function StatisticsContainer(properties: ProgressReportScreenProperties)

  local totalPartCount, setTotalPartCount = React.useState(0);
  
  React.useEffect(function()
  
    task.spawn(function()
    
      setTotalPartCount(ReplicatedStorage.Shared.Functions.GetTotalStagePartCount:InvokeServer());

    end);

  end, {});

  local allStatistics, setAllStatistics = React.useState({});
  local topAchievers, setTopAchievers = React.useState(nil);
  React.useState(function()
  
    local newAllStatistics = {};
    local newTopAchievers: {[string]: {ClientContestant}} = {};

    for _, members in properties.teams do

      for _, contestant in members do

        if contestant.statistics then

          for name, value in contestant.statistics do

            if typeof(name) == "string" and typeof(value) == "number" then

              -- Update current 
              newAllStatistics[name] = (newAllStatistics[name] or 0) + value;

              -- Update top achievers.
              newTopAchievers[name] = newTopAchievers[name] or {};
              local currentTopAchiever = newTopAchievers[name][1];
              if not currentTopAchiever or (currentTopAchiever.statistics and value > currentTopAchiever.statistics[name]) then

                newTopAchievers[name] = {contestant}

              elseif currentTopAchiever.statistics and value == currentTopAchiever.statistics[name] then

                table.insert(newTopAchievers[name], contestant);

              end;

            end;

          end;

        end;

      end;

    end;

    setAllStatistics(newAllStatistics);
    setTopAchievers(newTopAchievers);

  end, {properties.teams});
  
  if properties.selectedContestant.statistics and topAchievers then

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
        value = properties.selectedContestant.statistics.partsClaimed;
        totalValue = totalPartCount;
        isTopAchiever = not not table.find(topAchievers.partsClaimed, properties.selectedContestant);
      });
      DestructionsContainer = React.createElement(StatisticContainer, {
        LayoutOrder = 2;
        name = "Destructions";
        value = properties.selectedContestant.statistics.partsDestroyed;
        totalValue = allStatistics.partsDestroyed;
        isTopAchiever = not not table.find(topAchievers.partsDestroyed, properties.selectedContestant);
      });
      RestorationsContainer = React.createElement(StatisticContainer, {
        LayoutOrder = 3;
        name = "Restorations";
        value = properties.selectedContestant.statistics.partsRestored;
        totalValue = allStatistics.partsRestored;
        isTopAchiever = not not table.find(topAchievers.partsRestored, properties.selectedContestant);
      });
      EliminationsContainer = React.createElement(StatisticContainer, {
        LayoutOrder = 4;
        name = "Eliminations";
        value = properties.selectedContestant.statistics.eliminationCount;
        totalValue = allStatistics.eliminationCount;
        isTopAchiever = not not table.find(topAchievers.eliminationCount, properties.selectedContestant);
      });
      RecoveriesContainer = React.createElement(StatisticContainer, {
        LayoutOrder = 5;
        name = "Recoveries";
        value = properties.selectedContestant.statistics.recoveryCount;
        totalValue = allStatistics.recoveryCount;
        isTopAchiever = not not table.find(topAchievers.recoveryCount, properties.selectedContestant);
      });
      DeathsContainer = React.createElement(StatisticContainer, {
        LayoutOrder = 6;
        name = "Deaths";
        value = properties.selectedContestant.statistics.deathCount;
        totalValue = allStatistics.deathCount;
        isTopAchiever = not not table.find(topAchievers.deathCount, properties.selectedContestant);
      });
    });

  end;

end;

return StatisticsContainer;