#!/bin/bash

# Set package info
PACKAGE_NAME=$(node -p "require('./package.json').name")
DIST_DIR="dist/@ngfly/carousel"

# Copy README, CHANGELOG and LICENSE
echo "Copying README, CHANGELOG and LICENSE..."
npm run prepare:package

# Find actual ESM bundle file names
ESM2020_FILE=$(find "$DIST_DIR/esm2020" -name "*.mjs" | head -n 1)
FESM2020_FILE=$(find "$DIST_DIR/fesm2020" -name "*.mjs" | head -n 1)
FESM2015_FILE=$(find "$DIST_DIR/fesm2015" -name "*.mjs" | head -n 1)

# Optimize ESM bundles with terser (only if files exist)
echo "Optimizing ESM bundles with terser..."

if [ -n "$ESM2020_FILE" ] && [ -f "$ESM2020_FILE" ]; then
  echo "Optimizing $ESM2020_FILE"
  npx terser --compress --mangle --ecma 2020 --module --comments false -o "$ESM2020_FILE" "$ESM2020_FILE"
fi

if [ -n "$FESM2020_FILE" ] && [ -f "$FESM2020_FILE" ]; then
  echo "Optimizing $FESM2020_FILE"
  npx terser --compress --mangle --ecma 2020 --module --comments false -o "$FESM2020_FILE" "$FESM2020_FILE"
fi

if [ -n "$FESM2015_FILE" ] && [ -f "$FESM2015_FILE" ]; then
  echo "Optimizing $FESM2015_FILE"
  npx terser --compress --mangle --ecma 2020 --module --comments false -o "$FESM2015_FILE" "$FESM2015_FILE"
fi

# Try to optimize component files if they exist
CAROUSEL_COMPONENT=$(find "$DIST_DIR" -name "carousel.component.mjs" | head -n 1)
if [ -n "$CAROUSEL_COMPONENT" ] && [ -f "$CAROUSEL_COMPONENT" ]; then
  echo "Optimizing $CAROUSEL_COMPONENT"
  npx terser --compress --mangle --ecma 2020 --module --comments false -o "$CAROUSEL_COMPONENT" "$CAROUSEL_COMPONENT"
fi

# Try to optimize animation utils if they exist
ANIMATION_UTILS=$(find "$DIST_DIR" -name "animation.mjs" | head -n 1)
if [ -n "$ANIMATION_UTILS" ] && [ -f "$ANIMATION_UTILS" ]; then
  echo "Optimizing $ANIMATION_UTILS"
  npx terser --compress --mangle --ecma 2020 --module --comments false -o "$ANIMATION_UTILS" "$ANIMATION_UTILS"
fi

# Remove source maps to reduce size
echo "Removing source maps..."
find "$DIST_DIR" -name "*.map" -type f -delete

# Remove test files
echo "Removing test files..."
find "$DIST_DIR" -name "*.spec.*" -type f -delete

# File sizes
echo "Final package size:"
du -sh "$DIST_DIR"

echo "Done! Package is optimized for production." 