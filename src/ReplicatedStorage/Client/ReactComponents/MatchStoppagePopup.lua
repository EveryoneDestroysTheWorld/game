--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);
local Button = require(script.Parent.Button);
local TweenService = game:GetService("TweenService");

local function CheckeredBackgroundImageLabel(props: {LayoutOrder: number})

  local currentHeightOffset, setCurrentHeightOffset = React.useState(0);
  local sizeOffset, setSizeOffset = React.useState(100);

  React.useEffect(function()

    local processing = true;
  
    task.spawn(function()
    
      while processing and task.wait() do
      
        setSizeOffset(function(sizeOffset) return sizeOffset + if props.LayoutOrder == 1 then 1 else -1 end);
  
      end;

    end);

    return function()

      processing = false;

    end;

  end, {});

  React.useEffect(function()
  
    local numberValue = Instance.new("NumberValue");
    numberValue:GetPropertyChangedSignal("Value"):Connect(function()
      
      setCurrentHeightOffset(numberValue.Value);

    end);
    
    local goalHeightOffset = 25;
    local tween = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = goalHeightOffset});
    tween:Play();

  end, {});

  return React.createElement("ImageLabel", {
    Image = "rbxassetid://15562720000";
    ImageColor3 = Colors.DemoDemonsRed;
    Size = UDim2.new(1, sizeOffset, 0, currentHeightOffset);
    LayoutOrder = props.LayoutOrder;
    BackgroundTransparency = 1;
    ScaleType = Enum.ScaleType.Tile;
    TileSize = UDim2.new(0, 28, 0, 28);
  }, {
    UIGradient = React.createElement("UIGradient", {
      Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1, 0);
        NumberSequenceKeypoint.new(0.5, 0, 0);
        NumberSequenceKeypoint.new(1, 1, 0);
      })
    });
  });

end;

local function MatchStoppagePopup()

  local contentFrameSizeScale, setContentFrameSizeScale = React.useState(0); -- Transition to 1 after offset = 150.
  local contentFrameSizeOffset, setContentFrameSizeOffset = React.useState(0); -- Transition to 150.

  React.useEffect(function()

    local numberValue = Instance.new("NumberValue");
    numberValue:GetPropertyChangedSignal("Value"):Connect(function()
      
      setContentFrameSizeOffset(numberValue.Value);

    end);
    
    local goalContentFrameSizeOffset = 150;
    local tween = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Value = goalContentFrameSizeOffset});
    tween.Completed:Connect(function()
    
      task.delay(1.5, function()

        local scaleNumberValue = Instance.new("NumberValue");
        scaleNumberValue:GetPropertyChangedSignal("Value"):Connect(function()
          
          setContentFrameSizeScale(scaleNumberValue.Value);
    
        end);
        tween = TweenService:Create(scaleNumberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 1});
        tween.Completed:Connect(function()
        
        end);
        tween:Play();
        TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 0}):Play();

      end)

    end);
    tween:Play();
      
  end, {});

  local transparency, setTransparency = React.useState(1);
  React.useEffect(function()

    if contentFrameSizeScale == 1 then

      local numberValue = Instance.new("NumberValue");
      numberValue.Value = transparency;
      numberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
        setTransparency(numberValue.Value);

      end);
      
      local goalTransparency = 0;
      TweenService:Create(numberValue, TweenInfo.new(0.5), {Value = goalTransparency}):Play();

    end;
      
  end, {contentFrameSizeScale});

  return React.createElement(React.Fragment, {}, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalAlignment = Enum.VerticalAlignment.Center;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });
    CheckeredBackgroundImageLabelTop = if contentFrameSizeScale ~= 1 then React.createElement(CheckeredBackgroundImageLabel, {LayoutOrder = 1}) else nil;
    ContentFrame = React.createElement("Frame", {
      BackgroundColor3 = Color3.new();
      BorderSizePixel = 0;
      ClipsDescendants = true;
      LayoutOrder = 2;
      Size = UDim2.new(1, 0, contentFrameSizeScale, contentFrameSizeOffset);
    }, {
      TitleLabel = React.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Text = "MATCH STOPPED";
        TextSize = 71;
        Position = UDim2.new(0.5, 0, 0.5, 0);
        TextColor3 = Colors.DemoDemonsRed;
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
      });
      MessageLabel = React.createElement("TextLabel", {
        Text = `Nice job, you broke the game. No points for it though.\nOn the bright side, this match has been marked as "no contest" so it isn't a loss.`;
        TextSize = 17;
        LineHeight = 1.25;
        TextWrapped = true;
        TextColor3 = Colors.ParagraphText;
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.Y;
        Size = UDim2.new(0.7, 0, 0, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 60);
        TextTransparency = transparency;
        Visible = contentFrameSizeScale == 1;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Medium);
      });
      Button = React.createElement(Button, {
        AnchorPoint = Vector2.new(0.5, 1);
        Position = UDim2.new(0.5, 0, 1, -30);
        text = "RETURN TO LOBBY";
        BackgroundTransparency = transparency;
        TextTransparency = transparency;
        Visible = contentFrameSizeScale == 1;
        onClick = function()

        end;
      });
    });
    CheckeredBackgroundImageLabelBottom = if contentFrameSizeScale ~= 1 then React.createElement(CheckeredBackgroundImageLabel, {LayoutOrder = 3}) else nil;
  });

end;

return MatchStoppagePopup;