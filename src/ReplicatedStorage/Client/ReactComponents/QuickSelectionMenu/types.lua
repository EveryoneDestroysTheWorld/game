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
  selectionKey: unknown;
  onSelectionConfirmed: (selection: QuickSelectMenuOption) -> ();
}

return {};