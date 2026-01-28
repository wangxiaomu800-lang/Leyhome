
import React, { useState, useEffect } from 'react';
import { LEYHOME_THEME } from '../constants';

interface SplashViewProps {
  onFinished: () => void;
}

const SplashView: React.FC<SplashViewProps> = ({ onFinished }) => {
  const [hasStartedAnimation, setHasStartedAnimation] = useState(false);
  const [hasFinishedLoading, setHasFinishedLoading] = useState(false);

  useEffect(() => {
    // Start entry animations
    const timer1 = setTimeout(() => setHasStartedAnimation(true), 100);
    
    // Simulate loading
    const timer2 = setTimeout(() => setHasFinishedLoading(true), 2000);
    
    // Transition to main screen
    const timer3 = setTimeout(() => onFinished(), 3500);

    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
      clearTimeout(timer3);
    };
  }, [onFinished]);

  return (
    <div 
      className="fixed inset-0 z-50 flex flex-col items-center justify-between py-24 transition-opacity duration-1000"
      style={{ 
        backgroundColor: LEYHOME_THEME.background,
        opacity: 1
      }}
    >
      <div className="flex-1 flex flex-col items-center justify-center">
        {/* Core Energy Point */}
        <div className="relative w-40 h-40 flex items-center justify-center mb-12">
          {/* Breathing Glow */}
          <div 
            className={`absolute w-32 h-32 rounded-full animate-breathe transition-opacity duration-1000 ${hasStartedAnimation ? 'opacity-100' : 'opacity-0'}`}
            style={{ 
              background: `radial-gradient(circle, ${LEYHOME_THEME.primary}4D 0%, transparent 70%)` 
            }}
          />
          
          {/* Central Point */}
          <div 
            className={`w-2 h-2 rounded-full transition-all duration-1000 delay-300 ${hasStartedAnimation ? 'scale-100 opacity-100' : 'scale-0 opacity-0'}`}
            style={{ 
              backgroundColor: LEYHOME_THEME.primary,
              boxShadow: `0 0 15px ${LEYHOME_THEME.primary}`
            }}
          />
        </div>

        {/* Titles */}
        <div 
          className={`text-center space-y-4 transition-all duration-1000 delay-500 ${hasStartedAnimation ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'}`}
        >
          <h1 
            className="text-4xl font-light tracking-[0.2em]"
            style={{ color: LEYHOME_THEME.textPrimary }}
          >
            地脉归途
          </h1>
          <p 
            className="text-xs font-poetic tracking-[0.5em] uppercase"
            style={{ color: LEYHOME_THEME.textSecondary }}
          >
            Leyhome
          </p>
        </div>
      </div>

      {/* Loading Hint */}
      <div 
        className={`transition-opacity duration-500 ${hasStartedAnimation ? 'opacity-100' : 'opacity-0'}`}
      >
        <span 
          className="text-xs font-light tracking-widest italic"
          style={{ color: LEYHOME_THEME.textMuted }}
        >
          {hasFinishedLoading ? "回归内在世界" : "正在唤醒地脉..."}
        </span>
      </div>
    </div>
  );
};

export default SplashView;
