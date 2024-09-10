--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Colors = require(ReplicatedStorage.Client.Colors);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type RoundTimerProps = {
  round: ClientRound;
}

local function RoundTimer(props: RoundTimerProps)

  local secondsLeft, setSecondsLeft = React.useState(nil);
  local didRoundStop, setDidRoundStop = React.useState(false);

  React.useEffect(function()

    task.spawn(function()

      local function check()

        local roundDuration = props.round.duration;
        local roundStartTime = props.round.timeStarted;
        print(props.round);
        if props.round.status == "Active" and roundDuration and roundStartTime then

          setSecondsLeft(math.floor((roundStartTime + roundDuration * 1000 - DateTime.now().UnixTimestampMillis) / 1000) :: any)

        end;

      end;

      props.round.onStarted:Connect(check);

      props.round.onStopped:Connect(function()
      
        setDidRoundStop(true);

      end);

      check();

    end);

  end, {props.round});

  React.useEffect(function()

    task.delay(1, function()
    
      if secondsLeft and secondsLeft > 0 and not didRoundStop then

        setSecondsLeft(secondsLeft - 1);
  
      end;

    end);

  end, {secondsLeft});

  local time = "-:--";
  if secondsLeft then

    local seconds = secondsLeft % 60;
    if seconds < 10 then

      seconds = `0{seconds}`;

    end;
    local minutes = (secondsLeft - tonumber(seconds) or 0) / 60;
    time = `{minutes}:{seconds}`;

  end;

  local shouldUseMaximumSize = useResponsiveDesign({minimumWidth = 700});

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new(0, 0, 0);
    BackgroundTransparency = 0.2;
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    AnchorPoint = Vector2.new(1, 0);
    Position = UDim2.new(1, -15, 0, 15);
    BorderSizePixel = 0;
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingBottom = UDim.new(0, if shouldUseMaximumSize then 5 else 1);
      PaddingLeft = UDim.new(0, if shouldUseMaximumSize then 10 else 5);
      PaddingRight = UDim.new(0, if shouldUseMaximumSize then 10 else 5);
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MinSize = Vector2.new(if shouldUseMaximumSize then 63 else 18, 0);
    });
    UIListLayout = React.createElement("UIListLayout", {
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      VerticalAlignment = Enum.VerticalAlignment.Center;
    });
    CurrentTime = React.createElement("TextLabel", {
      Text = time;
      FontFace = Font.fromId(12187371840);
      BackgroundTransparency = 1;
      TextSize = if shouldUseMaximumSize then 30 else 8;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      TextColor3 = if secondsLeft and secondsLeft <= 60 then Colors.DemoDemonsRed else Color3.new(1, 1, 1);
    });
  });

end;

return RoundTimer;