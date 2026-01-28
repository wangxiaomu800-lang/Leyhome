
import React, { useState } from 'react';
import SplashView from './views/SplashView';
import MainTabView from './views/MainTabView';

const App: React.FC = () => {
  const [isSplashFinished, setIsSplashFinished] = useState(false);

  return (
    <div className="relative w-full h-full">
      {!isSplashFinished ? (
        <SplashView onFinished={() => setIsSplashFinished(true)} />
      ) : (
        <div className="animate-in fade-in duration-1000">
          <MainTabView />
        </div>
      )}
    </div>
  );
};

export default App;
