--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

local React = require(ReplicatedStorage.Shared.Packages.react);

export type KeybindNotificationProperties = {
  message: string;
  onClose: () -> ();
}

local function KeybindNotification(properties: KeybindNotificationProperties)

  local textLabelRef = React.useRef(nil :: TextLabel?);
  
  React.useEffect(function()

    if textLabelRef.current then

      textLabelRef.current.TextTransparency = 0;

    end;
  
    local tween;
    local tweenEvent;
    local transparencyThread = task.delay(2, function()

      if textLabelRef then

        tween = TweenService:Create(textLabelRef.current, TweenInfo.new(), {
          TextTransparency = 1;
        });

        tweenEvent = tween.Completed:Once(function()
        
          properties.onClose();

        end);

        tween:Play();

      end;
    
    end);

    return function()

      task.cancel(transparencyThread);

      if tween then

        tween:Cancel();

      end;

      if tweenEvent then

        tweenEvent:Disconnect();

      end;

    end;

  end, {properties.message :: unknown, properties.onClose});

  return React.createElement("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1);
    Position = UDim2.new(0.5, 0, 1, -120);
    Size = UDim2.new();
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    TextColor3 = Color3.new(1, 1, 1);
    FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    TextSize = 16;
    Text = properties.message;
    ref = textLabelRef;
  });

end;

return KeybindNotification;