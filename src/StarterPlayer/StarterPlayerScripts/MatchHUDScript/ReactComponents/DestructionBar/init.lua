--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local HorizontalUIListLayout = require(script.HorizontalUIListLayout);
local TeamDot = require(script.TeamDot);
local ProgressDot = require(script.ProgressDot);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type DestructionBarProps = {
  round: ClientRound;
}

local function DestructionBar(props: DestructionBarProps)

  -- Animate the stat bar.
  local gameModeStats, setGameModeStats = React.useState(nil);
  local shouldShowAllDots = useResponsiveDesign({minimumWidth = 800});
  React.useEffect(function(): ()
    
    local function updateBar()

      task.spawn(function()
      
        local gameModeStats = ReplicatedStorage.Shared.Functions.GetGameModeStats:InvokeServer();
        setGameModeStats(gameModeStats);

      end);

    end;
    
    local updateEvent = ReplicatedStorage.Shared.Events.GameModeStatsUpdated.OnClientEvent:Connect(updateBar)
    updateBar();

    return function()

      updateEvent:Disconnect();

    end;

  end, {props.round});

  local function getProgressDots()

    if not gameModeStats then

      return {};

    end;

    local teamClaimedParts = {0, 0};
    for contestantID, contestantStats in pairs(gameModeStats.contestants) do

      for _, contestant in props.round.contestants do

        if contestant.ID == tonumber(contestantID) then

          if contestant.teamID then

            teamClaimedParts[contestant.teamID] += contestantStats.partsClaimed;

          end;
          break;

        end;

      end;

    end;

    local newProgressDots = {};
    local teamDotData = {};
    local team1Remainder = 0;
    local blanks = 0;
    local dotCount = if shouldShowAllDots then 40 else 5;
    for teamNumber = 1, 2 do

      local newDots = {};
      local percentage = dotCount * teamClaimedParts[teamNumber] / gameModeStats.totalStageParts;
      local flooredPercentage = math.floor(percentage);
      local progressRemainder = percentage - flooredPercentage;
      
      if teamNumber == 2 then

        for progressDotIndex = 1, dotCount - #teamDotData[1] - flooredPercentage - (if progressRemainder > 0 then 1 else 0) do

          blanks += 1;

        end;

      end;

      for progressDotIndex = 1, flooredPercentage do

        table.insert(newDots, 1);

      end;

      if progressRemainder > 0 and (teamNumber == 1 or team1Remainder < progressRemainder) then

        table.insert(newDots, if teamNumber == 1 then #newDots + 1 else 1, progressRemainder);
      
        if team1Remainder > 0 and teamNumber == 2 then

          table.remove(teamDotData[1]);

        end;

      end;

      teamDotData[teamNumber] = newDots;

    end;

    local layoutOrder = 1;
    for teamNumber, teamDots in teamDotData do

      if teamNumber == 2 then

        for i = 1, blanks do

          table.insert(newProgressDots, React.createElement(ProgressDot, {LayoutOrder = layoutOrder}));
          layoutOrder += 1;

        end;

      end;

      for _, data in ipairs(teamDots) do

        table.insert(newProgressDots, React.createElement(ProgressDot, {LayoutOrder = layoutOrder; teamColor = if teamNumber == 1 then Colors.DemoDemonsOrange else Colors.DemoDemonsRed; progress = data}))
        layoutOrder += 1;

      end;

    end;

    return newProgressDots;

  end;

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0);
    AutomaticSize = Enum.AutomaticSize.XY;
    Position = UDim2.new(0.5, 0, 0, 15);
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement(HorizontalUIListLayout);
    Team1Destruction = React.createElement(TeamDot, {teamNumber = 1});
    ProgressBar = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      LayoutOrder = 2;
    }, {
      UIListLayout = React.createElement(HorizontalUIListLayout);
      ProgressDotList = React.createElement(React.Fragment, {}, getProgressDots());
    });
    Team2Destruction = React.createElement(TeamDot, {teamNumber = 2});
  });

end;

return DestructionBar;