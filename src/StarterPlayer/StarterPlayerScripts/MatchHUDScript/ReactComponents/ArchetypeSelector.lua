
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local ClientArchetype = require(ReplicatedStorage.Client.Classes.ClientArchetype);

export type ArchetypeSelectorProperties = {

}

local function ArchetypeSelector(properties: ArchetypeSelectorProperties)

  local archetypes, setArchetypes = React.useState({});
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

  return React.createElement("Frame", {
    LayoutOrder = 2;
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
  }, {
    ArchetypeCategorySelector = React.createElement(Button, {
      LayoutOrder = 1;
      Text = "FAVORITES";
    });
  });

end;

return ArchetypeSelector;