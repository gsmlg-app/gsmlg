# 指南针工具设计

日期：2026-10-08。产品设计已获用户批准（LGTM）；功能已实现，范围内自动化检查及 Android / iOS 宿主构建通过。真机方向、权限与传感器生命周期验收未验证。

## 1. 目标与范围

在工具箱添加仅供 Android / iOS 使用的指南针，显示手机当前屏幕顶部的磁航向。第一版采用固定朝向标记、旋转罗盘和数字读数，帮助用户快速判断方向。

- 工具箱入口名称为本地化的“指南针 / Compass”。
- 始终使用磁北，界面明确标注“磁北 / Magnetic north”。
- 不请求定位权限，不启动位置更新，不读取坐标，也不根据已有定位授权切换为真北。
- 不增加海拔、导航目标、历史记录、锁定读数、水平仪或常亮设置；屏幕休眠沿用系统设置。
- 页面状态由页面管理，不新增全局 BLoC、MainProvider 注册项或数据库表。

## 2. 页面与交互

### 入口与路由

在现有工具箱网格加入 Compass，保持其他工具的布局和平台判断不变。入口只在非 Web 的 Android / iOS 显示。

使用 Compass 专用的平台判断函数，入参为 `isWeb` 和 `TargetPlatform`，由入口和页面共用。这保持实际平台限制一致，也允许在桌面测试环境验证移动端入口，无需调整现有 Camera / Bluetooth 的 `dart:io` 判断。

新页面 `CompassScreen` 使用 `name = 'Compass'`、相对路径 `path = 'compass'`，通过现有 `toolboxRoutes()` 注册 `NoTransitionPage`，完整地址为 `/toolbox/compass`。路由保持注册；桌面或 Web 直接访问时显示本地化的不支持提示，且不访问原生通道。

### 页面结构

沿用 `AppAdaptiveScaffold`、工具箱导航选中状态、SafeArea 和现有网格间距。

1. 顶部浮动标题栏显示“指南针”，右侧帮助按钮打开校准说明。
2. 中央显示响应式圆形罗盘，最大直径 360 logical pixels；窄屏按可用宽度缩小，内容可以滚动，横屏不会溢出。
3. 固定的顶部指向标记表示当前屏幕顶部，刻度盘按磁航向反向旋转。北方有独立文字标记和醒目颜色，不能仅靠颜色识别。
4. 罗盘显示四个主方位，5° 小刻度、30° 大刻度；下方显示整数角度和八方位，例如 `128° · 东南`。
5. 数字读数下方显示“磁北”；校准提示或传感器状态放在其下。

颜色、文字和警告样式来自现有主题，支持明暗主题。罗盘文字、按钮和状态均使用本地化资源；读数提供可访问的语义描述，不随传感器采样自动反复播报。

### 角度与动画

原始磁航向统一为 `[0, 360)`，读数为 `round(heading) % 360`。八方位按每 45° 一组，北方区间为 `[337.5°, 360°) ∪ [0°, 22.5°)`。

首次有效读数直接定位罗盘；之后采用最短角度差和 180ms 的平滑动画。新读数从当前动画位置继续，不排队播放旧读数。`359° → 0°` 只转动 1°，不会绕行一圈。系统要求减少动画时直接更新角度。

## 3. 状态与生命周期

| 状态 | 界面与行为 |
| --- | --- |
| 等待首个读数 | 显示 `—` 和等待提示，不显示假 `0°`。 |
| 有效读数 | 显示旋转罗盘、角度、方位和磁北标注。 |
| 建议校准 | 显示校准提示；有效但精度低的估计值可显示，明确保留警告。无可靠角度时显示 `—`。 |
| 没有必要传感器 | 显示设备不支持指南针的说明，不持续加载。 |
| 读取失败 | 显示本地化失败提示和已有的“重试”按钮，重试重新订阅。 |
| 不支持的平台 | 显示仅 Android / iOS 可用，不初始化插件。 |

