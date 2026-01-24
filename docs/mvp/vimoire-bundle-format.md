# .tome Bundle Format

## Summary

Create a `.tome` bundle format (like `.docx`) that packages a complete manuscript project. Double-clicking opens it in Vimoire.

## What's Inside

A `.tome` bundle is the entire project folder:
```
MyNovel.tome/
  manuscript.json
  book.yml
  entries/
  planning/
  exports/
  assets/
  spell/
```

## How macOS Packages Work

macOS "packages" are [directories that Finder treats as single files](http://fileformats.archiveteam.org/wiki/Bundle_file_(OS_X)). The magic is in UTI (Uniform Type Identifier) registration.

From [Apple's documentation](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/AboutBundles/AboutBundles.html):
> "When you interact with the package directory, the Finder treats it like a single file."

### Registering a Package Type

In the Vimoire.app's `Info.plist`, add:

```xml
<key>CFBundleDocumentTypes</key>
<array>
  <dict>
    <key>CFBundleTypeName</key>
    <string>Vimoire Manuscript</string>
    <key>CFBundleTypeExtensions</key>
    <array>
      <string>tome</string>
    </array>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>LSTypeIsPackage</key>
    <true/>
    <key>LSItemContentTypes</key>
    <array>
      <string>dev.vimoire.manuscript</string>
    </array>
  </dict>
</array>

<key>UTExportedTypeDeclarations</key>
<array>
  <dict>
    <key>UTTypeIdentifier</key>
    <string>dev.vimoire.manuscript</string>
    <key>UTTypeDescription</key>
    <string>Vimoire Manuscript</string>
    <key>UTTypeConformsTo</key>
    <array>
      <string>com.apple.package</string>
    </array>
    <key>UTTypeTagSpecification</key>
    <dict>
      <key>public.filename-extension</key>
      <array>
        <string>vimoire</string>
      </array>
    </dict>
  </dict>
</array>
```

Key parts:
- `LSTypeIsPackage: true` — tells Finder to treat as single file
- `UTTypeConformsTo: com.apple.package` — declares it's a package type

## Git Behavior

**Git sees packages as directories** — it tracks the contents individually, not as a single opaque file. This is actually ideal for version control:

- Each prose file is tracked separately
- You see meaningful diffs for text changes
- Standard git workflow works

No special git configuration needed. The `.tome` directory is just a directory to git.

## Linux Compatibility

**Linux has no package concept.** The `.tome` extension would just be a regular directory.

Options:
1. **Accept it** — on Linux, `MyNovel.tome` is a folder, users `cd` into it
2. **Zip archive mode** — support `.tome` as zip file (like `.docx` actually is)
3. **Different extension on Linux** — just use the folder without extension

Recommendation: Start with option 1. Linux users are comfortable with directories. If demand exists, add zip support later.

## Double-Click to Open

Once the UTI is registered, macOS will:
1. Associate `.tome` with Vimoire.app
2. Pass the path to the app when double-clicked
3. Vimoire opens with that manuscript loaded

The app launch script needs to accept a path argument:
```bash
#!/bin/bash
NVIM_APPNAME=vimoire neovide -- "$1"
```

And the neovim startup needs to detect and load the manuscript path.

## Creating New Manuscripts

Options:
1. **From app** — File → New Manuscript → choose location, creates `.tome` folder
2. **CLI** — `vimoire new MyNovel` creates `MyNovel.tome/` with scaffold
3. **Template** — copy a starter `.tome` bundle

## Migration

Existing projects (plain folders) can become bundles by:
1. Adding `.tome` extension to folder name
2. That's it — contents unchanged

## Open Questions

1. Should we support zip-based bundles for portability/email?
2. Icon for `.tome` files in Finder — need to create `.icns`
3. Quick Look preview support — show book title/word count?

## References

- [Apple: About Bundles](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/AboutBundles/AboutBundles.html)
- [Bundle file format](http://fileformats.archiveteam.org/wiki/Bundle_file_(OS_X))
- [Apple: UTI Overview](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html)
