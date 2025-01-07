--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local WaitingMessage = require(script.Parent.WaitingMessage);
local TransitionCircle = require(script.Parent.TransitionCircle);
local RivalFrameContainer = require(script.Parent.RivalFrameContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
type RoundStatus = ClientRound.RoundStatus;

local function PreRoundLoadoutScreen()

  local shouldShowRivals, setShouldShowRivals = React.useState(false);
  local roundStatus: RoundStatus?, setRoundStatus = React.useState(nil :: RoundStatus?);
  local frameRef = React.useRef(nil :: Frame?);

  React.useEffect(function()
  
    local round = ClientRound.fromServerRound();
    round.onStatusChanged:Connect(function()
    
      setRoundStatus(round.status);

    end);
    setRoundStatus(round.status);

  end, {});

  React.useEffect(function()
  
    local frame = frameRef.current;
    if shouldShowRivals and frame then

      task.delay(2, function()
      
        local tween = TweenService:Create(frame, TweenInfo.new(), {
          BackgroundTransparency = 1;
        });

        tween.Completed:Once(function()
        
        end);

        tween:Play();

      end);

    end;

  end, {shouldShowRivals});

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundColor3 = if shouldShowRivals then Color3.new(1, 1, 1) else Color3.new(0, 0, 0);
    BorderSizePixel = 0;
    ref = frameRef;
  }, {
    RivalFrameContainer = if shouldShowRivals then
      React.createElement(RivalFrameContainer)
    else nil;
    WaitingMessage = if not shouldShowRivals then
      React.createElement(WaitingMessage)
    else nil;
    TransitionCircle = if not shouldShowRivals then
      React.createElement(TransitionCircle, {
        roundStatus = roundStatus;
        onTransitionEnd = function()
          setShouldShowRivals(true);
        end;
      })
    else nil
  });

end;

return PreRoundLoadoutScreen;