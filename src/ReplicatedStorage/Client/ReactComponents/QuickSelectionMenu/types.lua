--!strict
export type QuickSelectMenuOption = {
  key: unknown;
  labelText: string;
  iconImage: string;
}

export type QuickSelectionMenuProperties = {
  options: {QuickSelectMenuOption};
  onSelectionConfirmed: (selection: QuickSelectMenuOption) -> ();
}

export type SelectionListProperties = {
  options: {QuickSelectMenuOption};
  selectedOption: QuickSelectMenuOption?;
  onSelectionConfirmed: (selection: QuickSelectMenuOption) -> ();
}

export type ControlGuideProperties = {
  options: {QuickSelectMenuOption};
  selectedOption: QuickSelectMenuOption?;
  onSelectionChanged: (selection: QuickSelectMenuOption) -> ();
}

return {};