已开始监听且 5 秒内没有收到任何事件时，页面结束等待并显示可重试的读取失败；此超时不能被解释为硬件不存在。收到任何事件即取消首读定时器。

帮助说明包含保持手机平放、远离金属和磁性配件、缓慢画“8”字移动手机。帮助按钮只是说明，不宣称能重置传感器或校准成功。

传感器只在页面挂载、当前路由可见且应用为 `resumed` 时订阅。`didChangeDependencies` 使用 `ModalRoute.isCurrentOf(context)`；应用状态使用 `WidgetsBindingObserver`。页面被其他路由或帮助弹层覆盖、应用 inactive / hidden / paused / detached、页面销毁时取消订阅和首读定时器。

取消与恢复串行协调，避免快速切换产生重复监听。恢复时清空旧读数，再获取当前方向。迟到的旧订阅回调不能更新界面；任意时刻最多存在一个有效订阅。旋转屏幕或恢复前台时刷新原生方向参考。

## 4. 传感器架构

### 依赖选择

采用单个工作区原生插件 `app_compass`，位于 `app_plugin/compass`，仅注册 Android / iOS。

已核查的现成库不符合“始终磁北”要求：`flutter_compass 0.8.1` 的 iOS 实现直接使用 `trueHeading`；`compassx 1.0.1` 在 iOS 优先真北，Android 在已有定位授权时启动位置更新并应用磁偏角。这是选择自有小插件的原因。使用通用传感器库自行计算会增加融合算法和校准维护，因此采用系统提供的磁航向。

插件遵循项目单包约定，使用当前 Flutter 原生构建模板。iOS 按项目现有 Swift Package Manager 接入，不复制砖块中的旧构建版本或未加前缀的 podspec 名称，不修复或扩展 Mason 砖块。

### Dart 合约

`CompassSource` 提供 `Stream<CompassReading> readings` 和 `Future<void> refreshOrientation()`；页面可注入假数据源，生产数据源为 `AppCompass`。

事件通道为 `app_compass/events`；方法通道为 `app_compass`，仅提供 `refreshOrientation`。订阅事件流触发原生 `onListen`，最后一个订阅取消触发 `onCancel`。注册插件和创建 Dart 对象都不启动传感器。

`CompassReading` 的固定字段为：

| 字段 | 语义 |
| --- | --- |
| `status` | `ready`、`calibrating`、`unavailable`。等待属于页面状态。 |
| `magneticHeadingDegrees` | 可空 double；有效值必须有限且处于 `[0, 360)`，无可靠角度时为 null。 |
| `accuracyDegrees` | 可空 double；仅保存 iOS 非负真实角度误差，Android 为 null。 |
| `sensorAccuracy` | 可空 Android 质量等级：`unknown`、`unreliable`、`low`、`medium`、`high`；iOS 为 null。 |
| `unavailableReason` | 不可用时为 `sensorNotFound` 或 `sensorFailure`，其他事件为 null。 |

`ready` 必须包含角度；`unavailable` 不携带角度；`calibrating` 可携带低精度的估计角度。错误通道和非法事件统一进入页面读取失败状态，不展示原始原生错误信息。

### Android

优先使用 `TYPE_ROTATION_VECTOR`。缺失或无法注册时，清理已注册监听后回退到加速度计和磁力计；必要硬件缺失时报告 `sensorNotFound`，硬件存在但最终注册失败时报告 `sensorFailure`。回退等两种数据都到达后使用 `getRotationMatrix`，失败时报告暂时不可靠，不能把零矩阵当作北方。

每次采样读取当前 Activity 显示旋转，重映射矩阵后读取方位角：0° 使用 `(X,Y)`，90° 使用 `(Y,-X)`，180° 使用 `(-X,-Y)`，270° 使用 `(-Y,X)`。

保留旋转向量或回退磁力计的真实质量等级，不能被加速度计质量覆盖。low / unreliable 提示校准；unreliable 不显示数值，unknown 不声称高精度。Android 质量等级不能换算成虚构的角度误差。

