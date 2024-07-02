local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local LimbSelectionButton = require(script.Parent.LimbSelectionButton);

type LimbSelectionWindowProps = {
  onSelect: (limbName: string) -> ();
  onClose: () -> ();
};

local function LimbSelectionWindow(props: LimbSelectionWindowProps)

  local buttonComponents = {};
  local limbInfo = {
    {
      {limbName = "Head"; shortcutCharacter = "U"}
    };
    {
      {limbName = "LeftArm"; shortcutCharacter = "H"};
      {limbName = "Torso"; shortcutCharacter = "J"};
      {limbName = "RightArm"; shortcutCharacter = "K"};
    };
    {
      {limbName = "LeftLeg"; shortcutCharacter = "N"};
      {limbName = "RightLeg"; shortcutCharacter = "M"};
    };
  };
  for rowIndex, row in ipairs(limbInfo) do

    local buttonComponentsRow = {};
    local layoutOrder = 1;
    for _, componentInfo in ipairs(row) do

      table.insert(buttonComponentsRow, React.createElement(LimbSelectionButton, {
        shortcutCharacter = componentInfo.shortcutCharacter;
        layoutOrder = layoutOrder;
        onActivate = function()
  
          props.onSelect(componentInfo.limbName);
  
        end;
      }));
  
      layoutOrder += 1;

    end;

    table.insert(buttonComponents, React.createElement("Frame", {
      LayoutOrder = rowIndex;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new(0, 0, 0, 0);
      BackgroundTransparency = 1;
    }, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        Padding = UDim.new(0, 5);
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      buttonComponentsRow
    }));

  end;

  return React.createElement(React.StrictMode, {}, {
    Container = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AnchorPoint = Vector2.new(0.5, 0.5);
      Position = UDim2.new(0.5, 0, 0.5, 0);
      Size = UDim2.new(0, 0, 0, 0);
      AutomaticSize = Enum.AutomaticSize.XY;
    }, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        Padding = UDim.new(0, 5);
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      buttonComponents
    });
  });

end;

return LimbSelectionWindow;
