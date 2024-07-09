--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
}

local function TeammateCardList(props)

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
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