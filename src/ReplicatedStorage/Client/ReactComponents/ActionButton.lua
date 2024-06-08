local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type LimbSelectionButtonProps = {
  onActivate: () -> ();
  shortcutCharacter: string;
}

local function ActionButton(props: LimbSelectionButtonProps)

  local function onActivate()

    props.onActivate();

  end;

  return React.createElement("TextButton", {
    [React.Event.Activated] = onActivate;
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Text = "";
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      VerticalFlex = Enum.UIFlexAlignment.SpaceBetween;
    });
    RotationContainerFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      Size = UDim2.new(0, 50, 0, 50);
    }, {
      IconContainerButton = React.createElement("TextButton", {
        [React.Event.Activated] = onActivate;
        Rotation = 45;
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 0.4;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Text = "";
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, -15, 1, -15);
      }, {
        UIStroke = React.createElement("UIStroke", {
          Color = Color3.fromRGB(204, 204, 204);
          Thickness = 1;
          Transparency = 0.4;
        });
        IconImageLabel = React.createElement("ImageLabel", {
          AnchorPoint = Vector2.new(0.5, 0.5);
          Rotation = -45;
          Position = UDim2.new(0.5, 0, 0.5, 0);
          Size = UDim2.new(1, -10, 1, -10);
          BackgroundTransparency = 1;
          Image = "rbxassetid://17551046771";
        });
      });
    });
    ShortcutCharacterLabel = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      TextColor3 = Color3.new(1, 1, 1);
      Text = props.shortcutCharacter or "";
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
      AutomaticSize = Enum.AutomaticSize.XY;
    });
  });

end;

return ActionButton;