--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TeamProgressBarContainer = require(script.Parent.TeamProgressBarContainer);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type ProgressBarContainerProperties = {
  teams: {
    [number]: {ClientContestant}
  }
};

local function ProgressBarContainer(properties: ProgressBarContainerProperties)

  local teamContainers, setTeamContainers = React.useState({});
  React.useEffect(function()

    task.spawn(function()

      local newTeamContainers = {};

      -- Count the claimed parts per team.
      local countList = {};
      for teamID, contestantList in properties.teams do

        local claimedPartCount = 0;
        for _, contestant in contestantList do

          if contestant.statistics then

            claimedPartCount += contestant.statistics.partsClaimed;

          end;

        end;

        countList[teamID] = claimedPartCount;

      end;

      local totalStagePartCount = ReplicatedStorage.Shared.Functions.GetTotalStagePartCount:InvokeServer();

      for teamID, partDestructionCount in countList do

        table.insert(newTeamContainers, React.createElement(TeamProgressBarContainer, {
          key = teamID,
          percentage = partDestructionCount / totalStagePartCount;
        }));

      end;

      setTeamContainers(newTeamContainers);

    end);
  
  end, {properties.teams});

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new();
    BackgroundTransparency = 0.6;
    Size = UDim2.new(1, 0, 0, 30);
    LayoutOrder = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 10);
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 5);
      PaddingRight = UDim.new(0, 5);
      PaddingTop = UDim.new(0, 5);
      PaddingBottom = UDim.new(0, 5);
    });
    TeamContainers = React.createElement(React.Fragment, {}, teamContainers);
  });

end;

return ProgressBarContainer;