local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type LimbSelectionButtonProps = {
  onActivate: () -> ();
  shortcutCharacter: string;
}

local function LimbSelectionButton(props: LimbSelectionButtonProps)

  local function onActivate()

    props.onActivate();

  end;

  return React.createElement("TextButton", {
    [React.Event.Activated] = onActivate;
    BackgroundTransparency = 1;
    Size = UDim2.new(0, 50, 0, 65);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalFlex = Enum.UIFlexAlignment.SpaceBetween;
    });
    IconContainerFrame = React.createElement("Frame", {
      BackgroundTransparency = 0.9;
      BorderSizePixel = 0;
      LayoutOrder = 1;
      Size = UDim2.new(0, 50, 0, 50);
    }, {
      UIStroke = React.createElement("UIStroke", {});
      IconImageLabel = React.createElement("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, -10, 1, -10);
        BackgroundTransparency = 1;
      });
    });
    ShortcutCharacterLabel = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 0, 10);
      LayoutOrder = 2;
      Text = props.shortcutCharacter;
    });
  });

end;

return LimbSelectionButton;