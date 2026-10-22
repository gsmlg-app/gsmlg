# Editor 文件编辑器

日期：2026-10-23。用户已确认以下首版范围，并要求复用 DuskMoon 编辑器。

## 行为

工具箱增加 Editor，路由 `/toolbox/editor`。复用 `duskmoon_ui` 已公开的 `DmCodeEditor` 与 `EditorViewController`，提供行号、按扩展名选择的语法高亮和组件已有的撤销重做。一次编辑一个 UTF-8 文本或代码文件，支持新建、打开、保存、另存为。保留 UTF-8 BOM 和原有换行风格；拒绝非法 UTF-8、包含 NUL 的二进制内容和超过 16 MiB 的文件。

新建、打开其他文件、离开编辑器及系统传入另一个文件，均在有修改时提供保存、放弃、取消。保存失败或取消另存为时保留当前文本和修改状态。只读来源通过另存为保存。显示文件名、未保存标记和操作失败提示，布局沿用现有 AppAdaptiveScaffold / DmNavigationHeader 与明暗主题。本功能补充英文和简体中文资源，不改变全局语言支持配置。

## 架构与平台

`app_lib/editor` 负责文件标识、UTF-8 编解码、文件选择、读写和外部请求队列；`app_bloc/editor` 的 EditorCubit 管理文本、已保存快照、文件身份、忙碌和错误状态。MainProvider 注册服务和 Cubit。页面负责编辑组件、动作、未保存确认；App 只接收外部请求并导航。Splash 的延迟跳转必须可取消，不能覆盖文件打开路由。

Android、iOS、macOS 注册为系统可选文本/代码编辑器。Android 使用 Storage Access Framework 与 ContentResolver 对原 URI 读写；iOS 使用 open-in-place 文档选择器、安全作用域与文件协调。macOS 启用 user-selected.read-write，通过 AppDelegate 接收文件打开。Windows / Linux 沿用 runner 传入的命令行文件参数，提供用户级安装关联脚本和 Linux desktop 文件；这两个平台允许新窗口接收文件，不新增单实例 IPC，也不替用户更改默认应用。

方法通道 `gsmlg/editor`：`ready` 返回排队 URI 列表并启用后续 `openFiles(List<String>)` 回调；`pickFile` 返回文件映射或 null；`readFile({uri})` 返回文件映射；`writeFile({uri, bytes})` 成功返回 true；`saveFileAs({name, bytes})` 返回保存位置映射或 null。文件映射为 `{uri: String, name: String, writable: bool, bytes: Uint8List}`；另存为响应可省略 bytes，由调用方保留写入内容。原生层限制读取大小，操作失败使用 PlatformException，取消选择返回 null。

## 验证与边界

仅运行新库、Cubit、页面、Toolbox、Splash 及直接受影响的启动测试。覆盖编码/换行、读写、取消、失败、修改快照、未保存确认、外部请求排队及启动跳转。验证 macOS 构建和系统打开文件，检查 Android / iOS 构建并尽可能实测现有设备。Windows / Linux 的构建和系统关联需对应宿主，源码检查不能代替运行验收。编辑内容尚未保存时被操作系统强制结束不保证恢复；本版不增加自动保存或恢复数据库。
