# TopOnVungleAdapter

Custom TopOn Vungle adapter packaged for CocoaPods.

## Installation

```ruby
target 'YourApp' do
  pod 'AnyThinkiOS', '= 6.5.45'
  pod 'TopOnVungleAdapter', '= 1.0.0'
end
```

`TopOnVungleAdapter` depends on `VungleAds` `7.7.2`. Do not also add
`AnyThinkiOS/AnyThinkVungleAdapter`, otherwise the Vungle adapter will be linked
twice.

## Notes

- The adapter binary comes from the TopOn SDK download center for TopOn iOS SDK
  `6.5.45`.
- Test rewarded video, interstitial, banner/native if used, close callbacks, load
  failures, impression callbacks, and revenue callbacks before shipping.
