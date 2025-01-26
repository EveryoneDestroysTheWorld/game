--!strict
export type QuickSelectMenuOption = {
  key: unknown;
  labelText: string;
  iconImage: string;
  onConfirmed: () -> ();
}

export type QuickSelectionMenuProperties = {
  options: {QuickSelectMenuOption};
  selectionKey: unknown?;
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