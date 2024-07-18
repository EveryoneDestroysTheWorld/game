--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);

local function DestructionBar()

  -- Animate the stat bar.
  local containerRef = React.useRef(nil :: Frame?)
  local team1DestructionRef = React.useRef(nil :: Frame?);
  local team2DestructionRef = React.useRef(nil :: Frame?);
  React.useEffect(function()
  
    local container = containerRef.current;
    local team1Destruction = team1DestructionRef.current;
    local team2Destruction = team2DestructionRef.current;
    if container and team1Destruction and team2Destruction then

      container.Size = UDim2.new(0, 0, 0, 25);
      team1Destruction.Size = UDim2.new(0, 0, 1, 0);
      team2Destruction.Size = UDim2.new(0, 0, 1, 0);

      dataTypeTween({
        type = "Number";
        goalValue = 500;
        onChange = function(newValue: number)

          container.Size = UDim2.new(container.Size.X.Scale, newValue, container.Size.Y.Scale, container.Size.Y.Offset);

        end;
      }):Play();

    end;

  end, {});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0);
    Position = UDim2.new(0.5, 0, 0, 22);
    BackgroundColor3 = Color3.new(1, 1, 1);
    BorderSizePixel = 0;
    BackgroundTransparency = 0.55;
    ref = containerRef;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
    });
    Team1Destruction = React.createElement("Frame", {
      BackgroundColor3 = Colors.DemoDemonsOrange;
      LayoutOrder = 1;
      BackgroundTransparency = 0.5;
      BorderSizePixel = 0;
      ref = team1DestructionRef;
    });
    Team2Destruction = React.createElement("Frame", {
      BackgroundColor3 = Colors.DemoDemonsRed;
      LayoutOrder = 1;
      BackgroundTransparency = 0.5;
      BorderSizePixel = 0;
      ref = team2DestructionRef;
    });
  });

end;

return DestructionBar;