--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

type LimbSelectionButtonProps = {
  onActivate: () -> ();
  shortcutCharacter: string;
  layoutOrder: number;
}

local function LimbSelectionButton(props: LimbSelectionButtonProps)

  local function onActivate()

    props.onActivate();

  end;

  return React.createElement("TextButton", {
    [React.Event.Activated] = onActivate;
    BackgroundColor3 = Color3.new(0, 0, 0);
    Size = UDim2.new(0, 50, 0, 50);
    BackgroundTransparency = 0.4;
    Text = "";
    BorderSizePixel = 0;
    LayoutOrder = props.layoutOrder;
  }, {
    UIStroke = React.createElement("UIStroke", {
      Color = Color3.fromRGB(204, 204, 204);
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    });
  });

end;

return LimbSelectionButton;