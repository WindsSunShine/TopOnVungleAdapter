# TopOn Vungle Adapter CocoaPods 发布手册

这份文档用于以后重新创建、升级、验证并公开发布 `TopOnVungleAdapter`。示例以当前仓库为准：

- GitHub 仓库：`https://github.com/WindsSunShine/TopOnVungleAdapter.git`
- Pod 名称：`TopOnVungleAdapter`
- TopOn SDK：`TPNiOS 6.5.45`
- Vungle SDK：`VungleAds 7.7.2`
- 当前发布版本：`1.0.1`

## 1. 准备文件

从 TopOn 下载对应平台的 iOS SDK 包，确认里面包含：

- `AnyThinkVungleAdapter.xcframework`
- TopOn 主 SDK 版本号，例如 `6.5.45`
- Vungle 官方 SDK 版本号，例如 `7.7.2`

当前项目只打包 TopOn 的 Vungle Adapter，不要把 `VungleAdsSDK.xcframework` 复制进本仓库。Vungle 官方 SDK 通过 CocoaPods 依赖声明：

```ruby
s.dependency 'VungleAds', '= 7.7.2'
```

这样可以避免 App 同时链接两份 Vungle SDK。

## 2. 创建工程目录

第一次创建时：

```bash
mkdir TopOnVungleAdapter
cd TopOnVungleAdapter
git init
mkdir -p Frameworks
```

复制 TopOn 下载包里的 adapter：

```bash
cp -R /path/to/AnyThinkVungleAdapter.xcframework Frameworks/
```

建议目录结构：

```text
TopOnVungleAdapter/
  Frameworks/
    AnyThinkVungleAdapter.xcframework/
  LICENSE
  README.md
  TopOnVungleAdapter.podspec
```

## 3. 创建 podspec

创建 `TopOnVungleAdapter.podspec`：

```ruby
Pod::Spec.new do |s|
  s.name         = 'TopOnVungleAdapter'
  s.version      = '1.0.1'
  s.summary      = 'Custom TopOn Vungle adapter for iOS.'
  s.description  = 'Custom TopOn Vungle adapter packaged as a CocoaPods binary dependency.'

  s.homepage     = 'https://github.com/WindsSunShine/TopOnVungleAdapter'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'WindsSunShine' => 'zhangjianjunapple@gmail.com' }

  s.platform     = :ios, '12.0'
  s.source       = {
    :git => 'https://github.com/WindsSunShine/TopOnVungleAdapter.git',
    :tag => s.version.to_s
  }

  s.static_framework = true
  s.vendored_frameworks = 'Frameworks/AnyThinkVungleAdapter.xcframework'

  s.dependency 'TPNiOS', '= 6.5.45'
  s.dependency 'VungleAds', '= 7.7.2'

  s.frameworks = [
    'UIKit',
    'Foundation',
    'StoreKit',
    'AdSupport',
    'AppTrackingTransparency',
    'AVFoundation',
    'WebKit',
    'SystemConfiguration'
  ]

  s.libraries = ['z', 'sqlite3', 'c++']
end
```

升级版本时通常只改这几项：

- `s.version`
- `s.dependency 'TPNiOS', '= x.x.x'`
- `s.dependency 'VungleAds', '= x.x.x'`
- `Frameworks/AnyThinkVungleAdapter.xcframework`

## 4. 验证 Vungle 版本是否匹配

先用 TopOn 下载包里实际带的 Vungle 版本作为目标版本。不要只按广告平台官网最新版猜版本，因为 TopOn Adapter 编译时可能引用了某个 Vungle SDK 版本才有的类或符号。

执行：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose
```

如果报类似下面的符号错误：

```text
Undefined symbols for architecture arm64:
  "VungleAdsSDK.VungleAdSize"
  "VungleAdsSDK.VungleBannerView"
