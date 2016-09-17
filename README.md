# flag-icon-swift
🎏 A collection of all country flags to be used in iOS apps

A collection of all country flags in PNG — plus the sprite sheet for iOS apps and Swift class for accessing country flags by country code ([ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2))

## Usage

Simple use case

```swift
if let flagSheet = FlagIcons.loadSheetFrom(infoFile) {
	let image = flagSheet.getImageFor("PL")
}
```
In the example above created image is reusing a memory already allocated to store flags sheet. Image is valid as long as ```flagSheet``` exists. 

Use ```deepCopy``` parameter to create copy of a flag image. Underlying bytes will be copied over to new image data
```swift
if let flagSheet = FlagIcons.loadSheetFrom(infoFile) {
	let image = flagSheet.getImageFor("PL", deepCopy: true)
}
```

## Credits

This project wouldn't exist without the awesome [flag-ison-css](https://github.com/lipis/flag-icon-css)