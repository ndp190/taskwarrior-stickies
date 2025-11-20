#!/bin/bash
# SwiftLint script for TaskWarriorStickies

echo "Running SwiftLint..."
swiftlint lint --config .swiftlint.yml Sources/
swiftlint lint --config .swiftlint.yml Tests/

echo "SwiftLint completed."
