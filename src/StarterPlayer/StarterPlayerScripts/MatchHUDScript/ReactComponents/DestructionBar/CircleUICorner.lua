--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function CircleUICorner()

  return React.createElement("UICorner", {
    CornerRadius = UDim.new(1, 0);
  });

end;

return CircleUICorner;