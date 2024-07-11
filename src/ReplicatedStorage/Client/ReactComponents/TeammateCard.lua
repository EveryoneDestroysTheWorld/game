--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
-- local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant)
type ClientContestant = nil;

type TeammateCardProps = {
  contestant: ClientContestant?;
  layoutOrder: number;
  isRival: boolean;
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
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
    })
  });

end;

local function TeammateCard(props: TeammateCardProps)

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
        Size = UDim2.new(0, 300, 0, 100);
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
          Size = UDim2.new(1, 0, 0, 0);
          AutomaticSize = Enum.AutomaticSize.Y;
          Text = if props.contestant then "Joined!" else "Waiting for players...";
          TextTransparency = if props.contestant then 0 else 0.5;
          TextColor3 = if props.isRival then Color3.fromRGB(255, 117, 117) else Color3.new(1, 1, 1);
          TextSize = 17;
          FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
          TextXAlignment = Enum.TextXAlignment.Left;
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
          Size = UDim2.new(1, 0, 1, -25);
          Image = "rbxassetid://15562720000";
          ScaleType = Enum.ScaleType.Tile;
          LayoutOrder = 2;
          TileSize = UDim2.new(0, 28, 0, 28);
          ImageTransparency = if props.contestant then 0 else 1;
        }, {
          UICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0, 5);
          });
          UIGradient = if props.contestant then React.createElement("UIGradient", {
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
          UIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 15);
            FillDirection = Enum.FillDirection.Horizontal;
            VerticalAlignment = Enum.VerticalAlignment.Center;
          });
          ContestantInformationFrame = if props.contestant then React.createElement("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BackgroundTransparency = 0.4;
            Size = UDim2.new(1, 0, 1, 0);
          }, {
            UICorner = React.createElement("UICorner", {
              CornerRadius = UDim.new(0, 5);
            });
            UIGradient = React.createElement("UIGradient", {
              Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.50625, 0);
                NumberSequenceKeypoint.new(1, 0.8, 0);
              });
            });
            UIListLayout = React.createElement("UIListLayout", {
              SortOrder = Enum.SortOrder.LayoutOrder;
              VerticalAlignment = Enum.VerticalAlignment.Center;
            });
            DisplayNameLabel = React.createElement(NameLabel, {
              name = props.contestant.player.DisplayName;
              type = "Display Name";
            });
            UsernameLabel = React.createElement(NameLabel, {
              name = props.contestant.player.Name;
              type = "Username";
            });
          }) else nil;
          ReadyIndicationImageLabel = if props.contestant then React.createElement("ImageLabel", {
            Size = UDim2.new(0, 35, 0, 35);
            Image = "rbxassetid://17571806169";
            BackgroundTransparency = 1;
            LayoutOrder = if props.isRival then 1 else 2;
          }) else nil;
        });
      });
    });
  });

end;

return TeammateCard;