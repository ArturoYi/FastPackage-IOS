# Changelog

本项目的所有重要变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-06-01

### Added

- 初始发布，对外模块名 `FastPackage`，最低支持 iOS 14+
- **空安全扩展**（`Optional+NullSafe`）：为 `String?`、`Bool?`、`Int?`、`Double?` 等可选类型提供默认值、空值判断与非空断言
- **防抖**（`FastDebounce`）：按 tag 管理延迟执行，支持 `fire`、`cancel`、`cancelAll`
- **节流**（`FastThrottle`）：按 tag 限制时间窗口内执行次数，支持 `onAfter` 回调
- **速率限制**（`FastRateLimit`）：窗口内首次立即执行，后续调用缓存并在下一窗口执行
- **UIKit 扩展**：
  - `UIControl` / `UIButton` 防抖与节流点击（基于 `UIAction`）
  - `UIView` 防抖与节流点击手势（基于 `UITapGestureRecognizer`）
- Swift Package Manager 与 CocoaPods 双集成方式
- 单元测试（`FastPackageTests`）与示例 App（`TestApp-SPM`、`TestApp-CocoaPods`）
- MIT 许可证

[1.0.0]: https://github.com/ArturoYi/FastPackage-IOS/releases/tag/1.0.0
