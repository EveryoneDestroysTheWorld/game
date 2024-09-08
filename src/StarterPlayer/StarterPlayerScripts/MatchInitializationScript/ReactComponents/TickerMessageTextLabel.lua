--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type TickerMessageTextLabelProps = {
  text: string;
  layoutOrder: number;
}

local function TickerMessageTextLabel(props: TickerMessageTextLabelProps)

  return React.createElement("TextLabel", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.X;
    Size = UDim2.new(0, 0, 0, 14);
    TextSize = 14;
    TextColor3 = Color3.new(1, 1, 1);
    FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
    Text = props.text;
    LayoutOrder = props.layoutOrder;
  });

end;

return TickerMessageTextLabel;