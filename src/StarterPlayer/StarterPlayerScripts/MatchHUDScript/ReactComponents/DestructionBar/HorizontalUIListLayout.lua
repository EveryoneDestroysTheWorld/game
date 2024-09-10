--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

local function HorizontalUIListLayout()

  local shouldUseFullPadding = useResponsiveDesign({minimumWidth = 600});

  return React.createElement("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder;
    FillDirection = Enum.FillDirection.Horizontal;
    Name = "UIListLayout";
    Padding = UDim.new(0, if shouldUseFullPadding then 5 else 2);
    VerticalAlignment = Enum.VerticalAlignment.Center;
    HorizontalAlignment = Enum.HorizontalAlignment.Center;
  });

end;

return HorizontalUIListLayout;