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

local function TeammateCard(props: TeammateCardProps)

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    LayoutOrder = props.layoutOrder;
    Size = UDim2.new();
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 15);
    });
    RotationContainerFrame = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      BackgroundTransparency = 1;
    }, {
      TeammateCardFrame = React.createElement("Frame", {
        Size = UDim2.new(0, 300, 0, 100);
        Rotation = -2;
        BackgroundTransparency = 1;
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 5);
          SortOrder = Enum.SortOrder.LayoutOrder;
        });
        ContestantDisplayNameLabel = React.createElement("TextLabel", {
          BackgroundTransparency = 1;
          LayoutOrder = 1;
          Size = UDim2.new(1, 0, 0, 0);
          AutomaticSize = Enum.AutomaticSize.Y;
          Text = if props.contestant then props.contestant.player.DisplayName else "Waiting for players...";
          TextTransparency = if props.contestant then 0 else 0.5;
          TextColor3 = if props.isRival then Color3.fromRGB(255, 117, 117) else Color3.new(1, 1, 1);
          TextSize = 17;
          TextXAlignment = Enum.TextXAlignment.Left;
          TextTruncate = Enum.TextTruncate.AtEnd;
        }, {
          UIPadding = React.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, 5);
            PaddingRight = UDim.new(0, 5);
          });
        });
        ContestantBannerImageLabel = React.createElement("ImageLabel", {
          BackgroundColor3 = Color3.fromRGB(91, 91, 91);
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
        });
      });
    });
    ReadyIndicationImageLabel = React.createElement("ImageLabel", {
      Size = UDim2.new(0, 35, 0, 35);
      Image = "rbxassetid://17571806169";
      BackgroundTransparency = 1;
    });
  });

end;

return TeammateCard;