--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");

local function WaitingMessage()

  local shouldShowWaitingMessage, setShouldShowWaitingMessage = React.useState(false);
  local waitingMessageRef = React.useRef(nil :: TextLabel?);
  React.useEffect(function()

    task.delay(3, function()
    
      setShouldShowWaitingMessage(true);

    end);

  end, {});

  React.useEffect(function()
  
    -- Verify that there is a waiting message.
    local waitingMessage = waitingMessageRef.current;
    if not waitingMessage then

      return;

    end;

    local tween = TweenService:Create(waitingMessage, TweenInfo.new(), {
      TextTransparency = if shouldShowWaitingMessage then 0 else 1;
    });

    tween:Play();

    return function()

      tween:Cancel();

    end;

  end, {shouldShowWaitingMessage});

  return React.createElement("TextLabel", {
    AnchorPoint = Vector2.new(1, 1);
    Position = UDim2.new(1, -30, 1, -30);
    FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold, Enum.FontStyle.Italic);
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    TextWrapped = true;
    TextSize = 14;
    TextColor3 = Color3.new(1, 1, 1);
    TextXAlignment = Enum.TextXAlignment.Right;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    Text = "We're waiting on a few people. Don't worry — I'm making this stage extra warm for you. :)";
    ref = waitingMessageRef;
    TextTransparency = 1;
  }, {
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(250, math.huge);
    })
  });

end;

return WaitingMessage;