```

说明当前 `VungleAds` 版本和 TopOn Adapter 不匹配。处理方式：

1. 回到 TopOn 下载包确认内置 Vungle SDK 版本。
2. 修改 podspec 里的 `s.dependency 'VungleAds', '= 版本号'`。
3. 重新执行 `pod lib lint`。

只有 lint 成功后才继续发布。

### 4.1 为什么依赖 TPNiOS，而不是 AnyThinkiOS

TopOn 官方同时存在 `TPNiOS` 和 `AnyThinkiOS` 两个 CocoaPods 包，它们都会引入同名主 SDK：

```text
core/AnyThinkSDK.xcframework
```

如果业务工程已经使用：

```ruby
s.dependency 'TPNiOS', '= 6.5.45'
```

自定义 adapter 就不能再依赖：

```ruby
s.dependency 'AnyThinkiOS', '= 6.5.45'
```

否则执行 `pod install` 时会出现：

```text
[!] The target has frameworks with conflicting names: anythinksdk.xcframework.
```

因此当前发布版本固定使用：

```ruby
s.dependency 'TPNiOS', '= 6.5.45'
```

如果你的业务工程全量使用 `AnyThinkiOS` 体系，而不是 `TPNiOS`，需要单独发布另一个 adapter 版本或另一个 pod 名称，不能在同一个 App target 中混用 `TPNiOS` 和 `AnyThinkiOS`。

### 4.2 本次为什么先排除 7.3.1

这次一开始尝试过：

```ruby
s.dependency 'VungleAds', '= 7.3.1'
```

执行：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose
```

链接阶段失败，核心错误是：

```text
Undefined symbols:
  _OBJC_CLASS_$__TtC12VungleAdsSDK12VungleAdSize
  _OBJC_CLASS_$__TtC12VungleAdsSDK16VungleBannerView
```

这个错误的含义是：

```text
AnyThinkVungleAdapter.xcframework 这个二进制在编译时引用了 VungleAdsSDK.VungleAdSize 和 VungleAdsSDK.VungleBannerView。
但是当前链接进来的 VungleAds 7.3.1 里没有这些符号，所以最终 App 链接失败。
```

因此，`7.3.1` 不是 podspec 写法问题，而是二进制 ABI/API 不匹配。只把 podspec 改成 `7.3.1` 不能解决。要使用 `7.3.1`，必须拿到一份按 `VungleAds 7.3.1` 编译出来的 TopOn Vungle adapter，或者有源码后基于 `7.3.1` API 重新编译 adapter。

### 4.3 为什么一开始判断下载包更接近 7.7.1

排除 `7.3.1` 后，对 TopOn 下载包里的 Vungle SDK 做过二进制比对：

```text
release_folder_20260518205948/vungle/static/VungleAdsSDK.xcframework
```

它和 CocoaPods 缓存中的 `VungleAds 7.7.1` 二进制 SHA256 一致。这个结果说明：

```text
TopOn 这次下载包随包带的 Vungle SDK 原始版本是 7.7.1。
```

所以当时给出的保守判断是：

```text
如果严格按 TopOn 下载包的原始二进制版本匹配，应该使用 VungleAds 7.7.1。
```

这个判断是基于下载包原始 SDK 的二进制哈希，不是说 `7.7.2` 或 `7.7.3` 一定不能用。

### 4.4 为什么最终公开发布使用 7.7.2

随后继续验证 `VungleAds 7.7.2`：

```ruby
s.dependency 'VungleAds', '= 7.7.2'
```

