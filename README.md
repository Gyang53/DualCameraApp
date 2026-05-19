# DualCameraApp - 双景录制

一款专为 HarmonyOS NEXT 打造的双摄像头同时录制应用，支持分屏和画中画两种录制模式。

## 功能特性

### 核心功能
- **双摄并发录制** - 前后摄像头同时工作，捕捉精彩瞬间
- **分屏模式** - 左右或上下分屏显示双摄画面
- **画中画模式** - 主画面+小窗口灵活布局
- **实时预览** - 录制前实时预览双摄效果

### 控制功能
- **变焦控制** - 支持 1.0x ~ 6.0x 变焦
- **曝光调节** - -4 ~ +4 曝光补偿
- **闪光灯控制** - 开启/关闭闪光灯
- **视频防抖** - 支持开启/关闭防抖功能

### 设置功能
- **录制时长限制** - 5/10/15/30分钟或无限制
- **文件保存方式** - 合并文件或分开保存
- **分屏比例调节** - 30:70 / 50:50 / 70:30
- **画中画位置** - 左上/右上/左下/右下
- **前置镜像翻转** - 可选开启
- **网格线辅助** - 构图辅助线
- **时间戳水印** - 录制时间显示
- **色彩空间** - 自动/SDR/HDR 选择
- **前摄补光** - 低光环境补光提示
- **存储空间提醒** - 存储不足提醒

## 技术栈

- **平台**: HarmonyOS NEXT (API 18+)
- **语言**: ArkTS
- **UI框架**: ArkUI (V2 状态管理)
- **核心Kit**: 
  - CameraKit - 相机功能
  - MediaKit - 视频录制
  - ArkData - 数据持久化

## 项目结构

```
DualCameraApp/
├── AppScope/                    # 应用全局配置
├── entry/                       # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── pages/           # 页面
│       │   │   ├── Index.ets    # 主页面
│       │   │   ├── Settings.ets # 设置页面
│       │   │   └── PermissionGuide.ets
│       │   ├── components/      # 组件
│       │   │   ├── SplitView.ets    # 分屏视图
│       │   │   ├── PIPView.ets      # 画中画视图
│       │   │   ├── ControlPanel.ets # 控制面板
│       │   │   ├── CameraPreview.ets
│       │   │   ├── ZoomSlider.ets
│       │   │   └── RecordButton.ets
│       │   ├── services/        # 服务层
│       │   │   ├── CameraService.ets  # 相机服务
│       │   │   ├── RecordService.ets # 录制服务
│       │   │   ├── StorageService.ets
│       │   │   └── PermissionService.ets
│       │   ├── viewmodels/      # 视图模型
│       │   │   ├── SettingsViewModel.ets
│       │   │   ├── CameraViewModel.ets
│       │   │   └── RecordViewModel.ets
│       │   ├── models/          # 数据模型
│       │   │   ├── UserSettings.ets
│       │   │   ├── RecordConfig.ets
│       │   │   └── CameraDevice.ets
│       │   ├── common/          # 公共定义
│       │   └── utils/           # 工具类
│       │       ├── Logger.ets
│       │       ├── FileUtils.ets
│       │       └── Constants.ets
│       └── resources/           # 资源文件
├── docs/                        # 文档
│   ├── 功能规划文档.md
│   └── 开发方案.md
├── build-profile.json5          # 构建配置
├── hvigorfile.ts               # 构建脚本
└── oh-package.json5            # 依赖配置
```

## 开发环境

- DevEco Studio 5.0+
- HarmonyOS SDK API 18+
- Node.js 18+

## 构建运行

```bash
# 安装依赖
ohpm install

# 构建 HAP
hvigorw assembleHap -p product=default

# 安装到设备
hdc install entry-default-signed.hap
```

## 权限说明

应用需要以下权限：

| 权限 | 用途 |
|------|------|
| ohos.permission.CAMERA | 相机访问 |
| ohos.permission.MICROPHONE | 麦克风录音 |
| ohos.permission.WRITE_MEDIA | 保存视频文件 |
| ohos.permission.READ_MEDIA | 读取媒体文件 |

## 适用场景

- Vlog 博主双视角录制
- 采访记录（采访者+受访者）
- 运动教学（教练视角+动作视角）
- 旅行记录（风景+自拍）
- 产品展示（细节+全景）

## 注意事项

1. **设备要求** - 需要支持双摄并发功能的 HarmonyOS NEXT 设备
2. **并发限制** - 并发模式下仅支持 7 个基础功能：闪光灯、曝光、变焦、曝光补偿、对焦、防抖、色彩空间
3. **存储空间** - 高清双摄录制需要较大存储空间，建议定期清理

## 版本历史

### v1.0.0
- 实现双摄并发预览
- 支持分屏/画中画录制
- 完整设置功能
- 相机控制面板
- 视频保存到相册

## 许可证

MIT License

## 作者

Claude Code Assistant
