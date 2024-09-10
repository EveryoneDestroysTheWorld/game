--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local React = require(ReplicatedStorage.Shared.Packages.react);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

local function MatchInitializationTimer()

  local currentSecond: number?, setCurrentSecond = React.useState(nil :: number?);
  local animatedSecond: number?, setAnimatedSecond = React.useState(nil :: number?);

  local shouldUseMaximumSize = useResponsiveDesign({minimumHeight = 500});

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

  React.useEffect(function(): ()

    if currentSecond then
    
      if currentSecond >= 0 then

        local changed = false;
        local tween = dataTypeTween({
          type = "Number";
          goalValue = 1;
          tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
          onChange = function(newValue)

            if not changed then

              changed = true;
              setAnimatedSecond(currentSecond);
  
            end;
  
            setTextState({
              rotation = -360 + 360 * newValue;
              textSize = (if shouldUseMaximumSize then 50 else 10) * newValue;
              textTransparency = 1 - newValue;
            });

          end;
        });

        tween:Play();

        local delayTask = task.delay(1, function()

          if currentSecond > 0 then

            setCurrentSecond(function(currentSecond) return if currentSecond then currentSecond - 1 else nil end);

          else

            setCurrentSecond(nil);

          end;

        end);

        return function()

          if coroutine.status(delayTask) == "suspended" then

            task.cancel(delayTask);

          end;

          tween:Cancel();

        end;

      end;

    end;

  end, {currentSecond});

  React.useEffect(function()
  
    if not currentSecond and textState.textTransparency == 0 then

      dataTypeTween({
        type = "Number";
        goalValue = 1;
        tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine);
        onChange = function(newValue)

          setTextState(function(textState) 
            return {
              rotation = textState.rotation;
              textSize = textState.textSize;
              textTransparency = newValue;
            } 
          end);

        end;
      }):Play();

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
      Size = UDim2.new(0, if shouldUseMaximumSize then 50 else 10, 0, if shouldUseMaximumSize then 50 else 10);
    });
  }) else nil;

end;

return MatchInitializationTimer;