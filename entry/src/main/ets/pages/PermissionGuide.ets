import { PermissionService } from '../services/PermissionService';
import { Logger } from '../utils/Logger';

const TAG = 'PermissionGuide';

@Entry
@Component
struct PermissionGuide {
  @State hasCameraPermission: boolean = false;
  @State hasMicPermission: boolean = false;
  @State hasMediaPermission: boolean = false;
  private permissionService: PermissionService = new PermissionService();

  build() {
    Column() {
      Text('权限说明')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 30 })

      this.PermissionItem('相机权限', '用于双摄录像功能', this.hasCameraPermission)
      this.PermissionItem('麦克风权限', '用于录制视频音频', this.hasMicPermission)
      this.PermissionItem('存储权限', '用于保存视频文件到相册', this.hasMediaPermission)

      Button('授予权限')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#FF0000')
        .margin({ top: 30 })
        .onClick(() => {
          this.requestPermissions();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#1A1A1A')
    .padding(20)
  }

  @Builder
  PermissionItem(title: string, desc: string, granted: boolean) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor(Color.White)
        Text(desc)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (granted) {
        Text('已授权')
          .fontSize(14)
          .fontColor('#00FF00')
      }
    }
    .width('100%')
    .height(70)
    .padding(16)
    .backgroundColor('#2A2A2A')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  private async requestPermissions(): Promise<void> {
    const context = getContext(this);
    this.hasCameraPermission = await this.permissionService.requestCameraPermission(context);
    this.hasMicPermission = await this.permissionService.requestMicrophonePermission(context);
    this.hasMediaPermission = await this.permissionService.requestMediaPermission(context);
  }
}
