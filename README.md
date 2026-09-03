# 自动关闭 Turbo Boost

本项目复刻自 [psychowood/turbo-boost-manager](https://github.com/psychowood/turbo-boost-manager)，在原有命令行工具基础上增加了开机自动启动与自动禁用 Turbo Boost 的功能。完成配置后，无需每次开机手动打开终端执行脚本；系统启动时会自动禁用 Turbo Boost，并在每次睡眠唤醒后再次禁用。

`autodisable.sh` 会自动完成 LaunchDaemon 配置，使 macOS 启动时先关闭 Turbo Boost，然后持续监控睡眠唤醒事件。

## 使用方法

首先下载并安装官方版 Turbo Boost Switcher v2.10.2：

```text
https://turbo-boost-switcher.s3.amazonaws.com/Turbo_Boost_Switcher_v2.10.2.dmg
```

打开下载的 DMG，并将官方应用安装到 `/Applications`。项目需要其中的 `DisableTurboBoost.64bits.kext` 文件来执行禁用操作。

然后将本项目获取到本地。可使用 Git 克隆：

```sh
git clone https://github.com/yizhaoyiximh/turbo-boost-manager.git
```

也可以从 GitHub 下载项目 ZIP 文件并解压到本地。

进入项目目录后执行：

```sh
cd /path/to/turbo-boost-manager
chmod 755 autodisable.sh TurboBoostManagerDaemon.sh
./autodisable.sh
```

脚本会请求管理员密码，并完成以下操作：

- 生成适配当前项目路径的 `com.psychowood.turboboostmanager.plist`
- 安装到 `/Library/LaunchDaemons/`
- 设置 plist 为 `root:wheel` 和 `644` 权限
- 重新加载 LaunchDaemon
- 启动时执行选项 `3`，重新加载禁用 Turbo Boost 的 kext
- 执行选项 `0`，监控唤醒并自动再次禁用

脚本必须从项目目录执行，且项目目录之后不能移动或删除。项目路径中不要包含会导致 XML 转义问题的特殊字符，例如 `&`、`<` 或 `>`。

## 验证

查看服务：

```sh
sudo launchctl list | grep com.psychowood.turboboostmanager
```

确认 kext 已加载：

```sh
kmutil showloaded -V release | grep com.rugarciap.DisableTurboBoost
```

查看日志：

```sh
tail -n 30 /var/log/turboboostmanager.log
tail -n 30 /var/log/turboboostmanager.err
```

## 卸载服务

停止并移除 LaunchDaemon：

```sh
sudo launchctl unload /Library/LaunchDaemons/com.psychowood.turboboostmanager.plist
sudo rm /Library/LaunchDaemons/com.psychowood.turboboostmanager.plist
```

确认服务已移除：

```sh
sudo launchctl list | grep com.psychowood.turboboostmanager
```

该命令没有输出即表示卸载完成。卸载服务不会自动重新启用 Turbo Boost；如需立即启用，请在项目目录执行：

```sh
./TurboBoostManager.sh 2
```
