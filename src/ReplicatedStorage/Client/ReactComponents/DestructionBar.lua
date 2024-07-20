--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);

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
    Size = UDim2.new(0, 20, 0, 20);
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

local function ProgressDot()

  return React.createElement("Frame", {
    BorderSizePixel = 0;
    BackgroundColor3 = Color3.new(1, 1, 1);
    BackgroundTransparency = 0.7;
    Size = UDim2.new(0, 7, 0, 7);
  }, {
    CircleCorner = React.createElement(CircleCorner);
  });

end;

local function TeamDot(props: {teamNumber: number})

  return React.createElement("Frame", {
    BackgroundColor3 = if props.teamNumber == 1 then Colors.DemoDemonsOrange else Colors.DemoDemonsRed;
    BackgroundTransparency = 0.2;
    Size = UDim2.new(0, 40, 0, 40);
    BorderSizePixel = 0;
    LayoutOrder = props.teamNumber + (props.teamNumber - 1);
  }, {
    UICorner = React.createElement(CircleCorner);
    CircleFilling = React.createElement(CircleFilling);
  });

end;

local function DestructionBar()

  -- Animate the stat bar.
  local progressDots, setProgressDots = React.useState({});
  React.useEffect(function()
  
    if #progressDots ~= 41 then

      local newProgressDots = table.clone(progressDots);
      table.insert(newProgressDots, React.createElement(ProgressDot));
      setProgressDots(newProgressDots);
      task.wait(0.025);

    end

  end, {progressDots});

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