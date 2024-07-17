--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local Colors = require(ReplicatedStorage.Client.Colors);
local React = require(ReplicatedStorage.Shared.Packages.react);
local TickerMessageTextLabel = require(script.Parent.TickerMessageTextLabel);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type TickerProps = {
  round: ClientRound;
}

local function Ticker(props: TickerProps)

  -- Create the messages on the ticker.
  local messages = {
    "This is DemoDemons.",
    "We're waiting on some folks. Sit tight, this won't take long.",
    "Don't underestimate Enemy Fighter. They might be up to some tricks!",
    "There's more to what meets the eye with Enemy Supporter.",
    "You won't know what archetype your rivals are until the game starts. Don't worry though — your secret is also safe with us."
  };

  local messageTextLabels = {};
  for i = 1, 2 do
    
    for messageIndex, messageText in ipairs(messages) do

      table.insert(messageTextLabels, React.createElement(TickerMessageTextLabel, {
        layoutOrder = messageIndex + (5 * (i - 1));
        text = messageText;
      }));

    end
    
  end

  -- Keep these variables in mind so that the ticker can be infinitely reset.
  local scrollingFrameRef = React.useRef(nil);

  -- Scroll the ticker.
  local uiListLayoutPaddingOffset = 25;
  local canvasPosition: Vector2, setCanvasPosition = React.useState(Vector2.new());
  local absoluteWindowSizeX, setAbsoluteWindowSizeX = React.useState(0);

  React.useEffect(function()
  
    if scrollingFrameRef.current then

      -- Reset the position back to the beginning so the ticker seems infinite.
      game:GetService("RunService").Heartbeat:Wait();
      setAbsoluteWindowSizeX(scrollingFrameRef.current.AbsoluteWindowSize.X);
      if canvasPosition.X >= (absoluteWindowSizeX + scrollingFrameRef.current.AbsoluteCanvasSize.X + uiListLayoutPaddingOffset) / 2 then
        
        setCanvasPosition(Vector2.new(absoluteWindowSizeX, 0));
        
      else 
        
        setCanvasPosition(Vector2.new(canvasPosition.X + 1, 0));

      end;

    end;

  end, {canvasPosition});

  local positionYOffset, setPositionYOffset = React.useState(0);
  React.useEffect(function(): ()
  
    if props.round then

      local function tweenOut()

        local numberValue = Instance.new("NumberValue");
        numberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
          setPositionYOffset(numberValue.Value);
          
        end);
        TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Value = 50}):Play();

      end;

      local function checkRoundStatus()

        if props.round.status == "Contestant selection" then

          tweenOut();

        end;

      end;
      
      local event = props.round.onStatusChanged:Connect(checkRoundStatus);
      checkRoundStatus();

      return function()

        event:Disconnect();
  
      end;

    end;
    
  end, {props.round});

  return if positionYOffset == 50 then nil else React.createElement("ScrollingFrame", {
    ref = scrollingFrameRef;
    BackgroundColor3 = Colors.PopupBackground;
    BackgroundTransparency = 0.15;
    BorderSizePixel = 0.15;
    Size = UDim2.new(1, 0, 0, 50);
    Position = UDim2.new(0, 0, 1, positionYOffset);
    AnchorPoint = Vector2.new(0, 1);
    ScrollBarThickness = 0;
    ScrollingEnabled = false;
    ScrollingDirection = Enum.ScrollingDirection.X;
    CanvasPosition = canvasPosition;
    CanvasSize = UDim2.new(0, 0, 0, 0);
    AutomaticCanvasSize = Enum.AutomaticSize.X;
  }, {
    React.createElement("UIListLayout", {
      Padding = UDim.new(0, uiListLayoutPaddingOffset);
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalAlignment = Enum.VerticalAlignment.Center;
      FillDirection = Enum.FillDirection.Horizontal;
    });
    React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, absoluteWindowSizeX);
    });
    React.createElement(React.Fragment, {}, messageTextLabels); 
  });

end;

return Ticker;