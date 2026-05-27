# TopOnVungleAdapter

Custom TopOn Vungle adapter packaged for CocoaPods.

## Installation

```ruby
target 'YourApp' do
  pod 'TPNiOS', '= 6.5.45'
  pod 'TopOnVungleAdapter', '= 1.0.1'
end
```

`TopOnVungleAdapter` depends on `TPNiOS` `6.5.45` and `VungleAds` `7.7.2`.
Do not also add `AnyThinkiOS` or `TPNMediationVungleAdapter`, otherwise the
TopOn SDK or Vungle adapter will be linked twice.

## Notes

- The adapter binary comes from the TopOn SDK download center for TopOn iOS SDK
  `6.5.45`.
- Test rewarded video, interstitial, banner/native if used, close callbacks, load
  failures, impression callbacks, and revenue callbacks before shipping.

## Publishing

See [PUBLISHING.md](PUBLISHING.md) for the full create, validate, SourceTree,
GitHub token, and CocoaPods Trunk publishing workflow.
