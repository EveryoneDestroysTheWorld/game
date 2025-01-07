--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");

local function WaitingMessage(props: {onTransitionEnd: () -> ()})

  local circleRef = React.useRef(nil :: Frame?);
  React.useEffect(function()

    local circle = circleRef.current;
    if circle then

      task.delay(5, function()
      
        local viewportSize = workspace.CurrentCamera.ViewportSize;
        local newSize = math.max(viewportSize.X, viewportSize.Y) * 1.25;

        local tween = TweenService:Create(circle, TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
          Size = UDim2.new(0, newSize, 0, newSize);
        });

        tween.Completed:Once(function()
        
          props.onTransitionEnd();

        end);

        tween:Play();
      
      end);

    end;

  end, {});

  return React.createElement("Frame", {
    Size = UDim2.new();
    AnchorPoint = Vector2.new(0.5, 0.5);
    Position = UDim2.new(0.5, 0, 0.5, 0);
    BackgroundColor3 = Color3.new(1, 1, 1);
    BorderSizePixel = 0;
    ref = circleRef;
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
  });

end;

return WaitingMessage;