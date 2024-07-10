--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Popup = require(script.Parent.Popup);
local Button = require(script.Parent.Button);
local ParagraphTextLabel = require(script.Parent.ParagraphTextLabel);
local TeleportService = game:GetService("TeleportService");

local function MatchStoppagePopup()

  local isReturningToLobby, setIsReturningToLobby = React.useState(false);
  local didTeleportFail, setDidTeleportFail = React.useState(false);

  React.useEffect(function()
  
    if isReturningToLobby then

      -- TODO: Replace with production start place ID.
      local isTeleportSuccessful = pcall(function()
      
        TeleportService:Teleport(15555144468)

      end);

      if not isTeleportSuccessful then

        setDidTeleportFail(true);

      end;

    end;

  end, {isReturningToLobby});

  return React.createElement(Popup, {
    headingText = "We demo'd DemoDemons";
    options = if didTeleportFail then nil else {
      ConfirmButton = React.createElement(Button, {
        text = "Return to lobby";
        isDisabled = isReturningToLobby;
        onClick = function()

          setIsReturningToLobby(true);

        end;
        LayoutOrder = 1;
      });
    }
  }, {
    MessageLabel = if didTeleportFail then (
      React.createElement(ParagraphTextLabel, {
        text = "We couldn't teleport you back to the lobby due to an error. Please rejoin the game.";
      })
    ) else (
        React.createElement(ParagraphTextLabel, {
        text = "Pardon the interruption. The server encountered a critical error, so the round cannot continue. If this happens frequently, let us know using the feedback window in Settings.";
      }) 
    );
  });

end;

return MatchStoppagePopup;