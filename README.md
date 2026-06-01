# TopOnVungleAdapter

Custom TopOn Vungle adapter packaged for CocoaPods.

## Installation

```ruby
target 'YourApp' do
  pod 'TopOnVungleAdapter', '= 1.0.3'
end
```

`TopOnVungleAdapter` depends on `TPNiOS` and `VungleAds` `7.7.3`.
Do not also add `AnyThinkiOS` or `TPNMediationVungleAdapter`, otherwise the
TopOn SDK or Vungle adapter will be linked twice.

## Notes

- The adapter binary comes from the TopOn SDK download center.
- The app or upstream SDK should control the concrete `TPNiOS` version.
- Test rewarded video, interstitial, banner/native if used, close callbacks, load
  failures, impression callbacks, and revenue callbacks before shipping.

## Publishing

See [PUBLISHING.md](PUBLISHING.md) for the full create, validate, SourceTree,
GitHub token, and CocoaPods Trunk publishing workflow.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
