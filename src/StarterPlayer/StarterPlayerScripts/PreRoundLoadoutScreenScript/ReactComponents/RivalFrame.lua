--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");

local function RivalFrame(props: {quadrant: "Q1" | "Q2" | "Q3" | "Q4"})

  local frameRef = React.useRef(nil :: Frame?);
  local uiScaleRef = React.useRef(nil :: UIScale?);
  local frameAnchorPoint = Vector2.new(if props.quadrant == "Q2" or props.quadrant == "Q3" then 0 else 1, if props.quadrant == "Q1" or props.quadrant == "Q2" then 0 else 1);
  local textAnchorPoint = Vector2.new(if props.quadrant == "Q1" or props.quadrant == "Q4" then 0 else 1, if props.quadrant == "Q3" or props.quadrant == "Q4" then 0 else 1);

  local shade = math.random(2, 33);

  React.useEffect(function()

    task.delay(if props.quadrant == "Q2" then 0 elseif props.quadrant == "Q1" then 0.3 elseif props.quadrant == "Q4" then 0.6 else 0.9, function()
    
      local frame = frameRef.current;
      local uiScale = uiScaleRef.current;
      if frame and uiScale then

        frame.Visible = true;
        task.delay(2, function()
        
          local goalScale = 2;

          TweenService:Create(frame, TweenInfo.new(2), {
            Position = UDim2.new(frame.Position.X.Scale + goalScale * frame.Size.X.Scale * (if frame.AnchorPoint.X == 0 then -1 else 1), 0, frame.Position.Y.Scale + goalScale * frame.Size.Y.Scale * (if frame.AnchorPoint.Y == 0 then -1 else 1), 0);
          }):Play();

          TweenService:Create(uiScale, TweenInfo.new(0.75), {
            Scale = goalScale;
          }):Play();

        end);

      end;

    end);

  end, {});

  return React.createElement("Frame", {
    AnchorPoint = frameAnchorPoint;
    Position = UDim2.new(frameAnchorPoint.X, 0, frameAnchorPoint.Y, 0);
    Size = UDim2.new(0.5, 0, 0.5, 0);
    BackgroundColor3 = Color3.fromRGB(shade, shade, shade);
    AutomaticSize = Enum.AutomaticSize.XY;
    BorderSizePixel = 0;
    ref = frameRef;
    SizeConstraint = Enum.SizeConstraint.RelativeYY;
    Visible = false;
  }, {
    UIScale = React.createElement("UIScale", {
      ref = uiScaleRef;
    });
    UsernameLabel = React.createElement("TextLabel", {
      AnchorPoint = textAnchorPoint;
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
      Text = "Username";
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
      TextSize = 14;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new();
      Position = UDim2.new(textAnchorPoint.X, if textAnchorPoint.X == 0 then 15 else -15, textAnchorPoint.Y, if textAnchorPoint.Y == 0 then 15 else -15);
    });
  });

end;

return RivalFrame;