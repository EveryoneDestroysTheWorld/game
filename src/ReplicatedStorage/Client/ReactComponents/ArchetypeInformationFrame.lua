local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Colors = require(ReplicatedStorage.Client.Colors);
local ActionButton = require(script.Parent.ActionButton);

type ArchetypeInformationFrameProps = {
  selectedArchetype: ClientArchetype?;
  uiPaddingRightOffset: number;
}

local function ArchetypeInformationFrame(props: ArchetypeInformationFrameProps)

  local actionTextButtons, setActionTextButtons = React.useState({});
  local selectedAction: ClientAction?, setSelectedAction = React.useState(nil);

  React.useEffect(function()
  
    task.spawn(function()

      if props.selectedArchetype then

        local actionTextButtons = {};
        for _, actionID in ipairs(props.selectedArchetype.actionIDs) do

          local action = ClientAction.get(actionID);
          local actionButton = React.createElement(ActionButton, {
            iconImage = action.iconImage;
            onActivate = function() 
              
              setSelectedAction(action);

            end
          });
          table.insert(actionTextButtons, actionButton)

        end;
        setActionTextButtons(actionTextButtons);

      else

        setActionTextButtons({});

      end;

    end)

  end, {props.selectedArchetype, selectedAction});

  return React.createElement(if props.uiPaddingRightOffset ~= -300 then "CanvasGroup" else "Frame", {
    AnchorPoint = Vector2.new(1, 0);
    GroupTransparency = if props.uiPaddingRightOffset ~= -300 then 1 - props.uiPaddingRightOffset / -300 else nil;
    Position = UDim2.new(1, -300, 0, 0);
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    LayoutOrder = 2;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 15);
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(350, math.huge);
    });
    PrimaryMetadataFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 5);
      });
      ArchetypeClassTextLabel = if props.selectedArchetype then React.createElement("TextLabel", {
        LayoutOrder = 1;
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextColor3 = Colors.HeadingText;
        TextSize = 14;
        Text = props.selectedArchetype.type:upper();
        FontFace = Font.fromId(11702779517);
        TextXAlignment = Enum.TextXAlignment.Left;
      }) else nil;
      ArchetypeNameTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 2;
        TextSize = 30;
        Text = if props.selectedArchetype then props.selectedArchetype.name:upper() else "CHOOSE AN ARCHETYPE";
        TextColor3 = Colors.HeadingText;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
        TextXAlignment = Enum.TextXAlignment.Left;
      });
      ArchetypeDescriptionTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 3;
        Text = if props.selectedArchetype then props.selectedArchetype.description else "Let's take a looksie here...";
        TextWrapped = true;
        TextSize = 14;
        TextColor3 = Colors.ParagraphText;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Medium);
        TextXAlignment = Enum.TextXAlignment.Left;
      });
    });
    SecondaryMetadataFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      AutomaticSize = Enum.AutomaticSize.XY;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 5);
      });
      ActionListFrame = React.createElement("Frame", {
        BackgroundTransparency = 1;
        LayoutOrder = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
      }, {
        React.createElement("UIListLayout", {
          Name = "UIListLayout";
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
          Padding = UDim.new(0, 5);
        });
        actionTextButtons;
      });
      ActionInformationFrame = if selectedAction then React.createElement("Frame", {
        BackgroundTransparency = 0.55;
        BackgroundColor3 = Color3.new(0, 0, 0);
        LayoutOrder = 2;
        AutomaticSize = Enum.AutomaticSize.XY;
        Size = UDim2.new();
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          Padding = UDim.new(0, 5);
        });
        UICorner = React.createElement("UICorner", {
          CornerRadius = UDim.new(0, 5);
        });
        UIPadding = React.createElement("UIPadding", {
          PaddingBottom = UDim.new(0, 15);
          PaddingLeft = UDim.new(0, 15);
          PaddingRight = UDim.new(0, 15);
          PaddingTop = UDim.new(0, 15);
        });
        UIStroke = React.createElement("UICorner", {
          Color = Color3.fromRGB(49, 49, 49);
        });
        ActionNameTextLabel = React.createElement("TextLabel", {
          BackgroundTransparency = 1;
          Text = selectedAction.name:upper();
          AutomaticSize = Enum.AutomaticSize.XY;
          Size = UDim2.new();
          FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
          TextColor3 = Colors.HeadingText;
          TextSize = 17;
          TextXAlignment = Enum.TextXAlignment.Left;
        });
        ActionDescriptionTextLabel = React.createElement("TextLabel", {
          BackgroundTransparency = 1;
          AutomaticSize = Enum.AutomaticSize.XY;
          Text = selectedAction.description;
          FontFace = Font.fromId(11702779517);
          Size = UDim2.new();
          TextColor3 = Colors.ParagraphText;
          TextSize = 14;
          TextXAlignment = Enum.TextXAlignment.Left;
        });
      }) else nil;
    });
  });

end;

return ArchetypeInformationFrame;