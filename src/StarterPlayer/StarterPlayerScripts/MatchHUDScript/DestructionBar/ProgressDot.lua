--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local CircleUICorner = require(script.Parent.CircleUICorner);

type ProgressDotProps = {
  teamColor: Color3?;
  progress: number?;
  LayoutOrder: number;
}

local function ProgressDot(props: ProgressDotProps)

  local color, setColor = React.useState(Color3.new(1, 1, 1));

  React.useEffect(function()
  
    if props.teamColor and props.progress then

      local hue, saturation, value = props.teamColor:ToHSV();
      local newColor = Color3.fromHSV(hue, saturation * props.progress, value);
      setColor(newColor);

    else

      setColor(Color3.new(1, 1, 1));
      
    end;

  end, {props.teamColor, props.progress :: any});

  return React.createElement("Frame", {
    BorderSizePixel = 0;
    LayoutOrder = props.LayoutOrder;
    BackgroundColor3 = color;
    BackgroundTransparency = if props.progress then props.progress * 0.2 else 0.7;
    Size = UDim2.new(0, 3, 0, 3);
  }, {
    CircleUICorner = React.createElement(CircleUICorner);
  });

end;

return ProgressDot;