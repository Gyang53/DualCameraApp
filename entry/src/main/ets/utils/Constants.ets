export class Constants {
  // 应用信息
  static readonly APP_NAME = '双摄大师';
  static readonly APP_VERSION = '1.0.0';

  // 录制时长限制（毫秒）
  static readonly MAX_DURATION_5_MIN = 5 * 60 * 1000;
  static readonly MAX_DURATION_10_MIN = 10 * 60 * 1000;
  static readonly MAX_DURATION_15_MIN = 15 * 60 * 1000;
  static readonly MAX_DURATION_30_MIN = 30 * 60 * 1000;
  static readonly MAX_DURATION_UNLIMITED = -1;

  // 分屏比例
  static readonly SPLIT_RATIO_50_50 = 0.5;
  static readonly SPLIT_RATIO_70_30 = 0.7;
  static readonly SPLIT_RATIO_30_70 = 0.3;

  // 画中画位置
  static readonly PIP_POSITION_TOP_LEFT = 'topLeft';
  static readonly PIP_POSITION_TOP_RIGHT = 'topRight';
  static readonly PIP_POSITION_BOTTOM_LEFT = 'bottomLeft';
  static readonly PIP_POSITION_BOTTOM_RIGHT = 'bottomRight';

  // 录制模式
  static readonly RECORD_MODE_SPLIT = 'split';
  static readonly RECORD_MODE_PIP = 'pip';

  // 文件保存模式
  static readonly FILE_MODE_MERGED = 'merged';
  static readonly FILE_MODE_SEPARATE = 'separate';

  // 视频参数默认值
  static readonly DEFAULT_BITRATE = 5000000; // 5Mbps
  static readonly DEFAULT_FRAME_RATE = 30;
  static readonly DEFAULT_VIDEO_WIDTH = 1920;
  static readonly DEFAULT_VIDEO_HEIGHT = 1080;
}
