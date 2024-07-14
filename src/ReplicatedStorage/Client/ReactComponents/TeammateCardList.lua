--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
  uiPaddingRightOffset: number?;
}

local function TeammateCardList(props: TeammateCardListProps)

  return React.createElement(if props.uiPaddingRightOffset and props.uiPaddingRightOffset ~= 0 then "CanvasGroup" else "Frame", {
    AnchorPoint = Vector2.new(if props.layoutOrder == 1 then 0 else 1, 0);
    AutomaticSize = Enum.AutomaticSize.XY;
    Position = UDim2.new(if props.layoutOrder == 1 then 0 else 1, 0, 0, 0);
    BackgroundTransparency = 1;
    GroupTransparency = if props.uiPaddingRightOffset and props.uiPaddingRightOffset ~= 0 then props.uiPaddingRightOffset / -300 else nil,
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  }, {
    React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 15);
    });
    React.createElement(React.Fragment, {}, props.children);
  })

end;

return TeammateCardList;