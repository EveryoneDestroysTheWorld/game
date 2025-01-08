
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

export type ArchetypeSelectorProperties = {
  onArchetypeSelected: (archetype: ClientArchetype) -> ();
}

local function ArchetypeSelector(properties: ArchetypeSelectorProperties)

  local archetypes, setArchetypes = React.useState({} :: {ClientArchetype});
  React.useEffect(function()
  
    task.spawn(function()
    
      local archetypeIDs = ReplicatedStorage.Shared.Functions.GetArchetypeIDs:InvokeServer();
      local newArchetypes = {};
      for _, archetypeID in archetypeIDs do

        table.insert(newArchetypes, ClientArchetype.get(archetypeID));

      end;

      setArchetypes(newArchetypes);

    end);

  end, {});

  local archetypeComponents = {};
  for _, archetype in archetypes do

    table.insert(archetypeComponents, React.createElement(Button, {
      Image = archetype.iconImage;
      key = archetype.id;
      [React.Event.Activated] = function()

        properties.onArchetypeSelected(archetype);

      end;
    }));

  end;

  return React.createElement("Frame", {
    LayoutOrder = 2;
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
  }, {
    -- TODO: Implement category selector.
    ArchetypeOptionList = React.createElement(React.Fragment, {}, archetypeComponents);
  });

end;

return ArchetypeSelector;