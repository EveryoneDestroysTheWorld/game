--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function Line(props: {isTop: boolean})

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0, if props.isTop then 0 else 1);
    Size = UDim2.new(1, 0, 0, 1);
    BackgroundColor3 = Color3.new(1, 1, 1);
    Position = UDim2.new(0, 0, if props.isTop then 0 else 1);
    BorderSizePixel = 0;
    BackgroundTransparency = 0.6;
  });

end;

return Line;