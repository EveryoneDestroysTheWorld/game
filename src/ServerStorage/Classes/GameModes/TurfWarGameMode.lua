--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local GameMode = require(script.Parent.Parent.GameMode);

-- This is the class.
local TurfWarGameMode = setmetatable({
  __index = {} :: GameMode.GameModeProperties<TurfWarGameMode>; -- Keeps IntelliSense working in the methods.
  defaultProperties = {
    ID = 1;
    name = "Turf War";
    description = "";
    stats = {};
    events = {};
  }
}, GameMode);

export type TurfWarStats = {
  [number]: {
    place: number;
    partsDestroyed: number;
    partsRestored: number;
    timesDowned: number;
    playersDowned: number;
  };
};

local actionProperties: GameMode.GameModeProperties<{stats: TurfWarStats; events: {RBXScriptConnection}}> = TurfWarGameMode.defaultProperties;

-- Although it has the same name, this is the object type.
export type TurfWarGameMode = typeof(setmetatable(GameMode.new(actionProperties), {__index = TurfWarGameMode.__index}));

-- Returns a new action based on the user.
-- @since v0.1.0
function TurfWarGameMode.new(): TurfWarGameMode

  local gameMode = setmetatable(GameMode.new(actionProperties), TurfWarGameMode.__index);

  return gameMode;

end

-- @since v0.1.0
function TurfWarGameMode.__index:start(stageModel: Model): ()

  -- Keep track of destroyed parts.
  for _, child in ipairs(stageModel:GetChildren()) do

    if child:IsA("BasePart") and child:GetAttribute("BaseDurability") then

      table.insert(self.events, child:GetAttributeChangedSignal("CurrentDurability"):Connect(function()
      
        local destroyerID = child:GetAttribute("DestroyerID");
        if destroyerID then

          -- Add this to the score.


        else

          -- Make sure no one has this part in their score.


        end;

      end));

    end;

  end;

  -- Keep track of downed players.
  table.insert(self.events, ServerStorage.Events.ParticipantDowned.Event:Connect(function(victim: Player, downer: Player?)
  
    -- Add it to their score.


  end));

  -- Keep track of restored parts.

end;

function TurfWarGameMode.__index:breakdown()

  -- Disconnect all events.
  for _, event in ipairs(self.events) do

    event:Disconnect();

  end;

end;

return TurfWarGameMode;