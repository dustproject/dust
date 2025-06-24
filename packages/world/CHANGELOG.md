# Changelog

## 2024-06-24

- Use chunk randomness for tree growth.
- Allow planting saplings on moss.

## 2024-06-23

- Pack move directions in a single uint256 to decrease tx calldata size.
- New transferAmounts function that doesn't require specifying destination slots, which simplifies app interactions with chests.
- Fix: Lazily assign mass on mine for blocks that were set up incorrectly.
- Fix: Don't revert if trying to pickup multiple drops that don't fit in the inventory.

## 2024-06-16

- Wake up player when mining their bed instead of killing them.
- Prevent mining forcefields and adding/removing fragments if there are players sleeping inside.
- Fix: Seeds and saplings in circulation were not being tracked correctly.
- Fix: Correctly set mass of crops and trees grown from seeds and saplings.
- Fix: Support waking up for players that had their forcefields mined while sleeping.
