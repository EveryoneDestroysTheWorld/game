--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Colors = require(ReplicatedStorage.Client.Colors);
local ArchetypeSelectionButton = require(script.Parent.ArchetypeSelectionButton);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type ArchetypeCategoryFrameProps = {
  type: string;
  archetypes: {ClientArchetype};
  selectedArchetype: ClientArchetype?;
  onArchetypeSelected: (ClientArchetype) -> ();
  isDisabled: boolean;
}

local function ArchetypeCategoryFrame(props: ArchetypeCategoryFrameProps)

  local archetypeButtons = {};
  for _, archetype in ipairs(props.archetypes) do

    archetypeButtons[`Archetype{archetype.ID}`] = React.createElement(ArchetypeSelectionButton, {
      archetype = archetype;
      isSelected = props.selectedArchetype and archetype.ID == props.selectedArchetype.ID;
      onSelect = function()

        props.onArchetypeSelected(archetype);

      end;
    });
    
  end;

  local shouldShowArchetypeClassLabel = useResponsiveDesign({minimumWidth = 600});

  return React.createElement("Frame", {
    BackgroundTransparency = 0.55;
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundColor3 = Color3.new(0, 0, 0);
    Size = UDim2.new();
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 5);
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalFlex = Enum.UIFlexAlignment.SpaceBetween;
      VerticalAlignment = Enum.VerticalAlignment.Center;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    UIStroke = React.createElement("UIStroke", {
      Color = Colors.PopupBorder;
      Thickness = 1;
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingBottom = UDim.new(0, 5);
      PaddingLeft = UDim.new(0, 5);
      PaddingRight = UDim.new(0, 5);
      PaddingTop = UDim.new(0, 5);
    });
    ArchetypeButtonListFrame = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.XY;
      LayoutOrder = 1;
      Size = UDim2.new();
      BackgroundTransparency = 1;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Wraps = true;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      ArchetypeButtonList = React.createElement(React.Fragment, {}, archetypeButtons);
    });
    ArchetypeClassNameLabel = if shouldShowArchetypeClassLabel then React.createElement("TextLabel", {
      Text = props.type:upper();
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      LayoutOrder = 2;
      TextSize = 8;
      BackgroundTransparency = 1;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
      TextColor3 = Colors.ParagraphText;
    }) else nil;
  });

end;

return ArchetypeCategoryFrame;