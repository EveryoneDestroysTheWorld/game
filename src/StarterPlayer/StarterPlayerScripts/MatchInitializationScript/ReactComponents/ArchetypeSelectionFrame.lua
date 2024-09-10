--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Players = game:GetService("Players");
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local ClientAction = require(ReplicatedStorage.Client.Classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local ArchetypeCategoryFrame = require(script.Parent.ArchetypeCategoryFrame);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type ArchetypeInformationFrameProps = {
  selectedArchetype: ClientArchetype?;
  isConfirmingArchetype: boolean;
  onSelectionChanged: (newArchetype: ClientArchetype) -> ();
  onSelectionConfirmed: () -> ();
}

local function ArchetypeSelectionFrame(props: ArchetypeInformationFrameProps)

  local archetypeIDs, setArchetypeIDs = React.useState({});
  local confirmedArchetypeID, setConfirmedArchetypeID = React.useState(nil);

  -- Get a list of all owned archetypes.
  React.useEffect(function()
  
    task.spawn(function()

      setArchetypeIDs(ReplicatedStorage.Shared.Functions.GetArchetypeIDs:InvokeServer());

      ReplicatedStorage.Shared.Events.ArchetypePrivatelyChosen.OnClientEvent:Connect(function(contestantID, archetypeID)
          
        if contestantID == Players.LocalPlayer.UserId then 

          setConfirmedArchetypeID(archetypeID);

        end;
    
      end);

    end);

  end, {});

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

    archetypeCategoryFrames[`{type}Frame`] = React.createElement(ArchetypeCategoryFrame, {
      type = type;
      archetypes = archetypes;
      isDisabled = props.isConfirmingArchetype;
      selectedArchetype = props.selectedArchetype;
      onArchetypeSelected = props.onSelectionChanged;
    });

  end;

  local shouldUseFullSpacing = useResponsiveDesign({minimumWidth = 700});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
    BackgroundTransparency = 1;
    AnchorPoint = Vector2.new(0, 1);
    Position = UDim2.new(0, 0, 1, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, if shouldUseFullSpacing then 15 else 5);
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });
    ConfirmButton = React.createElement(Button, {
      text = "CONFIRM";
      LayoutOrder = 1;
      textSize = if shouldUseFullSpacing then 12 else 8;
      isDisabled = props.isConfirmingArchetype or props.selectedArchetype == nil or props.selectedArchetype.ID == confirmedArchetypeID;
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
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, if shouldUseFullSpacing then 15 else 5);
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
      });
      ArchetypeCategoryFrames = React.createElement(React.Fragment, {}, archetypeCategoryFrames);
    });
  });

end;

return ArchetypeSelectionFrame;