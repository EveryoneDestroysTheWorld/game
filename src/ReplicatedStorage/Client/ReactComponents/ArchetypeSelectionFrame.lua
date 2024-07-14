local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Colors = require(ReplicatedStorage.Client.Colors);
local Button = require(script.Parent.Button);

type ArchetypeInformationFrameProps = {
  selectedArchetype: ClientArchetype?;
  onSelectionChanged: (newArchetype: ClientArchetype) -> ();
  onSelectionConfirmed: () -> ();
}

local function ArchetypeSelectionFrame(props: ArchetypeInformationFrameProps)

  local archetypeIDs, setArchetypeIDs = React.useState({});
  local archetypeCategoryFrames, setArchetypeCategoryFrames = React.useState({});

  -- Get a list of all owned archetypes.
  React.useEffect(function()
  
    setArchetypeIDs(ReplicatedStorage.Shared.Functions.GetArchetypeIDs:InvokeServer());

  end, {});

  React.useEffect(function()
  
    local archetypeCategories = {};
    for _, archetypeID in ipairs(archetypeIDs) do

      local archetype = ClientArchetype.get(archetypeID);
      if not archetypeCategories[archetype.type] then

        archetypeCategories[archetype.type] = {};        

      end;

      table.insert(archetypeCategories[archetype.type], archetype);

    end;

    local archetypeCategoryFrames = {};
    for type, archetypes in pairs(archetypeCategories) do

      local archetypeButtons = {};
      for _, archetype in ipairs(archetypes) do

        table.insert(archetypeButtons, React.createElement("TextButton", {
          ClipsDescendants = true;
          Name = `Archetype{archetype.ID}`;
          BackgroundTransparency = 0.55;
          BackgroundColor3 = Color3.new(0, 0, 0);
          Text = "";
          Size = UDim2.new(0, 70, 0, 70);
          [React.Event.Activated] = function()

            props.onSelectionChanged(archetype);

          end;
        }, {
          UICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(1, 0);
          });
          UIStroke = React.createElement("UIStroke", {
            Color = if props.selectedArchetype and props.selectedArchetype.ID == archetype.ID then Colors.DemoDemonsOrange else Colors.PopupBorder;
            Thickness = 2;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
          });
          ImageLabel = React.createElement("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Image = archetype.iconImage;
            Position = UDim2.new(0, 20, 1, -15);
            Size = UDim2.new(1, 15, 1, 15);
            BackgroundTransparency = 1;
          })
        }));
      end;
      table.insert(archetypeCategoryFrames, React.createElement("Frame", {
        Name = `{type}Frame`;
        BackgroundTransparency = 0.55;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new();
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          Padding = UDim.new(0, 15);
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
          PaddingBottom = UDim.new(0, 15);
          PaddingLeft = UDim.new(0, 15);
          PaddingRight = UDim.new(0, 15);
          PaddingTop = UDim.new(0, 15);
        });
        ArchetypeButtonListFrame = React.createElement("Frame", {
          AutomaticSize = Enum.AutomaticSize.XY;
          LayoutOrder = 1;
          Size = UDim2.new();
          BackgroundTransparency = 1;
        }, {
          React.createElement("UIListLayout", {
            Padding = UDim.new(0, 15);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            Wraps = true;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
          });
          archetypeButtons;
        });
        ArchetypeClassNameLabel = React.createElement("TextLabel", {
          Text = type:upper();
          AutomaticSize = Enum.AutomaticSize.XY;
          Size = UDim2.new();
          LayoutOrder = 2;
          TextSize = 14;
          BackgroundTransparency = 1;
          FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
          TextColor3 = Colors.ParagraphText;
        });
      }));

    end;
    setArchetypeCategoryFrames(archetypeCategoryFrames);

  end, {archetypeIDs, props.selectedArchetype});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
    BackgroundTransparency = 1;
    AnchorPoint = Vector2.new(0, 1);
    Position = UDim2.new(0, 0, 1, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 15);
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });
    ConfirmButton = React.createElement(Button, {
      text = "CONFIRM";
      LayoutOrder = 1;
      isDisabled = props.selectedArchetype == nil;
      onClick = function()

        props.onSelectionConfirmed();

      end;
    });
    ArchetypeCategoryListFrame = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      BackgroundTransparency = 1;
      LayoutOrder = 2;
    }, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, 15);
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      archetypeCategoryFrames;
    });
  });

end;

return ArchetypeSelectionFrame;