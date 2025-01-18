--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");

type ComboNotificationProperties = {
  event: RemoteEvent;
}

local function ComboNotification(props: ComboNotificationProperties)

  local comboText, setComboText = React.useState(nil :: ("Nice" | "Good" | "Great!" | "Cool!!" | "Excellent!!!")?);
  local randomNumber, setRandomNumber = React.useState(nil :: number?);
  local transparencyTask, setTransparencyTask = React.useState(nil :: thread?);

  React.useEffect(function()
  
    local connection = props.event.OnClientEvent:Connect(function(eventType: string, newComboCount: number)
    
      if eventType == "Combo" then

        setComboText(if newComboCount >= 10 then "Excellent!!!" elseif newComboCount >= 7 then "Cool!!" elseif newComboCount >= 5 then "Great!" elseif newComboCount >= 3 then "Good" else "Nice");
        setRandomNumber(math.random())

      end

    end);

    return function()

      connection:Disconnect();

    end;

  end, {props.event});

  local ref = React.useRef(nil :: TextLabel?);
  React.useEffect(function()
  
    if ref.current then

      if transparencyTask then

        task.cancel(transparencyTask);

      end;

      ref.current.TextTransparency = 0;
      ref.current.Position = UDim2.new(1, ref.current.AbsoluteSize.X, 0, 30);

      TweenService:Create(ref.current, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -30, 0, 30);
      }):Play();

      setTransparencyTask(task.delay(3, function()
      
        TweenService:Create(ref.current, TweenInfo.new(), {
          TextTransparency = 1;
        }):Play();

      end));

    end;

  end, {comboText :: unknown, randomNumber});

  if comboText then

    return React.createElement("TextLabel", {
      AnchorPoint = Vector2.new(1, 0);
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = comboText;
      TextColor3 = Color3.new(1, 1, 1);
      Rotation = -5;
      BackgroundTransparency = 1;
      TextSize = 30;
      ref = ref;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    })

  end;

end;

return ComboNotification;