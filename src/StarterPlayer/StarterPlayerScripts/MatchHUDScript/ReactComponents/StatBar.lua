--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

type StatBarProps = {
  type: "Health" | "Stamina";
  contestant: ClientContestant;
}

local function StatBar(props: StatBarProps)

  local contestant = props.contestant;

  -- Animate the stat bar.
  local containerRef = React.useRef(nil :: Frame?);
  local textLabelRef = React.useRef(nil :: TextLabel?);
  local currentStatBarRef = React.useRef(nil :: Frame?);
  local isTweening, setIsTweening = React.useState(false);

  local isHealthBar = props.type == "Health";
  local shouldUseFullLength, shouldUseFullHeight = useResponsiveDesign({minimumWidth = 800}, {minimumHeight = 600});

  React.useEffect(function()
  
    local container = containerRef.current;
    if not isTweening and container then

      container.Size = UDim2.new(container.Size.X.Scale, if shouldUseFullLength then 200 else 70, container.Size.Y.Scale, container.Size.Y.Offset);

    end;

  end, {isTweening, shouldUseFullLength});

  React.useEffect(function(): ()
  
    local container = containerRef.current;
    local currentStatBar = currentStatBarRef.current;
    local textLabel = textLabelRef.current;
    if container and currentStatBar and textLabel then

      setIsTweening(true);
      textLabel.Transparency = 1;
      TweenService:Create(container, TweenInfo.new(), {
        Size = UDim2.new(container.Size.X.Scale, if shouldUseFullLength then 200 else 70, container.Size.Y.Scale, container.Size.Y.Offset)
      }):Play();

      local tween = TweenService:Create(currentStatBar, TweenInfo.new(2, Enum.EasingStyle.Sine), {
        Size = UDim2.new(1, currentStatBar.Size.X.Offset, 1, currentStatBar.Size.Y.Offset);
      });

      tween.Completed:Connect(function()
      
        setIsTweening(false);
        TweenService:Create(textLabel, TweenInfo.new(), {
          TextTransparency = 0;
        }):Play();
        
      end);

      tween:Play();

      local function updateBar()

        local current = contestant[`current{props.type}`] or 0;
        local base = contestant[`base{props.type}`] or 0;
        TweenService:Create(currentStatBar, TweenInfo.new(0.2), {
          Size = UDim2.new(math.min(current, 100) / base, 0, 1, 0)
        }):Play();

      end;
  
      local onHealthUpdated;
      local onStaminaUpdated;
      if props.type == "Health" then

        onHealthUpdated = contestant.onHealthUpdated:Connect(updateBar);

      else

        onStaminaUpdated = contestant.onStaminaUpdated:Connect(updateBar);

      end;

      return function()
  
        if onHealthUpdated then

          onHealthUpdated:Disconnect();

        else

          onStaminaUpdated:Disconnect();

        end;
  
      end;

    end;

  end, {props.type :: any, contestant});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    LayoutOrder = if isHealthBar then 1 else 2;
    ref = containerRef;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalAlignment = if isHealthBar then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Right;
      Padding = UDim.new(0, 5);
    });
    TextLabel = React.createElement("TextLabel", {
      Text = props.type:upper();
      Size = UDim2.new();
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
      TextSize = if shouldUseFullHeight then 14 else 8;
      TextColor3 = Color3.new(1, 1, 1);
      ref = textLabelRef;
      LayoutOrder = 1;
    });
    BaseStat = React.createElement("Frame", {
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderSizePixel = 0;
      AnchorPoint = Vector2.new(if isHealthBar then 1 else 0, 0);
      BackgroundTransparency = 0.7;
      Size = UDim2.new(1, 0, 0, if shouldUseFullHeight then 5 else 3);
      LayoutOrder = 2;
    }, {
      CurrentStat = React.createElement("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1);
        Position = UDim2.new(if isHealthBar then 1 else 0, 0, 0, 0);
        AnchorPoint = Vector2.new(if isHealthBar then 1 else 0, 0);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
        ref = currentStatBarRef;
      });
    });
  });

end;

return StatBar;