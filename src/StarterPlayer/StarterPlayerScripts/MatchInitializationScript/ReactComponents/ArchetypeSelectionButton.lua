--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Colors = require(ReplicatedStorage.Client.Colors);

type ArchetypeSelectionButtonProps = {
  archetype: ClientArchetype;
  isSelected: boolean;
  onSelect: () -> ();
  isDisabled: boolean;
}

local function ArchetypeSelectionButton(props: ArchetypeSelectionButtonProps)

  return React.createElement("TextButton", {
    ClipsDescendants = true;
    BackgroundTransparency = 0.55;
    BackgroundColor3 = Color3.new(0, 0, 0);
    Text = "";
    Size = UDim2.new(0, 70, 0, 70);
    [React.Event.Activated] = function()

      props.onSelect();

    end;
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
    UIStroke = React.createElement("UIStroke", {
      Color = if props.isSelected then Colors.DemoDemonsOrange else Colors.PopupBorder;
      Thickness = 2;
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
      Transparency = if props.isDisabled then 0.6 else 0;
    });
    ImageLabel = React.createElement("ImageLabel", {
      AnchorPoint = Vector2.new(0.5, 0.5);
      Image = props.archetype.iconImage;
      Position = UDim2.new(0, 20, 1, -15);
      Size = UDim2.new(1, 15, 1, 15);
      BackgroundTransparency = 1;
      ImageTransparency = if props.isDisabled then 0.6 else 0; 
    })
  });

end;

return ArchetypeSelectionButton;