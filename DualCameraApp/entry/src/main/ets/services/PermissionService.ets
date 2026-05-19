import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { Logger } from '../utils/Logger';

const TAG = 'PermissionService';

export class PermissionService {
  private async checkPermission(context: common.Context, permission: Permissions): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const grantStatus = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, permission);
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  private async requestPermission(context: common.Context, permission: Permissions): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(context, [permission]);
    return result.authResults[0] === 0;
  }

  async checkCameraPermission(context: common.Context): Promise<boolean> {
    return this.checkPermission(context, 'ohos.permission.CAMERA');
  }

  async requestCameraPermission(context: common.Context): Promise<boolean> {
    const hasPermission = await this.checkCameraPermission(context);
    if (hasPermission) {
      return true;
    }
    return this.requestPermission(context, 'ohos.permission.CAMERA');
  }

  async checkMicrophonePermission(context: common.Context): Promise<boolean> {
    return this.checkPermission(context, 'ohos.permission.MICROPHONE');
  }

  async requestMicrophonePermission(context: common.Context): Promise<boolean> {
    const hasPermission = await this.checkMicrophonePermission(context);
    if (hasPermission) {
      return true;
    }
    return this.requestPermission(context, 'ohos.permission.MICROPHONE');
  }

  async checkMediaPermission(context: common.Context): Promise<boolean> {
    const readPermission = await this.checkPermission(context, 'ohos.permission.READ_MEDIA');
    const writePermission = await this.checkPermission(context, 'ohos.permission.WRITE_MEDIA');
    return readPermission && writePermission;
  }

  async requestMediaPermission(context: common.Context): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(context, [
      'ohos.permission.READ_MEDIA',
      'ohos.permission.WRITE_MEDIA'
    ]);
    return result.authResults.every(r => r === 0);
  }

  async checkAllPermissions(context: common.Context): Promise<boolean> {
    const camera = await this.checkCameraPermission(context);
    const mic = await this.checkMicrophonePermission(context);
    const media = await this.checkMediaPermission(context);
    return camera && mic && media;
  }

  async requestAllPermissions(context: common.Context): Promise<boolean> {
    const camera = await this.requestCameraPermission(context);
    const mic = await this.requestMicrophonePermission(context);
    const media = await this.requestMediaPermission(context);
    return camera && mic && media;
  }
}
