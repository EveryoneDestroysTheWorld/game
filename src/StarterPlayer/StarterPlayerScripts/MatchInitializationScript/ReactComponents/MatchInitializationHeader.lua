--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Players = game:GetService("Players");
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
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
  local titleColor, setTitleColor = React.useState(Color3.fromRGB(255, 94, 97));
  local taglineColor, setTaglineColor = React.useState(Color3.fromRGB(199, 199, 199));
  local textTransparency, setTextTransparency = React.useState(0);
  React.useEffect(function()
  
    props.round.onStatusChanged:Connect(function()
    
      if props.round.status == "Matchup preview" then

        task.delay(5.25, function()
        
          local anchorPointTween = dataTypeTween({
            type = "Number";
            goalValue = 0.5;
            tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce);
            onChange = function(newValue)

              setAnchorPointY(newValue);

            end;
          });
          
          anchorPointTween.Completed:Connect(function()
          
            dataTypeTween({
              type = "Number";
              goalValue = 1;
              tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
              onChange = function(newValue)

                setTextSizes({
                  subtitle = textSizes.subtitle + 6 * newValue;
                  title = textSizes.title + 30 * newValue;
                  tagline = textSizes.tagline + 6 * newValue;
                });

              end;
            }):Play();

          end);
          
          anchorPointTween:Play();

        end);

      end;

    end);

    local characterAddedEvent = Players.LocalPlayer.CharacterAdded:Connect(function()
    
      dataTypeTween({
        type = "Color3",
        initialValue = titleColor;
        goalValue = Color3.new(1, 1, 1);
        onChange = function(newValue)

          setTitleColor(newValue);

        end;
      }):Play();

      dataTypeTween({
        type = "Color3",
        initialValue = taglineColor;
        goalValue = Color3.new(1, 1, 1);
        onChange = function(newValue)

          setTaglineColor(newValue);

        end;
      }):Play();

      task.delay(2, function()
      
        dataTypeTween({
          type = "Number";
          goalValue = 1;
          onChange = function(newValue)

            setTextTransparency(newValue);

          end;
        }):Play();

      end);

    end);

    return function()

      characterAddedEvent:Disconnect();

    end;

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
        TextTransparency = textTransparency;
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
        TextTransparency = textTransparency;
        LayoutOrder = 2;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
        TextColor3 = titleColor;
        TextSize = textSizes.title;
      });
      TaglineLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
        TextTransparency = textTransparency;
        LayoutOrder = 3;
        Text = "BREAK EVERYTHING BEFORE THEY DO!!";
        FontFace = Font.fromName("PressStart2P");
        TextColor3 = taglineColor;
        TextSize = textSizes.tagline;
      });
    });
  });

end;

return MatchInitializationHeader;