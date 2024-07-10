local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function ScreenUIListLayout()

  return React.createElement("UIListLayout", {
    Padding = UDim.new(0, 15);
    SortOrder = Enum.SortOrder.LayoutOrder;
  });

end

return ScreenUIListLayout;