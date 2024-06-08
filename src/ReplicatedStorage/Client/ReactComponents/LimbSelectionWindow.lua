local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local LimbSelectionButton = require(script.Parent.LimbSelectionButton);

type LimbSelectionWindowProps = {
  onLimbSelect: (limbName: string) -> ();
};

local function LimbSelectionWindow(props: LimbSelectionWindowProps)

  local buttonComponents = {};
  local limbInfo = {
    {name = "Torso"; shortcutCharacter = "1";};
    {name = "Head"; shortcutCharacter = "2";};
  };
  for _, limb in ipairs(limbInfo) do

    table.insert(buttonComponents, React.createElement(LimbSelectionButton, {
      onActivate = function()

        props.onLimbSelect(limb.name);

      end;
    }));

  end;

  return React.createElement(React.StrictMode, {}, {
    Container = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Position = UDim2.new(0, 30, 1, -90);
      Size = UDim2.new(0, 0, 0, 0);
      AutomaticSize = Enum.AutomaticSize.XY;
    }, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        Padding = UDim.new(0, 15);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      buttonComponents;
    });
  });

end;

return LimbSelectionWindow;