执行：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose
```

结果通过：

```text
TopOnVungleAdapter passed validation.
```

这说明 `7.7.2` 至少满足 CocoaPods 解析、编译、链接层面的兼容性要求。由于 `7.7.2` 是同一条 `7.7.x` 线的 patch 版本，并且通过 lint，所以本次 `1.0.1` 选择发布为：

```ruby
s.dependency 'VungleAds', '= 7.7.2'
```

这里要区分三个层级：

1. `7.3.1`：lint 链接失败，明确不能直接配这份 adapter。
2. `7.7.1`：和 TopOn 下载包里的 Vungle 二进制哈希一致，是原始随包版本。
3. `7.7.2`：lint 通过，本次实际发布版本。

### 4.5 为什么当前发布使用 7.7.2，而不是直接使用 7.7.3

截至这次发布时，CocoaPods 上 `VungleAds` 已经有 `7.7.3`：

```bash
pod trunk info VungleAds
pod search VungleAds --simple
```

能看到：

```text
7.7.1
7.7.2
7.7.3
```

但是这个 adapter 当前公开发布仍然固定为：

```ruby
s.dependency 'VungleAds', '= 7.7.2'
```

原因不是 `7.7.3` 一定不能编译，而是发布策略要保守：

1. TopOn 的 `AnyThinkVungleAdapter.xcframework` 是一个已经编译好的二进制 adapter，它不是源码级 adapter。
2. 二进制 adapter 是否兼容某个 Vungle 版本，不能只看 CocoaPods 上有没有这个版本。
3. `pod lib lint` 只能证明依赖解析、编译、链接能通过，不能证明广告运行时行为一定正常。
4. 这次 `1.0.1` 发布实际完整验证并发布的是 `VungleAds 7.7.2`。
5. `7.7.3` 是 `2026-05-14` 发布的更新版本，和当前 TopOn adapter 下载包不是同一次验证链路。

所以当前结论应该这样写：

```text
VungleAds 7.7.3 可以作为候选版本验证，但不应该直接替换到已发布版本里。
如果要使用 7.7.3，应发布一个新的 pod 版本，例如 1.0.2，并完成 lint + App 运行时广告验证。
```

这次实测过 `7.7.3` 的临时 lint，结果是通过的：

```text
TopOnVungleAdapter passed validation.
```

但这只代表“编译链接层面可用”，还不等于“线上投放层面已经验证完成”。

### 4.6 候选 Vungle 版本的详细校验步骤

不要直接改正式 `TopOnVungleAdapter.podspec` 来试版本。建议复制一份临时工程到 `/tmp` 验证，避免污染正式仓库。

以验证 `VungleAds 7.7.3` 为例：

```bash
cd /Users/apus/TopOnVungleAdapter

rm -rf /tmp/TopOnVungleAdapter-lint-773
mkdir -p /tmp/TopOnVungleAdapter-lint-773

cp -R TopOnVungleAdapter.podspec README.md LICENSE Frameworks /tmp/TopOnVungleAdapter-lint-773/

ruby -0777 -pi -e "gsub(/s\\.dependency 'VungleAds', '= 7\\.7\\.2'/, \"s.dependency 'VungleAds', '= 7.7.3'\")" /tmp/TopOnVungleAdapter-lint-773/TopOnVungleAdapter.podspec

pod lib lint /tmp/TopOnVungleAdapter-lint-773/TopOnVungleAdapter.podspec --allow-warnings --verbose
```

如果最后看到：

```text
TopOnVungleAdapter passed validation.
```

说明 `7.7.3` 通过 CocoaPods 编译链接验证。

如果看到：

```text
Undefined symbols for architecture arm64
```

或者出现 `VungleAdsSDK.xxx` 找不到，说明 TopOn adapter 和这个 Vungle 版本不匹配，不能发布。

### 4.7 运行时校验 checklist

lint 通过后，还要在真实 App 或测试 Demo 中验证广告运行时行为。至少验证这些场景：

1. `pod install --repo-update` 能安装成功。
2. App 能启动，不出现 dyld、duplicate symbol、framework not found。
3. TopOn 后台配置 Vungle 广告源后，SDK 初始化成功。
4. 激励视频 load 成功。
5. 激励视频 show 成功。
6. 激励视频 close 回调正常。
7. 激励视频 reward 回调正常。
8. 插屏广告 load/show/close 正常。
9. 如果项目使用 banner 或 native，也要分别验证 load/show/click/close。
10. load 失败时错误码和错误信息能正常回调到 TopOn。
11. impression 展示回调正常。
12. revenue 或 ILRD 收益回调正常。
13. 真机 Release 包验证一次，不只依赖模拟器。

只有这些验证通过后，才建议把 `7.7.3` 写进正式 podspec 并发布新版本。

### 4.8 如果决定发布 7.7.3

不要覆盖已经发布的 `1.0.1`。CocoaPods 已发布版本不可修改，应发新版本：

```ruby
s.version = '1.0.2'
s.dependency 'VungleAds', '= 7.7.3'
```

然后执行完整发布流程：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose

git add TopOnVungleAdapter.podspec README.md PUBLISHING.md Frameworks/AnyThinkVungleAdapter.xcframework
git commit -m "Release TopOn Vungle adapter 1.0.2"

git push origin main
git tag 1.0.2
git push origin 1.0.2

pod trunk push TopOnVungleAdapter.podspec --allow-warnings --verbose
pod trunk info TopOnVungleAdapter
```

