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

      ReplicatedStorage.Shared.Events.ArchetypeSelectionsFinalized.OnClientEvent:Connect(function()
      
        setCurrentSecond(5);

      end);

      setCurrentSecond(ReplicatedStorage.Shared.Functions.GetPreRoundTimeLimit:InvokeServer());

    end);

  end, {});

  local textState, setTextState = React.useState({
    rotation = -360;
    textSize = 0;
    textTransparency = 1;
  });

  React.useEffect(function()

    local delayTask;

    if currentSecond then
    
      if currentSecond >= 0 then

        local changed = false;
        local numberValue = Instance.new("NumberValue");
        numberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
          task.wait();
          if not changed then

            changed = true;
            setAnimatedSecond(currentSecond);

          end;

          setTextState({
            rotation = -360 + numberValue.Value * 360;
            textSize = 50 * numberValue.Value;
            textTransparency = 1 - numberValue.Value;
          });

        end);
        TweenService:Create(numberValue, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 1}):Play();

        delayTask = task.delay(1, function()

          if currentSecond > 0 then

            setCurrentSecond(function(currentSecond) return if currentSecond then currentSecond - 1 else nil end);

          else

            setCurrentSecond(nil);

          end;

        end);

      end;

    end;

    return function()

      if delayTask then

        task.cancel(delayTask);

      end;

    end;

  end, {currentSecond});

  React.useEffect(function()
  
    if not currentSecond and textState.textTransparency == 0 then

      local targetTextTransparencyNumberValue = Instance.new("NumberValue");
      targetTextTransparencyNumberValue.Value = 0;
      targetTextTransparencyNumberValue:GetPropertyChangedSignal("Value"):Connect(function()
      
        task.wait();
        setTextState(function(textState) 
          return {
            rotation = textState.rotation;
            textSize = textState.textSize;
            textTransparency = targetTextTransparencyNumberValue.Value;
          } 
        end);

      end);
      
      TweenService:Create(targetTextTransparencyNumberValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Value = 1}):Play();

    end;

  end, {currentSecond, textState :: any});

  return if animatedSecond then React.createElement("Frame", {
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
      TextTransparency = textState.textTransparency;
      Rotation = textState.rotation;
      TextSize = textState.textSize;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new(0, 50, 0, 50);
    });
  }) else nil;

end;

return MatchInitializationTimer;