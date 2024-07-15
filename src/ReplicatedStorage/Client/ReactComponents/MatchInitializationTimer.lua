--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function MatchInitializationTimer()

  local currentSecond: number?, setCurrentSecond = React.useState(nil :: number?);
  local animatedSecond: number?, setAnimatedSecond = React.useState(nil :: number?);

  React.useEffect(function()

    task.spawn(function()

      ReplicatedStorage.Shared.Events.ArchetypeSelectionsEnabled.OnClientEvent:Connect(function(selectionTimeLimitSeconds: number)
    
        setCurrentSecond(selectionTimeLimitSeconds);
  
      end);

      -- setCurrentSecond(ReplicatedStorage.Shared.Functions.GetPreRoundTimeLimit:InvokeServer());

    end);

  end, {});

  local rotation, setRotation = React.useState(-360);
  local textSize, setTextSize = React.useState(0);
  local textTransparency, setTextTransparency = React.useState(1);

  React.useEffect(function()

    local delayTask;

    if currentSecond then
    
      if currentSecond >= 0 then

        setRotation(-360);
        setTextSize(0);
        setTextTransparency(1);
        setAnimatedSecond(currentSecond)

        local targetRotationNumberValue = Instance.new("NumberValue");
        targetRotationNumberValue.Value = -360;
        targetRotationNumberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
          setRotation(targetRotationNumberValue.Value);

        end);
        TweenService:Create(targetRotationNumberValue, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 0}):Play();

        local targetTextSizeNumberValue = Instance.new("NumberValue");
        targetTextSizeNumberValue.Value = 0;
        targetTextSizeNumberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
          setTextSize(targetTextSizeNumberValue.Value);

        end);

        TweenService:Create(targetTextSizeNumberValue, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 50}):Play();

        local targetTextTransparencyNumberValue = Instance.new("NumberValue");
        targetTextTransparencyNumberValue.Value = 1;
        targetTextTransparencyNumberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
          setTextTransparency(targetTextTransparencyNumberValue.Value);

        end);
        
        TweenService:Create(targetTextTransparencyNumberValue, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 0}):Play();

        if currentSecond > 0 then

          delayTask = task.delay(1, function()

            setCurrentSecond(currentSecond - 1);

          end);

        end;

      end;

    end;

    return function()

      if delayTask then

        task.cancel(delayTask);

      end;

    end;

  end, {currentSecond});

  return if currentSecond and animatedSecond then React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    AnchorPoint = Vector2.new(1, 0);
    Position = UDim2.new(1, 0, 0, 0);
  }, {
    CurrentSecondTextLabel = React.createElement("TextLabel", {
      Text = animatedSecond;
      FontFace = Font.fromId(16658221428, Enum.FontWeight.Bold);
      BackgroundTransparency = 1;
      TextTransparency = textTransparency;
      Rotation = rotation;
      TextSize = textSize;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new(0, 50, 0, 50);
    });
  }) else nil;

end;

return MatchInitializationTimer;