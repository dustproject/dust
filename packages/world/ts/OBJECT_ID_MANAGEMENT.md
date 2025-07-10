# Object ID Management

This document describes the object ID management system implemented to prevent accidental ID changes in deployed smart contracts.

## Overview

Previously, object IDs were determined by array position in `objectDef`, which created deployment risks when objects were inserted in the middle of the array. Now, every object has an explicit `id` field to prevent accidental changes.

## ID Ranges

| Range | Purpose | Description |
|-------|---------|-------------|
| 0-999 | Blocks & Items | Terrain blocks, building materials, basic items |
| 32768-65535 | Tools & Special | Tools, weapons, and special game items |

## Adding New Objects

### 1. Find Next Available ID

Use the ID helper script to find the next available ID:

```bash
# For blocks/items
pnpm tsx scripts/idHelper.ts suggest block

# For tools
pnpm tsx scripts/idHelper.ts suggest tool

# Or analyze current usage
pnpm tsx scripts/idHelper.ts analyze
```

### 2. Add Object with Explicit ID

Always add new objects with explicit IDs:

```typescript
// Good ✅
{ name: "NewBlock", id: 366, mass: 1000000000000000n }

// Bad ❌ - Never rely on position for ID
{ name: "NewBlock", mass: 1000000000000000n }
```

### 3. Add to End of Array

**CRITICAL**: Always add new objects at the end of their category section in `objectDef`. Never insert in the middle.

### 4. Validate Your Changes

Run validation before committing:

```bash
pnpm tsx scripts/validateObjectIds.ts
```

## Validation Scripts

### `validateObjectIds.ts`
Comprehensive validation that checks for:
- Duplicate IDs
- Missing explicit IDs
- Invalid ID ranges
- Consistency issues

```bash
pnpm tsx scripts/validateObjectIds.ts
```

### `idHelper.ts`
Helper utilities for ID management:

```bash
# Show usage analysis
pnpm tsx scripts/idHelper.ts analyze

# Find next available ID
pnpm tsx scripts/idHelper.ts next blocks

# Suggest ID for new object
pnpm tsx scripts/idHelper.ts suggest tool

# Validate proposed ID
pnpm tsx scripts/idHelper.ts validate 500 "NewObject"
```

## Emergency Procedures

### If ID Conflicts Are Found

1. **Stop**: Do not deploy until conflicts are resolved
2. **Identify**: Use validation script to find all conflicts
3. **Fix**: Assign unique IDs to conflicting objects
4. **Validate**: Re-run validation to confirm fixes
5. **Test**: Verify that Solidity generation still works

### If Objects Were Added Incorrectly

1. **Don't panic**: IDs can be reassigned before deployment
2. **Check impact**: Ensure no deployed contracts use the wrong IDs
3. **Reassign**: Move objects to correct ID ranges
4. **Document**: Update any references to the old IDs

## Best Practices

1. **Always use explicit IDs** - Never rely on array position
2. **Add at the end** - Never insert objects in the middle of arrays
3. **Use ID ranges appropriately** - Blocks in 0-999, tools in 32768+
4. **Validate early and often** - Run validation scripts before committing
5. **Plan ahead** - Leave gaps in ID sequences for future expansion
6. **Document changes** - Note why specific IDs were chosen

## Troubleshooting

### "Duplicate ID" Error
Two objects have the same ID. Use the validation script to identify conflicts and assign unique IDs.

### "ID outside expected range" Warning
Object ID is outside defined ranges. Consider moving to appropriate range or documenting why it's necessary.

### "Very large ID" Warning
ID is >100,000, possibly a typo. Double-check the intended ID value.

### Build Failures
If Solidity generation fails after ID changes, verify that:
- All IDs are unique and valid
- No circular dependencies exist
- Object names match exactly between arrays
