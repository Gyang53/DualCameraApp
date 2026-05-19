import { SettingsViewModel } from '../viewmodels/SettingsViewModel';
import { Logger } from '../utils/Logger';

const TAG = 'Settings';

@Entry
@Component
struct Settings {
  @State viewModel: SettingsViewModel = new SettingsViewModel();
  @State currentTab: number = 0;

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#2A2A2A')

      // 设置内容区
      Tabs() {
        TabContent() {
          this.RecordSettings()
        }
        .tabBar('录像')

        TabContent() {
          this.DisplaySettings()
        }
        .tabBar('画面')

        TabContent() {
          this.AudioSettings()
        }
        .tabBar('音频')

        TabContent() {
          this.AdvancedSettings()
        }
        .tabBar('高级')
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .barPosition(BarPosition.End)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A')
  }

  @Builder
  RecordSettings() {
    Column() {
      this.SettingItem('录制时长限制', '10分钟')
      this.SettingItem('文件保存方式', '合并文件')
      this.SettingItem('默认录制模式', '保持上次')
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  DisplaySettings() {
    Column() {
      this.SettingItem('分屏默认比例', '50:50')
      this.SettingItem('画中画默认位置', '右上')
      this.SettingItem('前置镜像翻转', '关')
      this.SettingItem('网格线辅助', '关')
      this.SettingItem('时间戳水印', '关')
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  AudioSettings() {
    Column() {
      this.SettingItem('音频模式', '共用音轨')
      this.SettingItem('麦克风选择', '系统默认')
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  AdvancedSettings() {
    Column() {
      this.SettingItem('色彩空间', '自动')
      this.SettingItem('前摄补光', '关')
      this.SettingItem('低光提示', '开')
      this.SettingItem('存储空间提醒', '开')
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  SettingItem(title: string, value: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(Color.White)
      Blank()
      Text(value)
        .fontSize(14)
        .fontColor('#888888')
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#2A2A2A')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}
