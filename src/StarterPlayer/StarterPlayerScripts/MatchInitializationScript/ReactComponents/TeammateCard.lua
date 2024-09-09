--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
local Colors = require(ReplicatedStorage.Client.Colors);
type ClientArchetype = ClientArchetype.ClientArchetype;
local Players = game:GetService("Players");
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local NameLabel = require(script.Parent.NameLabel);

type TeammateCardProps = {
  contestant: ClientContestant?;
  layoutOrder: number;
  isRival: boolean;
  round: ClientRound?;
  uiPaddingRightOffset: number?;
}

local function TeammateCard(props: TeammateCardProps)

  local roundStatus: ClientRound.RoundStatus?, setRoundStatus = React.useState(if props.round then props.round.status else nil);
  local rivalMessage, setRivalMessage = React.useState("");
  local archetypeID, setArchetypeID = React.useState(if props.contestant then props.contestant.archetypeID else nil);

  React.useEffect(function(): ()

    if props.round then

      setRoundStatus(props.round.status);
      local event = props.round.onStatusChanged:Connect(function()
      
        setRoundStatus(props.round.status)

      end);

      return function()

        event:Disconnect();
  
      end;
    
    end;

  end, {props.round});

  React.useEffect(function()
  
    if props.contestant then
      
      props.contestant.onArchetypePrivatelyChosen:Connect(function(archetypeID)
      
        setArchetypeID(archetypeID);

      end);

      props.contestant.onArchetypeUpdated:Connect(function(archetypeID)
      
        setArchetypeID(archetypeID);

      end)

      if props.isRival then

        local messages = {
          "It's our family's secret recipe!";
          "Do you really wanna know?";
          "Eh, I don't feel like it";
          "BWAHA! I'll never tell";
          "How much you willing to pay?";
          "You'll know in a few seconds";
          "Over my dead body!",
          "Please donate me Robux"
        }
        setRivalMessage(messages[math.random(1, #messages)]);

      end;

    end;

  end, {props.contestant});


  local contestantBannerSizeXOffset = React.useState(100);
  
  local avatarImageLabelRef = React.useRef(nil :: ImageLabel?);
  local tcfUIPaddingRef = React.useRef(nil);
  local statusLabelRef = React.useRef(nil);
  local contestantBannerImageLabelRef = React.useRef(nil);
  React.useEffect(function()
  
    task.spawn(function()

      local avatarImageLabel = avatarImageLabelRef.current;
      local tcfUIPadding: UIPadding? = tcfUIPaddingRef.current;
      if avatarImageLabel and tcfUIPadding then

        if roundStatus == "Contestant selection" then

          dataTypeTween({
            type = "Number";
            tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
            initialValue = 0;
            goalValue = 15;
            onChange = function(newValue)

              avatarImageLabel.Size = UDim2.new(0, 15, 0, newValue);

            end;
          }):Play();

        elseif roundStatus == "Matchup preview" then

        local goalValue = 30 * (props.layoutOrder - 1) + 5;
        dataTypeTween({
          type = "Number";
          tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine);
          goalValue = goalValue;
          onChange = function(newValue)

            if props.isRival then

              tcfUIPadding.PaddingRight = UDim.new(0, newValue);

            else

              tcfUIPadding.PaddingLeft = UDim.new(0, newValue);

            end;

          end;
        }):Play();

        task.delay(5, function()
        
          dataTypeTween({
            type = "Number";
            initialValue = contestantBannerSizeXOffset;
            tweenInfo = TweenInfo.new(1 + (0.25 * (4 - props.layoutOrder)), Enum.EasingStyle.Bounce);
            goalValue = 0;
            onChange = function(newValue)

              local contestantBannerImageLabel: ImageLabel? = contestantBannerImageLabelRef.current;
              local statusLabel: TextLabel? = statusLabelRef.current;
              if contestantBannerImageLabel and statusLabel then 

                contestantBannerImageLabel.Size = UDim2.new(contestantBannerImageLabel.Size.X.Scale, newValue, contestantBannerImageLabel.Size.Y.Scale, contestantBannerImageLabel.Size.Y.Offset);
                statusLabel.Size = UDim2.new(statusLabel.Size.X.Scale, newValue, statusLabel.Size.Y.Scale, statusLabel.Size.Y.Offset);
  
              end;

            end;
          }):Play();

          dataTypeTween({
            type = "Number";
            initialValue = goalValue;
            tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine);
            goalValue = -60;
            onChange = function(newValue)

              if props.isRival then

                tcfUIPadding.PaddingRight = UDim.new(0, newValue);
  
              else
  
                tcfUIPadding.PaddingLeft = UDim.new(0, newValue);
  
              end;
  
            end;
          }):Play();

        end);
        
        end;

      end;

    end)

  end, {roundStatus, props.isRival :: any});

  React.useEffect(function()
  
    local contestantBannerImageLabel: ImageLabel? = contestantBannerImageLabelRef.current;
    local statusLabel: TextLabel? = statusLabelRef.current;
    if contestantBannerImageLabel and statusLabel then

      contestantBannerImageLabel.Size = UDim2.new(0, contestantBannerSizeXOffset, 0, 10);
      statusLabel.Size = UDim2.new(0, contestantBannerSizeXOffset, 0, 17)

    end;

  end, {props.round});

  local transparency = if props.uiPaddingRightOffset and props.uiPaddingRightOffset ~= 0 then props.uiPaddingRightOffset / -300 else nil;

  local statusLabelText = "Waiting for players...";
  if props.contestant then

    if archetypeID then

      statusLabelText = ClientArchetype.get(archetypeID).name;

    elseif roundStatus == "Contestant selection" then 

      statusLabelText = if props.contestant.isBot then "Waiting..." else "Choosing...";
      if props.isRival then

        statusLabelText = rivalMessage;

      end;

    else 

      statusLabelText = "Joined!";

    end;

  end;
  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    LayoutOrder = props.layoutOrder;
    Size = UDim2.new();
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 1);
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      VerticalAlignment = Enum.VerticalAlignment.Center;
    });
    RotationContainerFrame = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      BackgroundTransparency = 1;
      LayoutOrder = if props.isRival then 2 else 1;
    }, {
      TeammateCardFrame = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY;
        Rotation = if props.isRival then 2 else -2;
        BackgroundTransparency = 1;
        Size = UDim2.new();
      }, {
        UIPadding = React.createElement("UIPadding", {
          ref = tcfUIPaddingRef;
        });
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 1);
          SortOrder = Enum.SortOrder.LayoutOrder;
          HorizontalAlignment = if props.isRival then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left;
        });
        StatusLabel = React.createElement("TextLabel", {
          BackgroundTransparency = 1;
          LayoutOrder = 1;
          AutomaticSize = Enum.AutomaticSize.XY;
          Size = UDim2.new();
          Text = statusLabelText;
          TextTransparency = if props.contestant then transparency or 0 else 0.5 + (transparency or 0);
          TextColor3 = if props.isRival then Color3.fromRGB(255, 117, 117) else Color3.new(1, 1, 1);
          TextSize = 8;
          FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
          TextXAlignment = if props.isRival then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left;
          TextTruncate = Enum.TextTruncate.AtEnd;
        }, {
          UIPadding = React.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, 5);
            PaddingRight = UDim.new(0, 5);
          });
        });
        ContestantBannerImageLabel = React.createElement("ImageLabel", {
          BackgroundColor3 = Color3.fromRGB(0, 0, 0);
          BackgroundTransparency = if props.contestant then transparency or 0 else 0.4 + (transparency or 0);
          Size = UDim2.new(0, 100, 0, 10);
          Image = "rbxassetid://15562720000";
          ScaleType = Enum.ScaleType.Tile;
          LayoutOrder = 2;
          TileSize = UDim2.new(0, 28, 0, 28);
          ImageTransparency = if props.contestant or (props.round and props.round.status ~= "Waiting for players") then transparency or 0 else 1;
        }, {
          UICorner = React.createElement("UICorner", {
            CornerRadius = if props.round and props.round.status ~= "Waiting for players" then UDim.new(1, 0) else UDim.new(0, 5);
          });
          UIStroke = if props.contestant and props.contestant.player and props.contestant.player == Players.LocalPlayer then React.createElement("UIStroke", {
            Color = Colors.DemoDemonsOrange;
            Thickness = 2;
          }) else nil;
          UIGradient = if props.contestant then React.createElement("UIGradient", if props.isRival then {
            Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1));
              ColorSequenceKeypoint.new(0.488, Color3.fromRGB(124, 124, 124));
              ColorSequenceKeypoint.new(1, Color3.new());
            });
            Transparency = NumberSequence.new({
              NumberSequenceKeypoint.new(0, 1, 0);
              NumberSequenceKeypoint.new(1, 0, 0);
            })
          } else {
            Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0, Color3.new());
              ColorSequenceKeypoint.new(0.488, Color3.fromRGB(124, 124, 124));
              ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1));
            });
            Transparency = NumberSequence.new({
              NumberSequenceKeypoint.new(0, 0, 0);
              NumberSequenceKeypoint.new(1, 1, 0);
            })
          }) else nil;
          ContestantInformationContainerFrame = if props.contestant then React.createElement("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BackgroundTransparency = 0.4 + (transparency or 0);
            Size = UDim2.new(1, 0, 1, 0);
          }, {
            UICorner = React.createElement("UICorner", {
              CornerRadius = if props.round and props.round.status ~= "Waiting for players" then UDim.new(1, 0) else UDim.new(0, 5)
            });
            UIGradient = React.createElement("UIGradient", {
              Transparency = NumberSequence.new(if props.isRival then {
                NumberSequenceKeypoint.new(0, 0.8, 0);
                NumberSequenceKeypoint.new(1, 0.50625, 0);
              } else {
                NumberSequenceKeypoint.new(0, 0.50625, 0);
                NumberSequenceKeypoint.new(1, 0.8, 0);
              });
            });
            UIListLayout = if props.round and props.round.status == "Waiting for players" then React.createElement("UIListLayout", {
              SortOrder = Enum.SortOrder.LayoutOrder;
              VerticalAlignment = Enum.VerticalAlignment.Center;
              HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
              FillDirection = Enum.FillDirection.Horizontal;
            }) else nil;
            UIPadding = React.createElement("UIPadding", {
              PaddingLeft = UDim.new(0, 7);
              PaddingRight = UDim.new(0, 7);
            });
            ContestantInformationFrame = React.createElement("Frame", {
              BackgroundTransparency = 1;
              AutomaticSize = Enum.AutomaticSize.XY;
              Position = UDim2.new(if props.isRival then 1 else 0, 0, 0.5, 0);
              AnchorPoint = Vector2.new(if props.isRival then 1 else 0, 0.5);
              Size = UDim2.new();
              LayoutOrder = if props.isRival then 2 else 1;
            }, {
              UIListLayout = if props.round and props.round.status ~= "Waiting for players" then React.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalAlignment = Enum.VerticalAlignment.Center;
              }) else nil;
              DisplayNameLabel = React.createElement(NameLabel, {
                name = props.contestant.name;
                type = "Display Name";
                TextTransparency = transparency;
              });
              UsernameLabel = if props.round and props.round.status == "Waiting for players" and props.contestant.player then React.createElement(NameLabel, {
                name = props.contestant.player.Name;
                type = "Username";
                TextTransparency = transparency;
              }) else nil;
            });
            ReadyIndicationImageLabelContainer = if props.round and props.round.status == "Waiting for players" and props.contestant then React.createElement("Frame", {
              BackgroundTransparency = 1;
              AnchorPoint = Vector2.new(if props.isRival then 0 else 1, 1);
              Position = UDim2.new();
              Size = UDim2.new(0, 35, 0, 35);
              LayoutOrder = if props.isRival then 1 else 2;
            }, {
              ReadyIndicationImageLabel = React.createElement("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0);
                Image = "rbxassetid://17571806169";
                ImageTransparency = transparency;
                BackgroundTransparency = 1;
              });
            }) else nil;
            AvatarImageLabel = if props.round and props.round.status ~= "Waiting for players" and props.contestant then React.createElement("ImageLabel", {
              AnchorPoint = Vector2.new(if props.isRival then 0 else 1, 1);
              Position = UDim2.new(if props.isRival then 0 else 1, 0, 1, 0);
              Size = UDim2.new();
              ref = avatarImageLabelRef;
              Image = if props.contestant.player then Players:GetUserThumbnailAsync(props.contestant.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) else "rbxassetid://18458164991";
              BackgroundTransparency = 1;
              ImageTransparency = transparency;
              LayoutOrder = if props.isRival then 1 else 2;
            }) else nil;
          }) else nil;
        });
      });
    });
  });

end;

return TeammateCard;