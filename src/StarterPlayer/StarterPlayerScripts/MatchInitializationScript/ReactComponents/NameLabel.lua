--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

export type NameLabelProps = {
  name: string;
  type: "Username" | "Display Name";
}

local function NameLabel(props: NameLabelProps)

  return React.createElement("TextLabel", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    Text = props.name;
    FontFace = Font.fromId(11702779517, if props.type == "Display Name" then Enum.FontWeight.Heavy else Enum.FontWeight.Medium);
    TextSize = 8;
    TextColor3 = if props.type == "Display Name" then Color3.new(1, 1, 1) else Color3.fromRGB(208, 208, 208);
    LayoutOrder = if props.type == "Display Name" then 1 else 2;
    TextTruncate = Enum.TextTruncate.AtEnd;
    TextXAlignment = Enum.TextXAlignment.Left;
  });

end;

return NameLabel;