--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function Square(props: {anchorPoint: Vector2})

  return React.createElement("Frame", {
    AnchorPoint = props.anchorPoint;
    Size = UDim2.new(0, 4, 0, 4);
    BackgroundColor3 = Color3.new(1, 1, 1);
    Position = UDim2.new(if props.anchorPoint.X == 1 then 1 else 0, if props.anchorPoint.X == 1 then 2 else -2, if props.anchorPoint.Y == 1 then 1 else 0, if props.anchorPoint.Y == 1 then 2 else -2);
    BorderSizePixel = 0;
    BackgroundTransparency = 0.2;
  });

end;

return Square;