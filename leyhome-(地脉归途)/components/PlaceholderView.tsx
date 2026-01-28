
import React from 'react';
import { LEYHOME_THEME } from '../constants';

interface PlaceholderViewProps {
  icon: string;
  title: string;
  subtitle: string;
}

const PlaceholderView: React.FC<PlaceholderViewProps> = ({ icon, title, subtitle }) => {
  return (
    <div 
      className="flex flex-col items-center justify-center min-h-screen px-8 text-center"
      style={{ backgroundColor: LEYHOME_THEME.background }}
    >
      <div className="mb-8">
        <svg 
          className="w-16 h-16 stroke-[0.5]" 
          fill="none" 
          viewBox="0 0 24 24" 
          stroke={LEYHOME_THEME.primary}
        >
          <path strokeLinecap="round" strokeLinejoin="round" d={icon} />
        </svg>
      </div>
      
      <h2 
        className="text-2xl font-light mb-4 tracking-wider"
        style={{ color: LEYHOME_THEME.textPrimary }}
      >
        {title}
      </h2>
      
      <p 
        className="text-sm font-light leading-relaxed max-w-xs"
        style={{ color: LEYHOME_THEME.textSecondary }}
      >
        {subtitle}
      </p>
    </div>
  );
};

export default PlaceholderView;