## 5. 配置 GitHub 仓库

创建 GitHub public 仓库，例如：

```text
WindsSunShine/TopOnVungleAdapter
```

配置 remote：

```bash
git remote add origin https://github.com/WindsSunShine/TopOnVungleAdapter.git
```

如果已经存在 remote：

```bash
git remote set-url origin https://github.com/WindsSunShine/TopOnVungleAdapter.git
git config --unset remote.origin.pushurl || true
```

检查 remote，正常情况不能包含 token：

```bash
git remote -v
```

应该看到：

```text
origin  https://github.com/WindsSunShine/TopOnVungleAdapter.git (fetch)
origin  https://github.com/WindsSunShine/TopOnVungleAdapter.git (push)
```

## 6. SourceTree 和 GitHub Token 配置

GitHub 不支持账号密码推送，只能使用 token 或 SSH。

推荐做法是：不要把 token 写进 `.git/config`，而是在 SourceTree 账号设置里配置 GitHub 账号。

### 6.1 创建 Fine-grained token

进入 GitHub：

```text
Settings -> Developer settings -> Personal access tokens -> Fine-grained tokens -> Generate new token
```

建议这样选：

- Repository access：`Only select repositories`
- 选择仓库：`WindsSunShine/TopOnVungleAdapter`
- Repository permissions：
  - `Contents`: `Read and write`
  - `Metadata`: `Read-only`，这是 GitHub 必选项

不需要勾选 `Repository security advisories`。如果已经勾选了，一般不影响推送，但不是必须权限。

生成后立刻复制 token。GitHub 只显示一次。

### 6.2 SourceTree 配置

SourceTree 中：

```text
Settings/Preferences -> Accounts -> Add/Edit GitHub account
```

建议：

- Host：`GitHub`
- Auth Type：`Basic` 或 `OAuth`，按 SourceTree 当前版本显示为准
- Username：`WindsSunShine`
- Password：填 GitHub token，不是 GitHub 登录密码

如果 SourceTree 仍然使用旧 token，清理 macOS 钥匙串：

```text
Keychain Access -> 搜索 github.com 或 SourceTree -> 删除旧的 GitHub 凭据
```

然后重新推送，让 SourceTree 重新询问账号和 token。

### 6.3 临时命令行推送方式

如果 SourceTree 一直缓存旧凭据，可以临时用命令行推送：

```bash
git push https://WindsSunShine:<YOUR_GITHUB_TOKEN>@github.com/WindsSunShine/TopOnVungleAdapter.git main
```

推送完成后确认 remote 不含 token：

```bash
git remote set-url origin https://github.com/WindsSunShine/TopOnVungleAdapter.git
git config --unset remote.origin.pushurl || true
```

不要把带 token 的 URL 提交、截图或发给别人。

## 7. 提交代码并打 tag

