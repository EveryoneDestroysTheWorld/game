--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local KeybindNotification = require(script.Components.KeybindNotification);

local KeybindNotificationService = {
  gui = nil :: ScreenGui?;
  guiRoot = nil :: ReactRoblox.RootType?;
}

function KeybindNotificationService:initializeGUI(): ()

  local player = Players.LocalPlayer;
  local keybindNotificationGUI = Instance.new("ScreenGui");
  keybindNotificationGUI.Name = "KeybindNotificationGUI";
  keybindNotificationGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  keybindNotificationGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  keybindNotificationGUI.ResetOnSpawn = false;
  keybindNotificationGUI.DisplayOrder = 1;
  keybindNotificationGUI.Enabled = true;
  keybindNotificationGUI.Parent = player.PlayerGui;

  KeybindNotificationService.gui = keybindNotificationGUI;
  KeybindNotificationService.guiRoot = ReactRoblox.createRoot(keybindNotificationGUI);

end;

function KeybindNotificationService:setMessage(message: string): ()

  local function destroyGUI()

    if KeybindNotificationService.guiRoot then

      KeybindNotificationService.guiRoot:unmount();

    end;

    if KeybindNotificationService.gui then

      KeybindNotificationService.gui:Destroy();
      KeybindNotificationService.gui = nil;

    end;

  end;

  destroyGUI();

  KeybindNotificationService:initializeGUI();

  assert(KeybindNotificationService.guiRoot);
  KeybindNotificationService.guiRoot:render(
    React.createElement(KeybindNotification, {
      message = message;
      onClose = function()

        destroyGUI();

      end;
    }
  ));

end;

return KeybindNotificationService;