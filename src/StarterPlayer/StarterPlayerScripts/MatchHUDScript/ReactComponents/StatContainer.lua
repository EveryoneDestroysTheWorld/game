--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

type StatContainerProperties = {
  iconImage: string;
  value: string;
  layoutOrder: number;
}

local function StatContainer(props: StatContainerProperties)

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    BackgroundTransparency = 1;
    LayoutOrder = props.layoutOrder;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Horizontal;
    });
    ImageLabel = React.createElement("ImageLabel", {
      Size = UDim2.new(1, 0, 1, 0);
      SizeConstraint = Enum.SizeConstraint.RelativeYY;
      Image = props.iconImage;
      ImageTransparency = 0.4;
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      ImageColor3 = Color3.new(1, 1, 1);
    });
    CurrentValueLabel = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      Text = props.value;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Regular);
      TextSize = 14;
      AutomaticSize = Enum.AutomaticSize.XY;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new();
    });
  });

end;

return StatContainer;