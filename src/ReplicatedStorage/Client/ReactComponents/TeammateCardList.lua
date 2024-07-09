--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type TeammateCardListProps = {
  layoutOrder: number;
}

local function TeammateCardList(props)

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  })

end;

return TeammateCardList;