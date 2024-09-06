--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function ScreenUIListLayout()

  return React.createElement("UIPadding", {
    PaddingLeft = UDim.new(0, 15);
    PaddingTop = UDim.new(0, 15);
    PaddingBottom = UDim.new(0, 15);
    PaddingRight = UDim.new(0, 15);
  });

end

return ScreenUIListLayout;