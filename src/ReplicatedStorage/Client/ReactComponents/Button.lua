
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Line = require(script.Parent.Line);
local Square = require(script.Parent.Square);

export type ButtonProperties = {
  Text: string;
  LayoutOrder: number;
  [typeof(React.Event.Activated)]: () -> ()
}

local function Button(properties: ButtonProperties)

  return React.createElement("TextButton", {
    LayoutOrder = properties.LayoutOrder;
    Size = UDim2.new(1, 0, 0, 30);
    BackgroundTransparency = 0.6;
    BorderSizePixel = 0;
    BackgroundColor3 = Color3.new();
    Text = "";
    [React.Event.Activated] = properties[React.Event.Activated];
  }, {
    DecorationContainer = React.createElement("Frame", {
      Size = UDim2.new(1, 0, 1, 0);
      BackgroundTransparency = 1;
    }, {
      TopLine = React.createElement(Line, {isTop = true});
      BottomLine = React.createElement(Line, {isTop = false});
      TopLeftSquare = React.createElement(Square, {anchorPoint = Vector2.new()});
      TopRightSquare = React.createElement(Square, {anchorPoint = Vector2.new(1, 0)});
      BottomLeftSquare = React.createElement(Square, {anchorPoint = Vector2.new(0, 1)});
      BottomRightSquare = React.createElement(Square, {anchorPoint = Vector2.new(1, 1)});
    });
    TextLabel = React.createElement("TextLabel", {
      AnchorPoint = Vector2.new(0.5, 0.5);
      Position = UDim2.new(0.5, 0, 0.5, 0);
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Light);
      TextColor3 = Color3.new(1, 1, 1);
      TextSize = 14;
      Text = properties.Text;
    });
  });

end;

return Button;