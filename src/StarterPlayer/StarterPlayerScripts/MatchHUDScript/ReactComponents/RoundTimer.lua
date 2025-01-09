--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Colors = require(ReplicatedStorage.Client.Colors);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);
local TextService = game:GetService("TextService");

type RoundTimerProps = {
  round: ClientRound;
}

local function RoundTimer(props: RoundTimerProps)

  local roundEndTimeMS, setRoundEndTimeMS = React.useState(nil :: number?);
  local didRoundStop, setDidRoundStop = React.useState(false);
  local totalMilliseconds, setTotalMilliseconds = React.useState(0);
  local largestCharacterSize, setLargestCharacterSize = React.useState(0);
  local shouldUseMaximumSize = useResponsiveDesign({minimumWidth = 700});
  local textSize = if shouldUseMaximumSize then 30 else 14;
  local font = Font.fromId(11702779517, Enum.FontWeight.SemiBold, Enum.FontStyle.Italic);

  React.useEffect(function()

    task.spawn(function()

      local function check()

        local roundDuration = props.round.duration;
        local roundStartTime = props.round.timeStarted;
        if props.round.status == "Active" and roundDuration and roundStartTime then

          setRoundEndTimeMS(roundStartTime + roundDuration * 1000);

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
    
    local largestNumberSize = 0;
    local params = Instance.new("GetTextBoundsParams");
    params.Size = textSize;
    params.Width = 0;
    params.Font = font;
    for number = 0, 9 do

      params.Text = `{number}`;
      largestNumberSize = math.max(TextService:GetTextBoundsAsync(params).X, largestNumberSize);

    end;
    setLargestCharacterSize(largestNumberSize);

  end, {shouldUseMaximumSize});

  React.useEffect(function()
  
    if not didRoundStop and roundEndTimeMS then

      task.wait();
      setTotalMilliseconds(math.max(roundEndTimeMS - DateTime.now().UnixTimestampMillis, 0));

    end;

  end, {totalMilliseconds :: unknown, roundEndTimeMS, didRoundStop});

  local timeString;
  if roundEndTimeMS then

    local totalSeconds = totalMilliseconds / 1000;
    local minutes = math.floor(totalSeconds / 60);
    local seconds = math.floor(totalSeconds % 60);
    local milliseconds = math.floor(totalMilliseconds % 1000);
    timeString = `{minutes}:{if seconds >= 10 then seconds else `0{seconds}`}.{if milliseconds >= 100 then milliseconds elseif milliseconds >= 10 then `0{milliseconds}` else `00{milliseconds}`}`;

    local timerParts = {};
    for index, character in timeString:split("") do

      local isNumber = not not tonumber(character);
      local part = React.createElement("TextLabel", {
        Text = character;
        FontFace = font;
        BackgroundTransparency = 1;
        LayoutOrder = index;
        TextSize = textSize;
        Size = UDim2.new(0, if isNumber then largestCharacterSize else 0, 0, 0);
        TextXAlignment = Enum.TextXAlignment.Center;
        AutomaticSize = if isNumber then Enum.AutomaticSize.Y else Enum.AutomaticSize.XY;
        TextColor3 = if totalSeconds <= 60 then Colors.DemoDemonsRed else Color3.new(1, 1, 1);
      });

      table.insert(timerParts, part);

    end;

    return React.createElement("Frame", {
      BackgroundTransparency = 1;
      AnchorPoint = Vector2.new(1, 0);
      AutomaticSize = Enum.AutomaticSize.XY;
      Position = UDim2.new(1, -15, 0, 15);
      Size = UDim2.new();
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Bottom;
      });
      Parts = React.createElement(React.Fragment, {}, timerParts);
    });

  end;

end;

return RoundTimer;