--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local CircleUICorner = require(ReplicatedStorage.Client.ReactComponents.CircleUICorner);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type ProgressDotProps = {
  teamColor: Color3?;
  progress: number?;
  LayoutOrder: number;
}

local function ProgressDot(props: ProgressDotProps)

  local color = Color3.new(1, 1, 1);

  if props.teamColor and props.progress then

    local hue, saturation, value = props.teamColor:ToHSV();
    color = Color3.fromHSV(hue, saturation * props.progress, value);
    
  end;

  local shouldUseFullSize = useResponsiveDesign({minimumHeight = 600});

  return React.createElement("Frame", {
    BorderSizePixel = 0;
    LayoutOrder = props.LayoutOrder;
    BackgroundColor3 = color;
    BackgroundTransparency = if props.progress then props.progress * 0.2 else 0.7;
    Size = UDim2.new(0, if shouldUseFullSize then 7 else 3, 0, if shouldUseFullSize then 7 else 3);
  }, {
    CircleUICorner = React.createElement(CircleUICorner);
  });

end;

return ProgressDot;