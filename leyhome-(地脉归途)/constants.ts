
export const LEYHOME_THEME = {
  background: '#F5F0E6', // Warm white (unbleached paper)
  surface: 'rgba(255, 255, 255, 0.8)',
  primary: '#D4A574',    // Amber gold (energy and wisdom)
  secondary: '#A8C8E8',  // Star blue (dreams and accents)
  textPrimary: '#2D5A4E', // Deep teal (calm and life)
  textSecondary: '#6B7280', // Gray-500
  textMuted: 'rgba(107, 114, 128, 0.6)',
  success: '#66B380',
  warning: '#E6B366',
  danger: '#CC8080',
};

export type TabId = 'map' | 'sites' | 'guidance' | 'profile';

export interface TabConfig {
  id: TabId;
  icon: string;
  label: string;
  title: string;
  subtitle: string;
}

export const TABS: TabConfig[] = [
  {
    id: 'map',
    icon: 'M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7',
    label: '地图',
    title: '心灵地图',
    subtitle: '你的每一步，都在绘制独一无二的心灵画卷'
  },
  {
    id: 'sites',
    icon: 'M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-7.714 2.143L11 21l-2.286-6.857L1 12l7.714-2.143L11 3z',
    label: '圣迹',
    title: '圣迹',
    subtitle: '探索世界的能量节点，感受孤独的共鸣'
  },
  {
    id: 'guidance',
    icon: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
    label: '引路',
    title: '引路',
    subtitle: '跟随先行者的脚步，借他人之光照亮自己的路'
  },
  {
    id: 'profile',
    icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z',
    label: '我的',
    title: '我的',
    subtitle: '回顾你的成长，整理内在世界'
  }
];
