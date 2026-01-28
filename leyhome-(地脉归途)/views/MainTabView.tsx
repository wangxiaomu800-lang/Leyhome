
import React, { useState } from 'react';
import { LEYHOME_THEME, TABS, TabId } from '../constants';
import PlaceholderView from '../components/PlaceholderView';

const MainTabView: React.FC = () => {
  const [activeTab, setActiveTab] = useState<TabId>('map');

  const currentTabConfig = TABS.find(t => t.id === activeTab) || TABS[0];

  return (
    <div className="relative min-h-screen flex flex-col" style={{ backgroundColor: LEYHOME_THEME.background }}>
      {/* Content Area */}
      <main className="flex-1 pb-20 overflow-auto animate-in fade-in duration-700">
        <PlaceholderView 
          icon={currentTabConfig.icon}
          title={currentTabConfig.title}
          subtitle={currentTabConfig.subtitle}
        />
      </main>

      {/* Poetic Bottom Tab Bar */}
      <nav 
        className="fixed bottom-0 left-0 right-0 h-20 px-6 pb-6 flex items-center justify-around z-40 backdrop-blur-md"
        style={{ backgroundColor: `${LEYHOME_THEME.background}CC` }}
      >
        {TABS.map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className="group flex flex-col items-center justify-center space-y-1 relative outline-none"
            >
              <div className="relative">
                <svg 
                  className={`w-6 h-6 transition-all duration-300 ${isActive ? 'scale-110' : 'scale-100'}`}
                  fill={isActive ? LEYHOME_THEME.primary : 'none'}
                  stroke={isActive ? LEYHOME_THEME.primary : LEYHOME_THEME.textSecondary}
                  strokeWidth={isActive ? "1.5" : "1"}
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d={tab.icon} />
                </svg>
                
                {/* Active indicator dot */}
                {isActive && (
                  <div 
                    className="absolute -top-1 -right-1 w-1 h-1 rounded-full"
                    style={{ backgroundColor: LEYHOME_THEME.primary }}
                  />
                )}
              </div>
              
              <span 
                className={`text-[10px] tracking-widest transition-colors duration-300 ${isActive ? 'font-medium' : 'font-light'}`}
                style={{ color: isActive ? LEYHOME_THEME.textPrimary : LEYHOME_THEME.textSecondary }}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
};

export default MainTabView;
