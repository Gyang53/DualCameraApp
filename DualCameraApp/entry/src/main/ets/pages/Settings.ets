import { SettingsViewModel } from '../viewmodels/SettingsViewModel';
import { Logger } from '../utils/Logger';
import { router } from '@kit.ArkUI';
import { UserSettings } from '../common/Types';

const TAG = 'Settings';

interface DurationOption {
  value: number;
  label: string;
}

@ComponentV2
struct SettingSwitchItem {
  @Param title: string = '';
  @Param value: boolean = false;
  @Event onChange: (value: boolean) => void = () => {};

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .fontColor(Color.White)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.value })
        .onChange((isOn: boolean) => {
          this.onChange(isOn);
        })
        .selectedColor('#4CAF50')
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#2A2A2A')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}

@ComponentV2
struct SettingSelectItem {
  @Param title: string = '';
  @Param value: string = '';
  @Param options: string[] = [];
  @Event onSelect: (index: number) => void = () => {};

  @Local showPicker: boolean = false;

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .fontColor(Color.White)
      Blank()
      Row() {
        Text(this.value)
          .fontSize(14)
          .fontColor('#888888')
        Text('>')
          .fontSize(14)
          .fontColor('#888888')
          .margin({ left: 8 })
      }
      .onClick(() => {
        this.showPicker = true;
      })
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#2A2A2A')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .bindSheet($$this.showPicker, this.PickerSheet(), {
      height: 300,
      backgroundColor: '#1A1A1A'
    })
  }

  @Builder
  PickerSheet() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 16, bottom: 16 })

      List() {
        ForEach(this.options, (option: string, index: number) => {
          ListItem() {
            Row() {
              Text(option)
                .fontSize(16)
                .fontColor(this.value === option ? '#4CAF50' : Color.White)
              if (this.value === option) {
                Text('✓')
                  .fontSize(16)
                  .fontColor('#4CAF50')
                  .margin({ left: 8 })
              }
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.onSelect(index);
              this.showPicker = false;
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}

@Entry
@ComponentV2
struct Settings {
  @Local viewModel: SettingsViewModel = new SettingsViewModel();
  @Local currentTab: number = 0;

  private durationOptions: DurationOption[] = [
    { value: 300000, label: '5分钟' },
    { value: 600000, label: '10分钟' },
    { value: 900000, label: '15分钟' },
    { value: 1800000, label: '30分钟' },
    { value: -1, label: '无限制' }
  ];

  async aboutToAppear(): Promise<void> {
    await this.viewModel.initialize(getContext(this));
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#4CAF50')
          .onClick(() => {
            router.back();
          })

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('    ')
          .fontSize(16)
          .width(50)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2A2A2A')

      // 设置内容区
      Tabs({ index: $$this.currentTab }) {
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
      .backgroundColor('#1A1A1A')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A')
  }

  @Builder
  RecordSettings() {
    Scroll() {
      Column() {
        if (this.viewModel.settings) {
          SettingSelectItem({
            title: '录制时长限制',
            value: this.viewModel.getDurationLabel(this.viewModel.settings!.maxDuration),
            options: this.durationOptions.map((item: DurationOption) => item.label),
            onSelect: (index: number) => {
              this.viewModel.updateMaxDuration(this.durationOptions[index].value);
            }
          })

          SettingSelectItem({
            title: '文件保存方式',
            value: this.viewModel.getFileModeLabel(this.viewModel.settings!.fileMode),
            options: ['合并文件', '分开文件'],
            onSelect: (index: number) => {
              this.viewModel.updateFileMode(index === 0 ? 'merged' : 'separate');
            }
          })

          SettingSelectItem({
            title: '默认录制模式',
            value: this.viewModel.settings!.recordMode === 'split' ? '分屏' : '画中画',
            options: ['分屏', '画中画'],
            onSelect: (index: number) => {
              this.viewModel.updateRecordMode(index === 0 ? 'split' : 'pip');
            }
          })
        } else {
          Text('加载中...')
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DisplaySettings() {
    Scroll() {
      Column() {
        if (this.viewModel.settings) {
          SettingSelectItem({
            title: '分屏默认比例',
            value: this.viewModel.getSplitRatioLabel(this.viewModel.settings!.splitRatio),
            options: ['30:70', '50:50', '70:30'],
            onSelect: (index: number) => {
              const ratios: number[] = [0.3, 0.5, 0.7];
              this.viewModel.updateSplitRatio(ratios[index]);
            }
          })

          SettingSelectItem({
            title: '画中画默认位置',
            value: this.viewModel.getPipPositionLabel(this.viewModel.settings!.pipPosition),
            options: ['左上', '右上', '左下', '右下'],
            onSelect: (index: number) => {
              const positions: ('topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight')[] =
                ['topLeft', 'topRight', 'bottomLeft', 'bottomRight'];
              this.viewModel.updatePipPosition(positions[index]);
            }
          })

          SettingSwitchItem({
            title: '前置镜像翻转',
            value: this.viewModel.settings!.frontMirror,
            onChange: (value: boolean) => {
              this.viewModel.updateFrontMirror(value);
            }
          })

          SettingSwitchItem({
            title: '网格线辅助',
            value: this.viewModel.settings!.gridLine,
            onChange: (value: boolean) => {
              this.viewModel.updateGridLine(value);
            }
          })

          SettingSwitchItem({
            title: '时间戳水印',
            value: this.viewModel.settings!.timestamp,
            onChange: (value: boolean) => {
              this.viewModel.updateTimestamp(value);
            }
          })
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AudioSettings() {
    Scroll() {
      Column() {
        if (this.viewModel.settings) {
          SettingSelectItem({
            title: '音频模式',
            value: this.viewModel.getAudioModeLabel(this.viewModel.settings!.audioMode),
            options: ['共用音轨', '独立音轨'],
            onSelect: (index: number) => {
              this.viewModel.updateAudioMode(index === 0 ? 'shared' : 'separate');
            }
          })
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AdvancedSettings() {
    Scroll() {
      Column() {
        if (this.viewModel.settings) {
          SettingSelectItem({
            title: '色彩空间',
            value: this.viewModel.getColorSpaceLabel(this.viewModel.settings!.colorSpace),
            options: ['自动', 'SDR', 'HDR'],
            onSelect: (index: number) => {
              const spaces: ('auto' | 'sdr' | 'hdr')[] = ['auto', 'sdr', 'hdr'];
              this.viewModel.updateColorSpace(spaces[index]);
            }
          })

          SettingSwitchItem({
            title: '前摄补光',
            value: this.viewModel.settings!.frontLight,
            onChange: (value: boolean) => {
              this.viewModel.updateFrontLight(value);
            }
          })

          SettingSwitchItem({
            title: '低光提示',
            value: this.viewModel.settings!.lowLightHint,
            onChange: (value: boolean) => {
              this.viewModel.updateLowLightHint(value);
            }
          })

          SettingSwitchItem({
            title: '存储空间提醒',
            value: this.viewModel.settings!.storageHint,
            onChange: (value: boolean) => {
              this.viewModel.updateStorageHint(value);
            }
          })

          // 重置按钮
          Button('恢复默认设置')
            .width('100%')
            .height(50)
            .fontSize(16)
            .fontColor('#FF5722')
            .backgroundColor('#2A2A2A')
            .borderRadius(8)
            .margin({ top: 24 })
            .onClick(() => {
              this.viewModel.resetToDefaults();
            })
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}

export default Settings;
