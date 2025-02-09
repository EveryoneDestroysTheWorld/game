--!strict

export type HUDButtonProperties = {
  key: string;
  type: "Action" | "Item";
  onActivate: () -> ();
  shortcutCharacter: string;
  iconImage: string?;
};

return {}