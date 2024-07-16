local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type LoadingBackgroundProps = {
  round: ClientRound;
}

local function LoadingBackground(props: LoadingBackgroundProps)

  local isVisible, setIsVisible = React.useState(false);
  local sizeYScale, setSizeYScale = React.useState(0);
  local positionYScale, setPositionYScale = React.useState(0);
  React.useEffect(function()
  
    props.round.onStatusChanged:Connect(function()
    
      if props.round.status == "Matchup preview" then

        setIsVisible(true);
        task.delay(5.6, function()
        
          local numberValue = Instance.new("NumberValue");
          numberValue:GetPropertyChangedSignal("Value"):Connect(function()
            
            task.wait();
            setSizeYScale(numberValue.Value)

          end);
          numberValue.Value = 0;
          
          TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 1}):Play();

        end);

      end;

    end);

    Players.LocalPlayer.CharacterAdded:Connect(function()
    
      local numberValue = Instance.new("NumberValue");
      numberValue:GetPropertyChangedSignal("Value"):Connect(function()
        
        task.wait();
        setPositionYScale(numberValue.Value)

      end);
      
      TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 1}):Play();

    end);

  end, {props.round});

  return if isVisible then React.createElement("Frame", {
    BackgroundColor3 = Color3.new(0, 0, 0);
    Size = UDim2.new(1, 0, sizeYScale, 0);
    Position = UDim2.new(0, 0, positionYScale, 0);
  }) else nil; 

end;

return LoadingBackground;