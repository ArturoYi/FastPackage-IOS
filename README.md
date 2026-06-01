# FastPackage-IOS

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2014%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

面向外部的 iOS 开源组件库，最低支持 **iOS 14+**，同时提供 **Swift Package Manager** 与 **CocoaPods** 集成（CocoaPods 为过渡方案，后续可能移除）。

- **仓库**：[github.com/ArturoYi/FastPackage-IOS](https://github.com/ArturoYi/FastPackage-IOS)
- **变更记录**：[CHANGELOG.md](CHANGELOG.md)
- **参考实现**：[fast_package](https://github.com/ArturoYi/fast_package)（Flutter 工具库，API 设计对齐）

提供空安全扩展、防抖、节流、速率限制等常用能力，零第三方依赖。

## 功能特性

- **空安全扩展**：为 `String?`、`Bool?`、`Int?`、`Double?` 等可选类型提供便捷的默认值与断言
- **防抖 (Debounce)**：延迟执行，多次触发只执行最后一次
- **节流 (Throttle)**：时间窗口内最多执行一次
- **速率限制 (Rate Limit)**：每个窗口首次立即执行，窗口内后续调用缓存并在下一窗口执行
- **零第三方依赖**：基于 Foundation / UIKit 实现

## 目录结构

```
FastPackage-IOS/
├── Package.swift              # SPM 清单
├── FastPackage.podspec        # CocoaPods 规格
├── Sources/FastPackage/       # 库源码（对外 product: FastPackage）
│   ├── Extensions/            # 扩展函数
│   │   └── UIKit/             # UIControl / UIView 点击扩展
│   └── Utils/                 # 工具类
├── Tests/FastPackageTests/    # 单元测试
├── TestApp-SPM/               # 示例 App（Swift Package Manager）
└── TestApp-CocoaPods/         # 示例 App（CocoaPods）
```

## 要求

- Xcode 15+
- iOS 14.0+
- Swift 5.9+

## 快速开始

### 安装

#### Swift Package Manager

在 Xcode：**File → Add Package Dependencies**，填入仓库 URL，选择 product **`FastPackage`**。

或在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/ArturoYi/FastPackage-IOS.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "FastPackage", package: "FastPackage-IOS"),
        ]
    ),
]
```

#### CocoaPods

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!
  pod 'FastPackage', '~> 1.0'
end
```

本地路径调试：

```ruby
pod 'FastPackage', :path => '../FastPackage-IOS'
```

### 导入

```swift
import FastPackage
```

## 使用教程

### 空安全扩展

为可选类型提供链式默认值，减少 `??` 与 `guard let` 的重复代码。

```swift
// String?
let name: String? = nil
print(name.nullSafeOrEmpty)           // ""
print(name.nullSafe("default"))       // "default"
print(name.isNullOrEmpty)             // true

// Bool?
let flag: Bool? = nil
print(flag.nullSafeOrFalse)           // false
print(flag.nullSafeOrTrue)            // true
print(flag.nullSafe(true))            // true

// Int? / Double?
let count: Int? = nil
print(count.nullSafeOrZero)           // 0
print(count.nullSafe(42))             // 42

// 非空断言
try name.nullSafeThrow()              // 抛出 NullSafeError.nullValue
```

### 防抖 (Debounce)

防止函数在短时间内被多次调用，只执行最后一次。

```swift
// 搜索框输入：停止输入 0.5 秒后再请求
FastDebounce.debounce(tag: "search", duration: 0.5) {
    performSearch()
}

// 立即触发已缓存的回调（不取消定时器）
FastDebounce.fire(tag: "search")

// 取消 / 取消全部
FastDebounce.cancel(tag: "search")
FastDebounce.cancelAll()
```

### 节流 (Throttle)

限制函数在一定时间内只能执行一次。

```swift
// 按钮点击：1 秒内最多响应一次
let isThrottled = FastThrottle.throttle(tag: "submit", duration: 1.0) {
    submitForm()
}

// isThrottled == true 表示当前处于节流中，本次调用被忽略

// 节流窗口结束后的可选回调
FastThrottle.throttle(
    tag: "scroll",
    duration: 0.3,
    onExecute: { updateUI() },
    onAfter: { hideLoadingIndicator() }
)
```

