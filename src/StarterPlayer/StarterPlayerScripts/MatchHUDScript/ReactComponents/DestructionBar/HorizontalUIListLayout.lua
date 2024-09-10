--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function HorizontalUIListLayout()

  return React.createElement("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder;
    FillDirection = Enum.FillDirection.Horizontal;
    Name = "UIListLayout";
    Padding = UDim.new(0, 2);
    VerticalAlignment = Enum.VerticalAlignment.Center;
    HorizontalAlignment = Enum.HorizontalAlignment.Center;
  });

end;

return HorizontalUIListLayout;