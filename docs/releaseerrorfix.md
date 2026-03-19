# Technical Report: Android ClassNotFoundException Fix

## 1. The Error
**Message**: `java.lang.ClassNotFoundException: Didn't find class "org.korelium.koraexpensetracker.MainActivity"`
**Symptom**: The app builds and installs successfully but crashes immediately upon opening with a "Fatal Exception" in the Android Runtime.

## 2. The Cause: Package Mismatch
When you rename an app's package name (e.g., from `com.example` to `org.korelium`), three things must match perfectly:
1.  **Gradle Namespace**: The `namespace` in [android/app/build.gradle.kts](cci:7://file:///home/kora/dev-workspace/flutter/main/kora_expense_tracker/android/app/build.gradle.kts:0:0-0:0).
2.  **Physical Folder Structure**: The directory where [MainActivity.kt](cci:7://file:///home/kora/dev-workspace/flutter/main/kora_expense_tracker/android/app/src/main/kotlin/org/korelium/koraexpensetracker/MainActivity.kt:0:0-0:0) resides.
3.  **Package Declaration**: The first line of [MainActivity.kt](cci:7://file:///home/kora/dev-workspace/flutter/main/kora_expense_tracker/android/app/src/main/kotlin/org/korelium/koraexpensetracker/MainActivity.kt:0:0-0:0).

In this case, the Gradle file was updated to `org.korelium.koraexpensetracker`, but the Kotlin file was still stuck in the old `com/example/...` folder and was still declaring itself as part of the old package.

## 3. The Solution
1.  **Re-structuring**: Created the directory `android/app/src/main/kotlin/org/korelium/koraexpensetracker/`.
2.  **Relocation**: Moved `MainActivity.kt` into that new directory.
3.  **Code Update**: Changed the first line of `MainActivity.kt` to `package org.korelium.koraexpensetracker`.
4.  **Clean Build**: Running `flutter clean` is required to force Android to discard the old "DEX" files and recognize the new class path.

## 4. Current Status
The code is now correctly aligned. Once the build cache is cleared, the Android OS will be able to find and launch the `MainActivity` class successfully.
