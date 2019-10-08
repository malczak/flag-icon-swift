# flag-icon-swift

🎏 A collection of all country flags to be used in iOS apps

A collection of all country flags in PNG — plus the sprite sheet for iOS apps and Swift class for accessing country flags by country code ([ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2))

## Usage

Simple use case

```swift
    if let flagSheet = FlagIcons.loadDefault() {
        let image = flagSheet.getImageFor("PL")
        // ...
    }
```

In the example above created image is reusing a memory already allocated to store flags sheet. Image is valid as long as `flagSheet` exists. Underlying `UIImage` is cached and shared between calls, cache can be flushed with `flagSheet?.flushCache()` call.

Use `deepCopy` parameter to create copy of a flag image. Underlying bytes will be copied over to new image data

```swift
    if let flagSheet = FlagIcons.loadDefault() {
        let image = flagSheet.getImageFor("PL", deepCopy: true)
        // ...
    }
```

Additionaly its possible to get country names

```swift
    if let countries = FlagIcons.loadCountries() {
        if let country = countries.first(where: { $0.code == "PL" }) {
            print(country.name) // output: Poland
        }
    }
```

### Production use

This repo is used in one of my apps - [Last Day? Life progress and stats](https://apps.apple.com/us/app/last-day-track-events-life/id1193076940?ign-mpt=uo%3D4)

### Sample application

For usage example please see sample country flags application

```

> cd FlagIconSample
> pod install

```

<img alt="Sample Flags App" src="https://raw.githubusercontent.com/malczak/flag-icon-swift/master/FlagIconSample/flags-sample-screen.png" height="640" />

## Credits

This project wouldn't exist without the awesome [flag-ison-css](https://github.com/lipis/flag-icon-css)

```

```