### 速率限制 (Rate Limit)

每个时间窗口内首次调用立即执行；窗口内的后续调用会被缓存，在下一窗口开始时执行最新一次。

```swift
// 位置更新：每 2 秒最多上报一次，窗口内的更新合并为最后一次
let isLimited = FastRateLimit.rateLimit(tag: "location", duration: 2.0) {
    uploadLocation()
}

// isLimited == true 表示当前窗口内，调用已被缓存

FastRateLimit.cancel(tag: "location")
FastRateLimit.cancelAll()
```

### 三者对比

| 场景 | 推荐 | 行为 |
|------|------|------|
| 搜索框输入 | Debounce | 停止触发后延迟执行最后一次 |
| 按钮防重复点击 | Throttle | 窗口内第一次立即执行，其余忽略 |
| 高频数据合并上报 | Rate Limit | 窗口内首次立即执行，后续缓存并在下一窗口执行 |

### UIKit 扩展（按钮 / 视图点击）

针对 iOS 常见交互场景，提供 `UIControl`、`UIButton`、`UIView` 扩展，内部基于 `UIAction` 与 `UITapGestureRecognizer`，无需手动管理 `tag`。

#### UIButton / UIControl — 节流（防重复点击）

```swift
// 推荐：按钮提交防连点
submitButton.addThrottledTap(duration: 1.0) { button in
    submitOrder()
}

// 通用 UIControl（如 UISwitch、自定义控件）
segmentControl.addThrottledAction(duration: 0.5, for: .valueChanged) { control in
    refreshContent()
}

// 移除
submitButton.removeThrottledAction(for: .touchUpInside)
```

#### UIButton / UIControl — 防抖

```swift
// 连续点击时，停止后执行最后一次
actionButton.addDebouncedTap(duration: 0.3) { button in
    performAction()
}

// 移除
actionButton.removeDebouncedAction(for: .touchUpInside)
```

#### UIView — 点击手势

适用于卡片、Cell 内容区、自定义可点击区域：

```swift
// 节流点击（列表 Cell 防连点）
cardView.addThrottledTapGesture(duration: 0.8) { view in
    openDetail()
}

// 防抖点击
bannerView.addDebouncedTapGesture(duration: 0.3) { view in
    trackImpressionAndNavigate()
}

// 同一视图注册多个手势时，请使用不同 identifier
cardView.addThrottledTapGesture(duration: 1.0, identifier: "select") { _ in selectItem() }
cardView.addDebouncedTapGesture(duration: 0.3, identifier: "preview") { _ in previewItem() }

// 移除
cardView.removeThrottledTapGesture(identifier: "select")
cardView.removeDebouncedTapGesture(identifier: "preview")
```

## 单元测试

在仓库根目录用 Xcode 打开 `Package.swift`，选择 scheme **`FastPackage-IOS`**，运行 **FastPackageTests**。

命令行（需指定本机已安装的 iOS 模拟器）：

```bash
xcodebuild test \
  -scheme FastPackage-IOS \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -skipPackagePluginValidation
```

## 示例 App

仓库提供两个独立示例工程，分别验证两种集成方式，互不混用。

### TestApp-SPM（Swift Package Manager）

1. 打开 `TestApp-SPM/FastPackageTestApp.xcodeproj`
2. 选择模拟器，Run

### TestApp-CocoaPods

```bash
cd TestApp-CocoaPods
pod install
open FastPackageTestApp.xcworkspace
```

## 开发说明

- 对外模块名：`FastPackage`（`import FastPackage`）
- 发布版本请同步更新：`FastPackage.version`、`FastPackage.podspec` 的 `s.version`、`CHANGELOG.md`、Git tag
- 提交 PR 前请运行单元测试，并在 `CHANGELOG.md` 的 `[Unreleased]` 小节补充变更说明

## License

MIT — 见 [LICENSE](LICENSE)
