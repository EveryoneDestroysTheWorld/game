--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function MatchInitializationTimer()

  local originalTextSize = 50;
  local currentSecond, setCurrentSecond = React.useState(10);
  local textLabelRef = React.useRef(nil);

  React.useEffect(function()
  
    ReplicatedStorage.Shared.Events.ArchetypeSelectionEnabled.OnClientEvent:Connect(function(selectionTimeLimitSeconds: number)
    
      setCurrentSecond(selectionTimeLimitSeconds);

    end);

  end, {});

  React.useEffect(function()

    local self = textLabelRef.current;
  
    local delayTask;

    if currentSecond >= 0 and self then

      self.Rotation = -360;
      self.TextSize = 0;
      TweenService:Create(self, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Rotation = 0, TextSize = originalTextSize}):Play();

      if currentSecond > 0 then

        delayTask = task.delay(1, function()

          setCurrentSecond(currentSecond - 1);

        end);

      end;

    end;

    return function()

      if delayTask then

        task.cancel(delayTask)

      end;

    end;

  end, {currentSecond});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    AnchorPoint = Vector2.new(1, 0);
    Position = UDim2.new(1, 0, 0, 0);
  }, {
    CurrentSecondTextLabel = React.createElement("TextLabel", {
      Text = currentSecond;
      ref = textLabelRef;
      FontFace = Font.fromId(16658221428, Enum.FontWeight.Bold);
      BackgroundTransparency = 1;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new(0, 50, 0, 50);
      TextSize = originalTextSize;
    });
  });

end;

return MatchInitializationTimer;