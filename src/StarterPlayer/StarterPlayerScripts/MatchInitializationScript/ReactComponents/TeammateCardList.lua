--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
}

local function TeammateCardList(props: TeammateCardListProps)

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(if props.layoutOrder == 1 then 0 else 1, 0.5);
    AutomaticSize = Enum.AutomaticSize.XY;
    Position = UDim2.new(if props.layoutOrder == 1 then 0 else 1, 0, 0.5, 0);
    BackgroundTransparency = 1;
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  }, {
    React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 1);
      HorizontalAlignment = if props.layoutOrder == 2 then Enum.HorizontalAlignment.Right else nil;
    });
    React.createElement(React.Fragment, {}, props.children);
  })

end;

return TeammateCardList;