---
description: Build and publish a new app version to GitHub Releases
---
1.  **Check Previous Version**
    Check the current version in `pubspec.yaml` to know what to bump from.

2.  **Bump Version**
    Update `version` in `pubspec.yaml`.
    Format: `Major.Minor.Patch+BuildNumber`.
    Example: `1.0.7+8` -> `1.0.8+9`.

3.  **Update Dependencies**
    // turbo
    Run `flutter pub get` to ensure `pubspec.lock` matches the new version.

4.  **Build Linux Binary**
    // turbo
    Run `make build-linux`.
    *This requires Docker running on your Mac.* 
    Expected output: `build/game_size_manager_linux.zip`.

5.  **Commit Changes**
    Add and commit the version bump and build artifacts/lockfiles if any.
    ```bash
    git add pubspec.yaml pubspec.lock
    git commit -m "chore: bump version to vX.Y.Z"
    ```

6.  **Tag Release**
    Tag the commit with the new version (e.g., `v1.0.8`).
    ```bash
    git tag vX.Y.Z
    ```

7.  **Push to GitHub**
    Push the commit and the tag.
    ```bash
    git push origin main --tags
    ```

8.  **Draft Changelog**
    List commits since the last release to create a nice changelog.
    ```bash
    git log --oneline $(git describe --tags --abbrev=0 HEAD^)..HEAD
    ```
    *Use this output to write a summary with emojis!*

9.  **Publish Release**
    Create the release on GitHub with the artifact.
    *Replace `vX.Y.Z` and the notes with your actual values.*
    ```bash
    gh release create vX.Y.Z build/game_size_manager_linux.zip --title "vX.Y.Z - [Feature Name]" --notes "## 🚀 Changes..."
    ```
