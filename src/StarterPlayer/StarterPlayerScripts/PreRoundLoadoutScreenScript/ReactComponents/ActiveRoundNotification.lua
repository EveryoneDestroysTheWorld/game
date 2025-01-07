--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");

local function ActiveRoundNotification()

  local textLabelRef = React.useRef(nil :: TextLabel?);
  local uiScaleRef = React.useRef(nil :: UIScale?);

  React.useEffect(function()
  
    local textLabel = textLabelRef.current;
    if textLabel then

      textLabel.Position = UDim2.new(0.5, 0, 0.5, 30);
      TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, 0, 0.5, 0);
        TextTransparency = 0.7;
      }):Play();

      local uiScale = uiScaleRef.current;
      if uiScale then

        task.delay(2, function()
        
          TweenService:Create(textLabel, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
            TextTransparency = 1;
          }):Play();

          TweenService:Create(uiScale, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
            Scale = 2
          }):Play();

        end);

      end;

    end;

  end, {});

  return React.createElement("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    BackgroundTransparency = 1;
    TextTransparency = 1;
    Size = UDim2.new(0, 350, 0, 82);
    ref = textLabelRef;
    TextColor3 = Color3.new(1, 1, 1);
    Position = UDim2.new(0.5, 0, 0.5, 0);
    TextSize = 41;
    FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
    Text = "DESTROY THE WORLD";
    TextWrapped = true;
  }, {
    UIScale = React.createElement("UIScale", {
      ref = uiScaleRef;
    })
  });

end;

return ActiveRoundNotification;