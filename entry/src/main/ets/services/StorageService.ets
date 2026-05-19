import { preferences } from '@kit.ArkData';
import { Logger } from '../utils/Logger';
import { UserSettings } from '../common/Types';

const TAG = 'StorageService';
const STORE_NAME = 'dual_camera_settings';

export class StorageService {
  private prefs: preferences.Preferences | null = null;

  async initialize(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, STORE_NAME);
      Logger.info(TAG, 'Storage initialized');
    } catch (error) {
      Logger.error(TAG, `Initialize failed: ${JSON.stringify(error)}`);
    }
  }

  async saveSettings(settings: UserSettings): Promise<boolean> {
    if (!this.prefs) {
      return false;
    }

    try {
      await this.prefs.put('recordMode', settings.recordMode);
      await this.prefs.put('splitRatio', settings.splitRatio);
      await this.prefs.put('pipPosition', settings.pipPosition);
      await this.prefs.put('maxDuration', settings.maxDuration);
      await this.prefs.put('fileMode', settings.fileMode);
      await this.prefs.put('frontMirror', settings.frontMirror);
      await this.prefs.put('gridLine', settings.gridLine);
      await this.prefs.put('timestamp', settings.timestamp);
      await this.prefs.put('audioMode', settings.audioMode);
      await this.prefs.put('colorSpace', settings.colorSpace);
      await this.prefs.put('frontLight', settings.frontLight);
      await this.prefs.put('lowLightHint', settings.lowLightHint);
      await this.prefs.put('storageHint', settings.storageHint);
      await this.prefs.flush();
      
      Logger.info(TAG, 'Settings saved');
      return true;
    } catch (error) {
      Logger.error(TAG, `Save settings failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async loadSettings(): Promise<UserSettings> {
    const defaultSettings: UserSettings = this.getDefaultSettings();

    if (!this.prefs) {
      return defaultSettings;
    }

    try {
      return {
        recordMode: await this.prefs.get('recordMode', defaultSettings.recordMode) as 'split' | 'pip',
        splitRatio: await this.prefs.get('splitRatio', defaultSettings.splitRatio) as number,
        pipPosition: await this.prefs.get('pipPosition', defaultSettings.pipPosition) as 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight',
        maxDuration: await this.prefs.get('maxDuration', defaultSettings.maxDuration) as number,
        fileMode: await this.prefs.get('fileMode', defaultSettings.fileMode) as 'merged' | 'separate',
        frontMirror: await this.prefs.get('frontMirror', defaultSettings.frontMirror) as boolean,
        gridLine: await this.prefs.get('gridLine', defaultSettings.gridLine) as boolean,
        timestamp: await this.prefs.get('timestamp', defaultSettings.timestamp) as boolean,
        audioMode: await this.prefs.get('audioMode', defaultSettings.audioMode) as 'shared' | 'separate',
        colorSpace: await this.prefs.get('colorSpace', defaultSettings.colorSpace) as 'auto' | 'sdr' | 'hdr',
        frontLight: await this.prefs.get('frontLight', defaultSettings.frontLight) as boolean,
        lowLightHint: await this.prefs.get('lowLightHint', defaultSettings.lowLightHint) as boolean,
        storageHint: await this.prefs.get('storageHint', defaultSettings.storageHint) as boolean,
      };
    } catch (error) {
      Logger.error(TAG, `Load settings failed: ${JSON.stringify(error)}`);
      return defaultSettings;
    }
  }

  getDefaultSettings(): UserSettings {
    return {
      recordMode: 'split',
      splitRatio: 0.5,
      pipPosition: 'topRight',
      maxDuration: 600000, // 10 minutes
      fileMode: 'merged',
      frontMirror: false,
      gridLine: false,
      timestamp: false,
      audioMode: 'shared',
      colorSpace: 'auto',
      frontLight: false,
      lowLightHint: true,
      storageHint: true,
    };
  }

  async clearSettings(): Promise<void> {
    if (!this.prefs) {
      return;
    }

    try {
      await this.prefs.clear();
      await this.prefs.flush();
      Logger.info(TAG, 'Settings cleared');
    } catch (error) {
      Logger.error(TAG, `Clear settings failed: ${JSON.stringify(error)}`);
    }
  }
}
