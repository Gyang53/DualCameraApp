import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from './Logger';

const TAG = 'FileUtils';

export class FileUtils {
  static async createVideoFile(context: Context, fileName: string): Promise<string> {
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(context);
      const fileNameWithExt = fileName.endsWith('\.mp4') ? fileName : `${fileName}\.mp4`;

      const assetOptions: photoAccessHelper.CreateOptions = {
        title: fileNameWithExt
      };

      const createAssetUri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', assetOptions);
      Logger.info(TAG, `Created video file: ${createAssetUri}`);
      return createAssetUri;
    } catch (error) {
      Logger.error(TAG, `Failed to create video file: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  static generateFileName(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hour = String(now.getHours()).padStart(2, '0');
    const minute = String(now.getMinutes()).padStart(2, '0');
    const second = String(now.getSeconds()).padStart(2, '0');
    return `VID_${year}${month}${day}_${hour}${minute}${second}`;
  }

  static formatDuration(milliseconds: number): string {
    const totalSeconds = Math.floor(milliseconds / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }
    return `${minutes}:${String(seconds).padStart(2, '0')}`;
  }
}
