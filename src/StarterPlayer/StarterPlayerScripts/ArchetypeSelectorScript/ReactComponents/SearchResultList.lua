--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ContextActionService = game:GetService("ContextActionService");
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;
local mapTable = require(ReplicatedStorage.Shared.Modules.mapTable);
local filterTable = require(ReplicatedStorage.Shared.Modules.filterTable);
local SearchResultButton = require(script.Parent.SearchResultButton);
local HttpService = game:GetService("HttpService");

export type SearchResultListProperties = {
  archetypeIDs: {string};
  query: string;
}

local function SearchResultList(properties: SearchResultListProperties)

  local cachedArchetypes, setCachedArchetypes = React.useState(nil :: {ClientArchetype}?);
  local filteredArchetypeIDs, setFilteredArchetypeIDs = React.useState({} :: {string});
  local selectionIndex, setSelectionIndex = React.useState(1);

  React.useEffect(function(): ()

    task.spawn(function()

      -- Include owned archetypes in the search pool.
      local archetypes = cachedArchetypes;

      if not archetypes then

        archetypes = mapTable(properties.archetypeIDs, function(archetypeID)
      
          return ClientArchetype.get(archetypeID);
  
        end);
  
        setCachedArchetypes(archetypes);

      end;

      -- Exclude archetypes that don't meet the query.
      local filteredArchetypes = filterTable(archetypes, function(archetype)
      
        return properties.query == "" or not not archetype.name:lower():find(properties.query:lower());

      end);

      -- Only store the table indices to save memory.
      local archetypeIDs = mapTable(filteredArchetypes, function(archetype)
      
        return archetype.id;

      end);

      setFilteredArchetypeIDs(archetypeIDs);

      -- Reset the selection if the list changes.
      if HttpService:JSONEncode(archetypeIDs) ~= HttpService:JSONEncode(archetypeIDs) then

        setSelectionIndex(1);

      end;

    end);

  end, {properties.query :: unknown, properties.archetypeIDs});

  React.useEffect(function()
  
    task.spawn(function()
    
      local function updateSelection()

      end;

      ContextActionService:BindAction("UpdateArchetypeSelection", updateSelection, false, Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown)

    end);

    return function()

      ContextActionService:UnbindAction("UpdateArchetypeSelection");

    end;

  end, {});

  -- TODO: Sort this.
  local filteredArchetypes = if cachedArchetypes then
    filterTable(cachedArchetypes, function(archetype)
    
      return not not table.find(filteredArchetypeIDs, archetype.id);

    end)
  else nil;

  local searchResultComponents = {};
  if filteredArchetypes then

    for possibleSelectionIndex, archetype in filteredArchetypes do

      local component = React.createElement(SearchResultButton, {
        LayoutOrder = possibleSelectionIndex;
        key = archetype.id,
        title = archetype.name;
        description = archetype.description;
        isSelected = possibleSelectionIndex == selectionIndex;
        iconImage = archetype.iconImage;
        onActivate = function()

          ReplicatedStorage.Shared.Functions.UpdateContestantArchetype:InvokeServer(archetype.id);

        end;
      });

      table.insert(searchResultComponents, component);

    end

  end;

  return React.createElement("ScrollingFrame", {
    BackgroundTransparency = 1;
    LayoutOrder = 2;
    Size = UDim2.new(1, 0, 0, 0);
    BorderSizePixel = 0;
    CanvasSize = UDim2.new();
    AutomaticCanvasSize = Enum.AutomaticSize.Y;
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
    TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
    BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
  }, {
    UIFlexItem = React.createElement("UIFlexItem", {
      FlexMode = Enum.UIFlexMode.Fill;
    });
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(700, math.huge);
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingRight = UDim.new(0, 5);
    });
    searchResultComponents = React.createElement(React.Fragment, {}, searchResultComponents);
  });

end;

return SearchResultList;