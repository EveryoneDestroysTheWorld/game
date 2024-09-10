--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

export type Condition = {
  minimumHeight: number?;
  minimumWidth: number?;
}

local function useResponsiveDesign(...: Condition): ...boolean

  local viewportSize, setViewportSize = React.useState(workspace.CurrentCamera.ViewportSize);

  React.useEffect(function()
  
    local viewportSizeChangedEvent = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    
      setViewportSize(workspace.CurrentCamera.ViewportSize);

    end);

    return function()

      viewportSizeChangedEvent:Disconnect();

    end;

  end, {});

  local results = {};
  for _, condition in ipairs(table.pack(...)) do

    local minimumWidth = condition.minimumWidth;
    local minimumHeight = condition.minimumHeight;
    local passesMinimumWidth = not minimumWidth or viewportSize.X >= minimumWidth;
    local passesMinimumHeight = not minimumHeight or viewportSize.Y >= minimumHeight;
    table.insert(results, passesMinimumWidth and passesMinimumHeight);

  end;

  return table.unpack(results);

end;

return useResponsiveDesign;