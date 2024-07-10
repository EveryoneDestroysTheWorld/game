local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);

type ParagraphTextLabelProps = {
  text: string;
  headingLevel: number?;
  LayoutOrder: number?;
  TextColor3: Color3?;
  children: any;
};

local function ParagraphTextLabel(props: ParagraphTextLabelProps)

  local fontInfo = if props.headingLevel then ({
    {
      TextSize = 20;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    }, 
    {
      TextSize = 18;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
    }
  })[props.headingLevel] else {
    TextSize = 14;
    FontFace = Font.fromId(11702779517);
  };

  return React.createElement("TextLabel", {
    LayoutOrder = props.LayoutOrder or 0;
    Text = props.text;
    BackgroundTransparency = 1;
    TextColor3 = props.TextColor3 or Colors.ParagraphText;
    AutomaticSize = Enum.AutomaticSize.XY;
    TextSize = fontInfo.TextSize;
    Size = UDim2.new(0, 0, 0, 0);
    FontFace = fontInfo.FontFace;
    LineHeight = 1.35;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextWrapped = true;
  }, {props.children});

end

return ParagraphTextLabel;