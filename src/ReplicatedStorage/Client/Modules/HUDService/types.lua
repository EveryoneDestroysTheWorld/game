--!strict

export type HUDButtonProperties = {
  key: string;
  type: "Action" | "Item";
  onActivate: () -> ();
  shortcutCharacter: string?;
  description: string?;
  iconImage: string?;
};

return {}