不使用 `LocationManager` 或 `GeomagneticField`，不添加定位权限，不强制要求传感器硬件从而改变应用安装范围。`onCancel`、Activity / engine detach 清理监听和引用。

### iOS

先检查 `CLLocationManager.headingAvailable()`，仅订阅 heading 并读取 `CLHeading.magneticHeading`。不请求授权、不启动位置更新，也不以已有授权状态限制或切换磁航向。

`headingAccuracy` 为 0 也有效；负数表示不可靠，输出校准状态和空角度。非负误差大于 20° 时保留角度但提示校准；其余有效读数为 ready。该阈值只用于提示，不代表精度保证。

方向参考来自 Flutter view 所属 `windowScene.interfaceOrientation`，不使用已弃用的 `statusBarOrientation` 或手机平放时不确定的物理方向。UI portrait / upside-down 直接映射；UI landscapeLeft / landscapeRight 分别映射到 CL landscapeRight / landscapeLeft。方向改变时更新 `headingOrientation` 并等待新参考下的读数。

原生失败输出 `sensorFailure`，不自动请求定位，也不提供“开启定位权限”的引导。

## 5. 集成范围与验收

实现修改仅限新插件、新 Compass 页面及测试、工具箱入口和子路由、根 workspace / dependency 注册、相应本地化资源及其必要生成结果。现有全局路由、导航目的地、MainProvider、其他工具权限流程和支持语言配置不变。

英语与简体中文补充 Compass 文案，沿用现有 `loading` / `retry` 等资源。当前 `AppLocale.supportedLocales` 仅包含英语；这项功能不扩大全局支持语言范围。

### 自动化验收

- 平台判断：Android / iOS 显示入口，Web / macOS / Linux / Windows 隐藏；不支持平台直接访问不调用原生通道。
- 数据合约：准确处理空值、非有限角度、负精度、未知质量和不可用原因，不制造北向或误差值。
- 方向与动画：八方位边界、四个屏幕方向、359° ↔ 0° 最短路径、读数取整、首次读数与减少动画设置。
- 状态：等待、首读超时、有效、校准、缺失硬件、失败与重试。
- 生命周期：后台、页面覆盖、帮助弹层、快速取消 / 恢复、销毁；验证旧回调被忽略且只有一个监听。
- 布局：明暗主题、窄屏、横屏和大字体，无溢出；帮助与语义文本可访问。
- 只运行新插件、新 Compass / Toolbox 测试及直接受影响的现有工具箱测试。

### 真机验收

Android 和 iOS 分别测试从未给予定位授权、拒绝授权和已有授权，确认磁北语义不变、不新增定位请求或位置更新。iOS 另测全局关闭 Location Services，记录系统行为和结果，不把此情况当作已经验证无系统提示。

使用实际设备验证朝向、平放使用、四种界面方向、连续转动、磁干扰 / 校准及退出页面和进入后台后停止更新。对照磁北模式的参考工具，不把真北偏差误判为指南针错误。模拟器和自动化测试只能证明状态 / 构建，不能证明实际方向准确性。

定位权限未授权或被拒绝时是否持续交付 heading，仍需真机证明。若平台无法满足批准的权限约束，报告该验收阻碍，不新增定位授权流程来通过测试。

## 6. 参考

- [Apple：magneticHeading](https://developer.apple.com/documentation/corelocation/clheading/magneticheading)
- [Apple：headingOrientation](https://developer.apple.com/documentation/corelocation/cllocationmanager/headingorientation)
- [Apple：Getting Heading-Related Events](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/LocationAwarenessPG/GettingHeadings/GettingHeadings.html)
- [flutter_compass 0.8.1](https://pub.dev/packages/flutter_compass/versions/0.8.1)
- [compassx 1.0.1](https://pub.dev/packages/compassx/versions/1.0.1)
