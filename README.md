# FastPackage-IOS

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2014%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

面向外部的 iOS 开源库，最低支持 **iOS 14+**，同时提供 **Swift Package Manager** 与 **CocoaPods** 集成（CocoaPods 为过渡方案，后续可能移除）。

- **仓库**：[github.com/ArturoYi/FastPackage-IOS](https://github.com/ArturoYi/FastPackage-IOS)
- **变更记录**：[CHANGELOG.md](CHANGELOG.md)

提供空安全扩展、防抖、节流、速率限制等常用能力，零第三方依赖。

## 功能特性

- **空安全扩展**：为 `String?`、`Bool?`、`Int?`、`Double?` 等可选类型提供便捷的默认值与断言
- **字符串扩展**：`String` URL 编码/解码、电子邮件与 URL 验证、类型转换
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
│   ├── FastPackage.swift      # 模块入口
│   ├── Extensions/            # 扩展函数
│   │   ├── StandardLibrary/   # Swift 标准库类型扩展
│   │   ├── Foundation/        # Foundation 框架类型扩展
│   │   └── UIKit/             # UIControl / UIView 点击扩展
│   └── Utils/                 # 工具类
│       └── Internal/          # 内部辅助工具
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

**在 Xcode 工程中集成（推荐）**

1. 打开你的 iOS App 工程（`.xcodeproj` / `.xcworkspace`）
2. 菜单 **File → Add Package Dependencies…**
3. 在搜索框填入仓库 URL：`https://github.com/ArturoYi/FastPackage-IOS.git`
4. 选择版本规则（例如 **Up to Next Major** `0.0.1`）
5. 在 product 列表中勾选 **`FastPackage`**，添加到需要依赖的 Target
6. 编译工程，确认无链接错误

**在 Swift Package 工程中集成**

在 `Package.swift` 的 `dependencies` 与 `targets` 中加入：

```swift
dependencies: [
    .package(url: "https://github.com/ArturoYi/FastPackage-IOS.git", from: "0.0.1"),
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

**本地路径调试（开发本仓库或 fork 时）**

在 Xcode：**File → Add Package Dependencies… → Add Local…**，选择本仓库根目录（含 `Package.swift` 的文件夹），再勾选 product **`FastPackage`**。

或在依赖方的 `Package.swift` 中使用本地路径：

```swift
dependencies: [
    .package(path: "../FastPackage-IOS"),
],
```

#### CocoaPods

在 `Podfile` 中加入：

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!
  pod 'FastPackage', '~> x.x.x'
end
```

安装并打开工程：

```bash
pod install
open YourApp.xcworkspace   # 务必使用 .xcworkspace，不要用 .xcodeproj
```

**从 CocoaPods 仓库安装**：执行 `pod install` 后，在 App Target 的 **Build Phases → Link Binary With Libraries** 中应能看到 `FastPackage`。

**本地路径调试**（开发本仓库时，在示例 App 或你的 App 的 `Podfile` 中）：

```ruby
pod 'FastPackage', :path => '../FastPackage-IOS'
```

然后同样执行 `pod install` 与 `open *.xcworkspace`。

### 导入与基本使用

在需要使用 API 的 Swift 文件中导入模块：

```swift
import FastPackage
```

最小示例（空安全 + 防抖）：

```swift
import UIKit
import FastPackage

class DemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let nickname: String? = nil
        label.text = nickname.nullSafeOrEmpty  // ""

        searchField.addDebouncedAction(duration: 0.5, for: .editingChanged) { _ in
            FastDebounce.debounce(tag: "search", duration: 0.5) {
                self.fetchResults()
            }
        }
    }
}
```

更完整的 API 说明见下文 [使用教程](#使用教程)。

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

### 字符串扩展

提供 `String` 的 URL 编码/解码、电子邮件与 URL 验证、类型转换等计算属性与方法。

#### 类型转换

将字符串安全地转换为常见 Swift 类型，返回 Optional 值。

| 属性/方法 | 返回类型 | 描述 |
|-----------|----------|------|
| `bool` | `Bool?` | 解析 `"true"`/`"false"`/`"1"`/`"0"`（不区分大小写） |
| `int` | `Int?` | 转换为整数 |
| `float(locale:)` | `Float?` | 通过 `NumberFormatter` 转换，支持本地化 |
| `double(locale:)` | `Double?` | 同上，转换为双精度浮点数 |
| `cgFloat(locale:)` | `CGFloat?` | 同上，转换为 `CGFloat` |

```swift
// Bool
"true".bool     // Optional(true)
"1".bool        // Optional(true)
"false".bool    // Optional(false)
"0".bool        // Optional(false)
"abc".bool      // nil

// Int
"42".int        // Optional(42)
"-7".int        // Optional(-7)
"3.14".int      // nil

// Float / Double
"3.14".float()              // Optional(3.14)
"3.14159".double()          // Optional(3.14159)

// 本地化格式（如法语使用逗号作为小数点）
"3,14".float(locale: Locale(identifier: "fr_FR"))      // Optional(3.14)
"3,14159".double(locale: Locale(identifier: "fr_FR"))  // Optional(3.14159)

// CGFloat（图形计算常用）
"3.14".cgFloat()            // Optional(3.14)
```

#### 其他转换

提供与 Foundation 类型的便捷桥接属性。

| 属性/方法 | 返回类型 | 描述 |
|-----------|----------|------|
| `utf8Data` | `Data?` | 将字符串编码为 UTF-8 数据 |
| `url` | `URL?` | 根据字符串创建 `URL` |
| `nsString` | `NSString` | 桥接到 `NSString` |
| `characters` | `[Character]` | 字符数组 |

```swift
"hello".utf8Data      // Optional(Data([0x68, 0x65, 0x6C, 0x6C, 0x6F]))
"https://example.com".url  // Optional(URL)
"hello".nsString      // NSString
"abc".characters      // ["a", "b", "c"]
```

#### 文本处理

非突变转换属性，返回新字符串而不修改原始字符串。

| 属性 | 描述 | 示例 |
|------|------|------|
| `camelCased` | 转换为驼峰式 | `"hello test"` → `"helloTest"` |
| `latinized` | 移除变音符号 | `"Hëllö"` → `"Hello"` |
| `trimmed` | 删除首尾空格/换行 | `"  hi  "` → `"hi"` |
| `withoutSpacesAndNewLines` | 删除所有空格/换行 | `" he llo "` → `"hello"` |
| `regexEscaped` | 转义正则特殊字符 | `"hello ^$"` → `"hello \\^\\$"` |

```swift
// 驼峰式
"hello test".camelCased       // "helloTest"
"Hello_test-world".camelCased // "helloTestWorld"

// 移除变音符号
"Hëllö".latinized  // "Hello"
"café".latinized   // "cafe"

// 删除首尾空白
"  hello  ".trimmed    // "hello"
"\n  test \n".trimmed  // "test"

// 删除所有空格和换行
" he llo ".withoutSpacesAndNewLines  // "hello"
"a\nb\tc".withoutSpacesAndNewLines   // "abc"

// 正则转义
"hello ^$".regexEscaped  // "hello \\^\\$"
"a.b".regexEscaped       // "a\\.b"
```

#### 内容分析

将字符串拆分为行、单词，或提取 Unicode 标量值。

| 方法 | 返回类型 | 描述 |
|------|----------|------|
| `lines()` | `[String]` | 以换行符分隔的行数组 |
| `words()` | `[String]` | 以空格/标点分隔的单词数组 |
| `wordCount()` | `Int` | 单词数量 |
| `unicodeArray()` | `[Int]` | Unicode 标量值数组 |

```swift
"line1\nline2\r\nline3".lines()  // ["line1", "line2", "line3"]
"hello, world!".words()          // ["hello", "world"]
"hello world".wordCount()        // 2
"abc".unicodeArray()             // [97, 98, 99]
```

#### 搜索操作

支持区分大小写和不区分大小写的子字符串搜索。

| 方法 | 参数 | 描述 |
|------|------|------|
| `contains(_:caseSensitive:)` | 子字符串, 区分大小写 | 子字符串搜索 |
| `count(of:caseSensitive:)` | 子字符串, 区分大小写 | 统计出现次数 |
| `starts(with:caseSensitive:)` | 前缀, 区分大小写 | 前缀检查 |
| `ends(with:caseSensitive:)` | 后缀, 区分大小写 | 后缀检查 |
| `matches(pattern:)` | 正则模式 | 正则表达式匹配 |
| `matches(regex:options:)` | NSRegularExpression | 正则表达式匹配 |

```swift
// 子字符串搜索
"Hello World".contains("world", caseSensitive: false)  // true

// 统计出现次数
"hello hello".count(of: "hello")  // 2

// 前缀/后缀
"Hello World".starts(with: "hello", caseSensitive: false)  // true
"Hello World".ends(with: "world", caseSensitive: false)    // true

// 正则匹配
"abc123".matches(pattern: "^[a-z]+\\d+$")  // true
let regex = try! NSRegularExpression(pattern: "^[a-z]+\\d+$")
"abc123".matches(regex: regex)             // true
```

#### 前缀/后缀与切片

| 方法 | 描述 |
|------|------|
| `removingPrefix(_:)` | 返回去掉前缀的字符串 |
| `removingSuffix(_:)` | 返回去掉后缀的字符串 |
| `withPrefix(_:)` | 如果前缀不存在则添加 |
| `withSuffix(_:)` | 如果后缀不存在则添加 |
| `slicing(from:length:)` | 从指定位置提取子字符串 |
| `slice(from:length:)` | 变异版本 |
| `slice(from:to:)` | 按起止索引切片（变异） |
| `slice(at:)` | 从指定位置切到末尾（变异） |

```swift
// 前缀/后缀
"prefixHello".removingPrefix("prefix")  // "Hello"
"HelloSuffix".removingSuffix("Suffix")  // "Hello"
"Hello".withPrefix("Mr. ")              // "Mr. Hello"
"Hello".withSuffix(".jpg")              // "Hello.jpg"

// 切片
"Hello World".slicing(from: 0, length: 5)  // "Hello"
"Hello World".slicing(from: 10, length: 2) // "" (越界安全)
"Hello".slicing(from: 0, length: 0)        // "" (长度为零)
```

#### NSRange 转换

`Range<String.Index>` 与 `NSRange` 之间的双向转换。

| 方法 | 参数 | 返回类型 |
|------|------|----------|
| `range(from:)` | `NSRange` | `Range<String.Index>?` |
| `nsRange(from:)` | `Range<String.Index>` | `NSRange` |
| `fullNSRange` | - | `NSRange` |

```swift
let nsRange = NSRange(location: 0, length: 5)
let range = "Hello World".range(from: nsRange)  // Range<String.Index>?
"Hello World"[range!]                            // "Hello"

let str = "Hello"
let r = str.startIndex..<str.endIndex
str.nsRange(from: r)  // NSRange(location: 0, length: 5)

"Hello".fullNSRange   // NSRange(location: 0, length: 5)
```

#### URL 编码/解码

```swift
// URL 编码
"hello world".urlEncoded   // "hello%20world"
"你好".urlEncoded            // "%E4%BD%A0%E5%A5%BD"

// URL 解码
"hello%20world".urlDecoded   // "hello world"
"%E4%BD%A0%E5%A5%BD".urlDecoded  // "你好"

// 往返编码
let original = "hello world 你好 test=1&a=2"
original.urlEncoded.urlDecoded == original  // true
```

#### 验证

##### 电子邮件验证

正则表达式遵循 RFC 标准，支持标准格式、子域名、加号地址、IP 域名和引号本地部分。

```swift
"test@example.com".isValidEmail            // true
"user+tag@sub.domain.com".isValidEmail     // true
"user@[123.123.123.123]".isValidEmail      // true
"not-an-email".isValidEmail                // false
```

##### URL 验证

提供多种粒度的 URL 验证属性：

| 属性 | 验证范围 |
|------|----------|
| `isValidUrl` | 任意有效 URL（可带或不带协议） |
| `isValidSchemedUrl` | 带有明确协议的 URL（`http://`、`ftp://` 等） |
| `isValidHttpsUrl` | 仅 HTTPS URL |
| `isValidHttpUrl` | 仅 HTTP URL |
| `isValidFileUrl` | 文件 URL（`file://`） |

```swift
"https://example.com".isValidUrl         // true
"example.com".isValidUrl                 // true
"https://example.com".isValidSchemedUrl  // true
"example.com".isValidSchemedUrl          // false
"https://example.com".isValidHttpsUrl    // true
"http://example.com".isValidHttpsUrl     // false
"http://example.com".isValidHttpUrl      // true
"file:///path/to/file".isValidFileUrl    // true
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

## 本地开发与单元测试

本仓库为 **iOS 库**，测试与示例 App 均需在 **Xcode + iOS 模拟器** 环境下运行。终端中的裸 `swift test` 在 macOS 上会因缺少 UIKit 而失败，请使用下文方式。

### 克隆与打开

```bash
git clone https://github.com/ArturoYi/FastPackage-IOS.git
cd FastPackage-IOS
open Package.swift    # 用 Xcode 打开 Swift Package
```

测试源码位于 `Tests/FastPackageTests/`（`Package.swift` 中 target 名 **`FastPackageTests`**）。

### 运行单元测试

#### 方式一：Xcode（推荐）

1. 用 Xcode 打开仓库根目录的 `Package.swift`
2. 顶部 Scheme 选择 **`FastPackage-IOS`**
3. 运行目标选择任意 **iOS Simulator**（例如 iPhone 17）
4. 菜单 **Product → Test**（快捷键 `⌘U`），执行 **FastPackageTests**

#### 方式二：命令行

在仓库根目录执行（与 [CI](.github/workflows/ci.yml) 一致：Xcode 16.4 + iPhone 16 / iOS 18.5）：

```bash
cd FastPackage-IOS

xcodebuild test \
  -scheme FastPackage-IOS \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
  -skipPackagePluginValidation \
  -skipMacroValidation
```

若提示找不到模拟器，先查看本机可用目标：

```bash
xcodebuild -showdestinations -scheme FastPackage-IOS
```

将 `-destination` 改为你已安装的运行时，例如 Xcode 26+ 常见为：

```bash
xcodebuild test \
  -scheme FastPackage-IOS \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -skipPackagePluginValidation \
  -skipMacroValidation
```

成功时终端会显示 **`TEST SUCCEEDED`**，并列出通过的测试数量。

#### 注意事项

| 方式 | 是否可用 | 说明 |
|------|----------|------|
| Xcode `⌘U` | ✅ | 本地开发首选 |
| `xcodebuild test` + iOS 模拟器 | ✅ | 与 CI 相同，适合脚本 |
| 裸 `swift test`（macOS） | ❌ | 库依赖 UIKit，需 iOS SDK |

### 示例 App

仓库提供两个独立示例工程，分别验证 **SPM** 与 **CocoaPods** 集成，互不混用。

#### TestApp-SPM（Swift Package Manager）

```bash
open TestApp-SPM/FastPackageTestApp.xcodeproj
```

在 Xcode 中选择 iOS 模拟器，点击 **Run**（`⌘R`）。工程已通过本地 Package / 远程 Package 引用 `FastPackage`，可直接体验 API。

#### TestApp-CocoaPods

```bash
cd TestApp-CocoaPods
pod install
open FastPackageTestApp.xcworkspace
```

使用 **`.xcworkspace`** 打开，选择模拟器后 **Run**。`Podfile` 通过 `:path` 引用上级目录的本仓库。

## 开发说明

- 对外模块名：`FastPackage`（`import FastPackage`）
- 本地克隆、跑测试、示例 App：见 [本地开发与单元测试](#本地开发与单元测试)
- 发布版本请同步更新：`FastPackage.version`、`FastPackage.podspec` 的 `s.version`、`CHANGELOG.md`、Git tag（格式 `x.y.z`，与 podspec 一致）
- 提交 PR 前请运行单元测试，并在 `CHANGELOG.md` 的 `[Unreleased]` 小节补充变更说明
- CI / 发版：推送 tag `x.y.z` 触发 [`.github/workflows/release.yml`](.github/workflows/release.yml)；需在仓库 Secrets 配置 `COCOAPODS_TRUNK_TOKEN`

## License

MIT — 见 [LICENSE](LICENSE)
