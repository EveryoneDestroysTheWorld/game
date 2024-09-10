--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Colors = require(ReplicatedStorage.Client.Colors);
local ActionButton = require(ReplicatedStorage.Client.ReactComponents.ActionButton);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type ArchetypeInformationFrameProps = {
  selectedArchetype: ClientArchetype?;
  shouldHide: boolean;
}

local function ArchetypeInformationFrame(props: ArchetypeInformationFrameProps)

  local actionTextButtons, setActionTextButtons = React.useState({});
  local shouldShowArchetypeDescriptionTextLabel, shouldShowSecondaryMetadataFrame, shouldUseIncreasedWidth = useResponsiveDesign(
    {minimumWidth = 600}, 
    {minimumWidth = 600, minimumHeight = 500},
    {minimumWidth = 800}
  );
  local selectedAction, setSelectedAction = React.useState(nil :: ClientAction?);

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

  end, {props.selectedArchetype :: any, selectedAction});

  local containerRef = React.useRef(nil :: GuiObject?);
  React.useEffect(function()
  
    local container = containerRef.current;
    if container then

      print(UDim2.new(1, if props.shouldHide then container.AbsoluteSize.X + 15 else 0, 0.5, 0))
      container.Position = UDim2.new(1, if props.shouldHide then container.AbsoluteSize.X + 15 else 0, 0.5, 0);

    end;
    
  end, {});


  React.useEffect(function(): ()
  
    local container = containerRef.current;
    if container then

      local tween = dataTypeTween({
        type = "Number";
        initialValue = container.Position.X.Offset;
        goalValue = if props.shouldHide then container.AbsoluteSize.X + 15 else 0;
        tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
        onChange = function(newValue: number)

          -- Using containerRef just in case the type of element changes.
          container = containerRef.current;
          if container then

            container.Position = UDim2.new(container.Position.X.Scale, newValue, container.Position.Y.Scale, container.Position.Y.Offset);

          end;

        end;
      });

      tween:Play();

      return function()

        tween:Cancel();

      end;

    end;

  end, {props.shouldHide});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(1, 0.5);
    BackgroundTransparency = 1;
    ref = containerRef;
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
    LayoutOrder = 2;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      HorizontalAlignment = Enum.HorizontalAlignment.Right;
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(if shouldUseIncreasedWidth then 350 else 250, math.huge);
    });
    PrimaryMetadataFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 2);
      });
      ArchetypeClassTextLabel = if props.selectedArchetype then React.createElement("TextLabel", {
        LayoutOrder = 1;
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextColor3 = Colors.HeadingText;
        TextSize = if shouldShowSecondaryMetadataFrame then 14 else 7;
        Text = props.selectedArchetype.type:upper();
        FontFace = Font.fromId(11702779517);
        TextXAlignment = Enum.TextXAlignment.Left;
      }) else nil;
      ArchetypeNameTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 2;
        TextSize = if shouldShowSecondaryMetadataFrame then 30 else 10;
        Text = if props.selectedArchetype then props.selectedArchetype.name:upper() else "CHOOSE AN ARCHETYPE";
        TextColor3 = Colors.HeadingText;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Heavy);
        TextXAlignment = Enum.TextXAlignment.Left;
      });
      ArchetypeDescriptionTextLabel = if shouldShowArchetypeDescriptionTextLabel then React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 3;
        Text = if props.selectedArchetype then props.selectedArchetype.description else "Let's take a looksie here...";
        TextWrapped = true;
        TextSize = if shouldShowSecondaryMetadataFrame then 14 else 8;
        TextColor3 = Colors.ParagraphText;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Medium);
        TextXAlignment = Enum.TextXAlignment.Left;
      }) else nil;
    });
    SecondaryMetadataFrame = if shouldShowSecondaryMetadataFrame then React.createElement("Frame", {
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
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
          Padding = UDim.new(0, 5);
        });
        ActionButtonList = React.createElement(React.Fragment, {}, actionTextButtons);
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
    }) else nil;
  });

end;

return ArchetypeInformationFrame;