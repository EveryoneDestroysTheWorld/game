--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Players = game:GetService("Players");
local TweenService = game:GetService("TweenService");

type TeammateCardProps = {
  contestant: ClientContestant?;
  layoutOrder: number;
  isRival: boolean;
  round: ClientRound;
}

type NameLabelProps = {
  name: string;
  type: "Username" | "Display Name";
}

local function NameLabel(props: NameLabelProps)

  return React.createElement("TextLabel", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    Text = props.name;
    FontFace = Font.fromId(11702779517, if props.type == "Display Name" then Enum.FontWeight.Heavy else Enum.FontWeight.Medium);
    TextSize = if props.type == "Display Name" then 20 else 14;
    TextColor3 = if props.type == "Display Name" then Color3.new(1, 1, 1) else Color3.fromRGB(208, 208, 208);
    LayoutOrder = if props.type == "Display Name" then 1 else 2;
    TextTruncate = Enum.TextTruncate.AtEnd;
    TextXAlignment = Enum.TextXAlignment.Left;
  });

end;

local function TeammateCard(props: TeammateCardProps)

  local canChooseArchetype, setCanChooseArchetype = React.useState(false);
  local canUseCanvasGroups, setCanUseCanvasGroups = React.useState(false);

  local readyIndicationUIPaddingRef = React.useRef(nil);
  local readyIndicationImageLabelRef = React.useRef(nil);

  React.useEffect(function()

    local event;

    if props.round then 

      local canChooseArchetype = props.round.status == "Contestant selection";
      
      if readyIndicationImageLabelRef.current then
        
        readyIndicationImageLabelRef.current.Visible = false;

      end
      setCanChooseArchetype(canChooseArchetype);
      setCanUseCanvasGroups(canChooseArchetype);

      if not canChooseArchetype then

        event = props.round.onStatusChanged:Connect(function()
        
          setCanUseCanvasGroups(true);
          setCanChooseArchetype(true);

        end);

      end;

    end;

    return function()

      if event then

        event:Disconnect();

      end;

    end;

  end, {props.round});

  local statusLabelText = "Waiting for players...";
  local rivalMessage, setRivalMessage = React.useState("");
  React.useEffect(function()
  
    if props.contestant and props.isRival then

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

  end, {props.contestant});

  if props.contestant then

    if canChooseArchetype then

      statusLabelText = if props.contestant.isBot then "Waiting..." else "Choosing...";
      if props.isRival then

        statusLabelText = rivalMessage;

      end;

    else 

      statusLabelText = "Joined!";

    end;

  end;

  React.useEffect(function()
  
    if canChooseArchetype and readyIndicationImageLabelRef.current and readyIndicationUIPaddingRef.current then

      local numberValue = Instance.new("NumberValue");
      numberValue:GetPropertyChangedSignal("Value"):Connect(function()
      
        readyIndicationImageLabelRef.current.Visible = true;
        readyIndicationUIPaddingRef.current.PaddingTop = UDim.new(0, numberValue.Value);

      end);
      numberValue.Value = 60;
      
      local tween = TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 0});
      tween.Completed:Connect(function()
      
        setCanUseCanvasGroups(false);

      end);
      tween:Play();

    end;

  end, {canChooseArchetype});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    LayoutOrder = props.layoutOrder;
    Size = UDim2.new();
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 15);
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
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 5);
          SortOrder = Enum.SortOrder.LayoutOrder;
        });
        StatusLabel = React.createElement("TextLabel", {
          BackgroundTransparency = 1;
          LayoutOrder = 1;
          Size = UDim2.new(0, 300, 0, 17);
          Text = statusLabelText;
          TextTransparency = if props.contestant then 0 else 0.5;
          TextColor3 = if props.isRival then Color3.fromRGB(255, 117, 117) else Color3.new(1, 1, 1);
          TextSize = 17;
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
          BackgroundTransparency = if props.contestant then 0 else 0.4;
          Size = UDim2.new(0, 300, 0, if props.round and props.round.status == "Waiting for players" then 100 else 30);
          Image = "rbxassetid://15562720000";
          ScaleType = Enum.ScaleType.Tile;
          LayoutOrder = 2;
          TileSize = UDim2.new(0, 28, 0, 28);
          ImageTransparency = if props.contestant or (props.round and props.round.status ~= "Waiting for players") then 0 else 1;
        }, {
          UICorner = React.createElement("UICorner", {
            CornerRadius = if props.round and props.round.status ~= "Waiting for players" then UDim.new(1, 0) else UDim.new(0, 5);
          });
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
            BackgroundTransparency = 0.4;
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
              PaddingLeft = UDim.new(0, 15);
              PaddingRight = UDim.new(0, 15);
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
              });
              UsernameLabel = if props.round and props.round.status == "Waiting for players" and props.contestant.player then React.createElement(NameLabel, {
                name = props.contestant.player.Name;
                type = "Username";
              }) else nil;
            });
            ReadyIndicationImageLabelContainer = React.createElement(if canUseCanvasGroups then "CanvasGroup" else "Frame", {
              BackgroundTransparency = 1;
              AnchorPoint = Vector2.new(if props.isRival then 0 else 1, 1);
              Position = if props.round and props.round.status ~= "Waiting for players" then UDim2.new(if props.isRival then 0 else 1, 0, 1, 0) else UDim2.new();
              Size = if props.round and props.round.status ~= "Waiting for players" then UDim2.new(0, 60, 0, 60) else UDim2.new(0, 35, 0, 35);
            }, {
              UIPadding = React.createElement("UIPadding", {
                ref = readyIndicationUIPaddingRef;
              });
              ReadyIndicationImageLabel = if props.contestant then React.createElement("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0);
                ref = readyIndicationImageLabelRef;
                Image = if props.round and props.round.status ~= "Waiting for players" then if props.contestant.player then Players:GetUserThumbnailAsync(props.contestant.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) else "rbxassetid://18458164991" else "rbxassetid://17571806169";
                BackgroundTransparency = 1;
                LayoutOrder = if props.isRival then 1 else 2;
              }) else nil;
            });
          }) else nil;
        });
      });
    });
  });

end;

return TeammateCard;