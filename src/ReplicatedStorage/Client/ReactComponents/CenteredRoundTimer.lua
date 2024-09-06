--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type CenteredRoundTimerProps = {
  round: ClientRound;
}

local function CenteredRoundTimer(props: CenteredRoundTimerProps)

  local currentSecond: number?, setCurrentSecond = React.useState(nil :: number?);
  local animatedSecond: number?, setAnimatedSecond = React.useState(nil :: number?);
  local remainingDuration: number?, setRemainingDuration = React.useState(nil :: number?);
  local isFinalCountdown: boolean, setIsFinalCountdown = React.useState(false);
  local didRoundStop, setDidRoundStop = React.useState(false);

  React.useEffect(function()

    task.spawn(function()

      props.round.onStatusChanged:Connect(function()
      
        if props.round.status == "Pre-round countdown" then

          setCurrentSecond(3);

        end;

      end);

      props.round.onStarted:Connect(function()

        setRemainingDuration(props.round.duration);

      end);

      props.round.onStopped:Connect(function()
      
        setDidRoundStop(true);

      end);

    end);

  end, {props.round});

  React.useEffect(function()
  
    if remainingDuration and not didRoundStop then

      if remainingDuration > 6 then

        task.delay(1, function()
        
          setRemainingDuration(remainingDuration - 1);

        end);

      elseif remainingDuration == 6 then

        setCurrentSecond(remainingDuration - 1);
        setIsFinalCountdown(true);

      end;

    end;

  end, {remainingDuration});

  local textState, setTextState = React.useState({
    rotation = -360;
    textSize = 0;
    transparency = 1;
  });

  React.useEffect(function(): ()

    if currentSecond and not didRoundStop then
    
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
              textSize = 100 * newValue;
              transparency = (1 - newValue) * 0.7;
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
  
    if not currentSecond and textState.transparency == 0 then

      dataTypeTween({
        type = "Number";
        goalValue = 1;
        tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine);
        onChange = function(newValue)

          setTextState(function(textState) 
            return {
              rotation = textState.rotation;
              textSize = textState.textSize;
              transparency = newValue;
            } 
          end);

        end;
      }):Play();

    end;

  end, {currentSecond, textState :: any});

  local messages = {
    "GO! DO A CRIME";
    "DO THE THING";
    "CAUSE A HAPPY ACCIDENT"
  }

  local message = React.useState(messages[math.random(1, #messages)]);

  return if animatedSecond and (animatedSecond > 0 or not isFinalCountdown) then React.createElement("TextLabel", {
    Text = if animatedSecond == 0 then message else animatedSecond;
    AnchorPoint = Vector2.new(0.5, 0.5);
    Position = UDim2.new(0.5, 0, 0.5, 0);
    FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Bold);
    BackgroundTransparency = 1;
    TextTransparency = 1;
    Rotation = textState.rotation;
    TextSize = textState.textSize;
    AutomaticSize = Enum.AutomaticSize.XY;
  }, {
    UIStroke = React.createElement("UIStroke", {
      Color = Color3.new(1, 1, 1);
      Thickness = 1;
      Transparency = textState.transparency;
    });
  }) else nil;

end;

return CenteredRoundTimer;