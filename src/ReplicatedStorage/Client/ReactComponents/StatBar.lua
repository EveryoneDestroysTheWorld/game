--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);

type StatBarProps = {
  type: "Health" | "Stamina";
}

local function StatBar(props: StatBarProps)

  -- Animate the stat bar.
  local containerRef = React.useRef(nil :: Frame?);
  local textLabelRef = React.useRef(nil :: TextLabel?);
  local currentStatBarRef = React.useRef(nil :: Frame?);
  React.useEffect(function()
  
    local container = containerRef.current;
    local currentStatBar = currentStatBarRef.current;
    local textLabel = textLabelRef.current;
    if container and currentStatBar and textLabel then

      textLabel.Transparency = 1;

      dataTypeTween({
        type = "Number";
        goalValue = 200;
        onChange = function(newValue: number)

          container.Size = UDim2.new(container.Size.X.Scale, newValue, container.Size.Y.Scale, container.Size.Y.Offset);

        end;
      }):Play();

      local tween = dataTypeTween({
        type = "Number";
        goalValue = 1;
        tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine);
        onChange = function(newValue: number)

          currentStatBar.Size = UDim2.new(newValue, currentStatBar.Size.X.Offset, 1, currentStatBar.Size.Y.Offset);

        end;
      });

      tween.Completed:Connect(function()
      
        dataTypeTween({
          type = "Number";
          initialValue = 1;
          goalValue = 0;
          onChange = function(newValue: number)
  
            textLabel.TextTransparency = newValue;
  
          end;
        }):Play();
        
      end);

      tween:Play();

    end;

  end, {});

  local isHealthBar = props.type == "Health";

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
      TextSize = 14;
      TextColor3 = Color3.new(1, 1, 1);
      ref = textLabelRef;
      LayoutOrder = 1;
    });
    BaseStat = React.createElement("Frame", {
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderSizePixel = 0;
      AnchorPoint = Vector2.new(if isHealthBar then 1 else 0, 0);
      BackgroundTransparency = 0.5;
      Size = UDim2.new(1, 0, 0, 5);
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