发布前确认 lint 已通过：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose
```

提交：

```bash
git status
git add README.md PUBLISHING.md LICENSE TopOnVungleAdapter.podspec Frameworks/AnyThinkVungleAdapter.xcframework
git commit -m "Release TopOn Vungle adapter 1.0.1"
```

推送 main：

```bash
git push origin main
```

创建并推送 tag。tag 必须和 podspec 里的 `s.version` 完全一致：

```bash
git tag 1.0.1
git push origin 1.0.1
```

如果以后发布 `1.0.2`：

```bash
git tag 1.0.2
git push origin 1.0.2
```

## 8. 注册 CocoaPods Trunk

第一次发布前需要注册：

```bash
pod trunk register zhangjianjunapple@gmail.com 'WindsSunShine' --description='TopOnVungleAdapter release machine'
```

然后去邮箱点击确认链接。

确认后执行：

```bash
pod trunk me
```

能看到自己的邮箱和名称就说明注册成功。

## 9. 发布到 CocoaPods

发布前再次验证：

```bash
pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose
```

正式发布：

```bash
pod trunk push TopOnVungleAdapter.podspec --allow-warnings --verbose
```

成功时会看到类似：

```text
Push for TopOnVungleAdapter 1.0.1 initiated.
Push for TopOnVungleAdapter 1.0.1 has been pushed.
```

发布后确认：

```bash
pod trunk info TopOnVungleAdapter
```

应该能看到版本号和 owner。

## 10. 等待 pod search 可搜索

`pod trunk push` 成功后，公开发布已经完成。但 `pod search` 有时不会立刻搜到，可能需要等待 CocoaPods 搜索索引或本地缓存更新。

先执行：

```bash
pod repo update
pod search TopOnVungleAdapter --simple
```

如果仍然搜不到，等 10 到 30 分钟后再试。

注意：`pod trunk info TopOnVungleAdapter` 能查到，通常就说明已经发布成功。`pod search` 延迟不代表发布失败。

## 11. 使用方接入方式

App 的 `Podfile`：

```ruby
source 'https://cdn.cocoapods.org/'

target 'YourApp' do
  pod 'TopOnVungleAdapter', '= 1.0.1'
end
```

然后：

```bash
pod install --repo-update
```

如果 App 里已经显式声明 `TPNiOS`，版本要和 adapter 的 podspec 保持一致：

```ruby
pod 'TPNiOS', '= 6.5.45'
pod 'TopOnVungleAdapter', '= 1.0.1'
```

不要再同时添加：

```ruby
pod 'AnyThinkiOS'
pod 'TPNMediationVungleAdapter'
```

否则 TopOn 主 SDK 或 Vungle adapter 会重复链接。

## 12. 升级版本 checklist

每次升级重新发布时按这个顺序：

1. 下载新的 TopOn SDK 包。
2. 替换 `Frameworks/AnyThinkVungleAdapter.xcframework`。
3. 确认 TopOn SDK 版本和 Vungle SDK 版本。
4. 修改 `TopOnVungleAdapter.podspec`：
   - `s.version`
   - `TPNiOS`
   - `VungleAds`
5. 执行 `pod lib lint TopOnVungleAdapter.podspec --allow-warnings --verbose`。
6. lint 通过后提交代码。
7. 推送 `main`。
8. 创建并推送和 `s.version` 一致的 tag。
9. 执行 `pod trunk push TopOnVungleAdapter.podspec --allow-warnings --verbose`。
10. 用 `pod trunk info TopOnVungleAdapter` 确认发布。
11. 等待 `pod search TopOnVungleAdapter --simple` 搜索索引更新。

## 13. 常见错误

### Invalid username or token

```text
remote: Invalid username or token. Password authentication is not supported for Git operations.
```

原因通常是 SourceTree 或 macOS 钥匙串还在使用旧 token，或者 token 写错。

处理：

```bash
git remote -v
```

确认 remote 不带旧 token。然后在 SourceTree 重新配置 GitHub 账号，必要时删除 Keychain Access 里的旧 `github.com` 凭据。

### 403 Permission denied

```text
remote: Permission to WindsSunShine/TopOnVungleAdapter.git denied to WindsSunShine.
```

原因通常是 token 没有该仓库的写权限。

处理：

- Fine-grained token 选择了 `Only select repositories`
- 已选中 `WindsSunShine/TopOnVungleAdapter`
- `Contents` 权限是 `Read and write`

重新生成 token 后，在 SourceTree 或命令行里替换旧 token。

### pod search 搜不到

如果 `pod trunk info TopOnVungleAdapter` 能查到，但 `pod search` 搜不到，通常是搜索索引延迟。

处理：

```bash
pod repo update
pod search TopOnVungleAdapter --simple
```

仍然搜不到就等一段时间。使用方一般可以直接 `pod install --repo-update`。
