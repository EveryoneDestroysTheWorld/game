--!strict
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type LoadingBackgroundProps = {
  round: ClientRound;
}

local function LoadingBackground(props: LoadingBackgroundProps)

  local isVisible, setIsVisible = React.useState(false);
  local sizeYScale, setSizeYScale = React.useState(0);
  local anchorPointY, setAnchorPointY = React.useState(0);
  local positionYScale, setPositionYScale = React.useState(0);
  React.useEffect(function()
  
    props.round.onStatusChanged:Connect(function()
    
      if props.round.status == "Matchup preview" then

        setIsVisible(true);
        task.delay(5.6, function()
        
          dataTypeTween({
            type = "Number";
            goalValue = 1;
            tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
            onChange = function(newValue)

              setSizeYScale(newValue);

            end;
          }):Play();

        end);

      end;

    end);

    local characterAddedEvent = Players.LocalPlayer.CharacterAdded:Connect(function()
    
      setAnchorPointY(1);
      setPositionYScale(1);
      dataTypeTween({
        type = "Number";
        goalValue = 0;
        initialValue = 1;
        tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
        onChange = function(newValue)

          setSizeYScale(newValue)

        end;
      }):Play();

    end);

    return function()

      characterAddedEvent:Disconnect();

    end;

  end, {props.round});

  return if isVisible then React.createElement("Frame", {
    AnchorPoint = Vector2.new(0, anchorPointY);
    BackgroundColor3 = Color3.new(0, 0, 0);
    Size = UDim2.new(1, 0, sizeYScale, 0);
    Position = UDim2.new(0, 0, positionYScale, 0);
  }) else nil; 

end;

return LoadingBackground;