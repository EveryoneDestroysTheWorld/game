--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

local function CircleCorner()

  return React.createElement("UICorner", {
    CornerRadius = UDim.new(1, 0);
  });

end;

local function CircleFilling()

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new(1, 1, 1);
    AnchorPoint = Vector2.new(0.5, 0.5);
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0, 5, 0, 5);
    BorderSizePixel = 0;
  }, {
    UICorner = React.createElement(CircleCorner);
  });

end;

local function HorizontalUIListLayout()

  return React.createElement("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder;
    FillDirection = Enum.FillDirection.Horizontal;
    Name = "UIListLayout";
    Padding = UDim.new(0, 5);
    VerticalAlignment = Enum.VerticalAlignment.Center;
    HorizontalAlignment = Enum.HorizontalAlignment.Center;
  });

end;

type ProgressDotProps = {
  teamColor: Color3?;
  progress: number?;
  LayoutOrder: number;
}

local function ProgressDot(props: ProgressDotProps)

  local color, setColor = React.useState(Color3.new(1, 1, 1));

  React.useEffect(function()
  
    if props.teamColor and props.progress then

      local hue, saturation, value = props.teamColor:ToHSV();
      local newColor = Color3.fromHSV(hue, saturation * props.progress, value);
      setColor(newColor);

    else

      setColor(Color3.new(1, 1, 1));
      
    end;

  end, {props.teamColor, props.progress :: any});

  return React.createElement("Frame", {
    BorderSizePixel = 0;
    LayoutOrder = props.LayoutOrder;
    BackgroundColor3 = color;
    BackgroundTransparency = if props.progress then props.progress * 0.2 else 0.7;
    Size = UDim2.new(0, 3, 0, 3);
  }, {
    CircleCorner = React.createElement(CircleCorner);
  });

end;

local function TeamDot(props: {teamNumber: number})

  return React.createElement("Frame", {
    BackgroundColor3 = if props.teamNumber == 1 then Colors.DemoDemonsOrange else Colors.DemoDemonsRed;
    BackgroundTransparency = 0.2;
    Size = UDim2.new(0, 10, 0, 10);
    BorderSizePixel = 0;
    LayoutOrder = props.teamNumber + (props.teamNumber - 1);
  }, {
    UICorner = React.createElement(CircleCorner);
    CircleFilling = React.createElement(CircleFilling);
  });

end;

type DestructionBarProps = {
  round: ClientRound;
}

local function DestructionBar(props: DestructionBarProps)

  -- Animate the stat bar.
  local progressDots, setProgressDots = React.useState({});
  React.useEffect(function(): ()
    
    local function updateBar(gameModeStats: any)

      task.spawn(function()
      
        local gameModeStats = ReplicatedStorage.Shared.Functions.GetGameModeStats:InvokeServer();
        
        local teamClaimedParts = {0, 0};
        for contestantID, contestantStats in pairs(gameModeStats.contestants) do

          for _, contestant in ipairs(props.round.contestants) do

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
        for teamNumber = 1, 2 do

          local newDots = {};
          local percentage = 41 * teamClaimedParts[teamNumber] / gameModeStats.totalStageParts;
          local flooredPercentage = math.floor(percentage);
          local progressRemainder = percentage - flooredPercentage;
          
          if teamNumber == 2 then

            for progressDotIndex = 1, 41 - #teamDotData[1] - flooredPercentage - (if progressRemainder > 0 then 1 else 0) do

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
        for teamNumber, teamDots in ipairs(teamDotData) do

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

        setProgressDots(newProgressDots);

      end);

    end;
    
    local updateEvent = ReplicatedStorage.Shared.Events.GameModeStatsUpdated.OnClientEvent:Connect(updateBar)
    updateBar();

    return function()

      updateEvent:Disconnect();

    end;

  end, {props.round});

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
      React.createElement(HorizontalUIListLayout);
      progressDots;
    });
    Team2Destruction = React.createElement(TeamDot, {teamNumber = 2});
  });

end;

return DestructionBar;