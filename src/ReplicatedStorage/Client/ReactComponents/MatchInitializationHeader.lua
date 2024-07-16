
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type MatchInitializationHeaderProps = {
  round: ClientRound;
}

local function MatchInitializationHeader(props: MatchInitializationHeaderProps)

  local anchorPointY, setAnchorPointY = React.useState(0);
  local textSizes, setTextSizes = React.useState({
    subtitle = 14;
    title = 30;
    tagline = 18;
  });
  React.useEffect(function()
  
    props.round.onStatusChanged:Connect(function()
    
      if props.round.status == "Matchup preview" then

        task.delay(5.25, function()
        
          local numberValue = Instance.new("NumberValue");
          numberValue:GetPropertyChangedSignal("Value"):Connect(function()
            
            task.wait();
            setAnchorPointY(numberValue.Value);

          end);
          
          local tween = TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Value = 0.5});
          tween.Completed:Connect(function()
          
            local n2 = Instance.new("NumberValue");
            n2:GetPropertyChangedSignal("Value"):Connect(function()
              
              task.wait();
              setTextSizes({
                subtitle = textSizes.subtitle + n2.Value * 6;
                title = textSizes.title + n2.Value * 30;
                tagline = textSizes.tagline + n2.Value * 6;
              });
  
            end);

            TweenService:Create(n2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 1}):Play();

          end);
          tween:Play();

        end);

      end;

    end);

  end, {props.round});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0, anchorPointY);
    AutomaticSize = Enum.AutomaticSize.Y;
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 0, 0);
    Position = UDim2.new(0, 0, anchorPointY, 0);
  }, {
    GameModeDescriptionFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      LayoutOrder = 1;
      Position = UDim2.new(0.5, 0, 0, 0);
      AnchorPoint = Vector2.new(0.5, 0);
      Size = UDim2.new();
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 5);
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      SubtitleLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
        Text = "YOU'RE IN A";
        LayoutOrder = 1;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
        TextColor3 = Color3.fromRGB(255, 255, 255);
        TextSize = textSizes.subtitle;
      });
      GameModeLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
        Text = "TURF WAR";
        LayoutOrder = 2;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
        TextColor3 = Color3.fromRGB(255, 94, 97);
        TextSize = textSizes.title;
      });
      TaglineLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
        LayoutOrder = 3;
        Text = "BREAK EVERYTHING BEFORE THEY DO!!";
        FontFace = Font.fromName("PressStart2P");
        TextColor3 = Color3.fromRGB(199, 199, 199);
        TextSize = textSizes.tagline;
      });
    });
  });

end;

return MatchInitializationHeader;