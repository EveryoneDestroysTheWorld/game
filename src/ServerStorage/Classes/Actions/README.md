# ServerActions
See [ServerAction.lua](../ServerAction.lua) for more information on what ClientActions are.

## Design philosophy
* Design server actions as if any archetype can use them. In v1, users will be able to mix up actions and create custom archetypes.
* Assume bots can use actions too. For example, you should get the character from `contestant.character` instead of `contestant.player.Character` in most cases.