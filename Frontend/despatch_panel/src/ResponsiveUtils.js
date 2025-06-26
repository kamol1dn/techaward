// ResponsiveUtils.js - Create this new file
import { useMediaQuery } from 'react-responsive';

// Custom hooks for different breakpoints
export const useIsMobile = () => {
  return useMediaQuery({ query: '(max-width: 768px)' });
};

export const useIsTablet = () => {
  return useMediaQuery({ query: '(min-width: 769px) and (max-width: 1024px)' });
};

export const useIsDesktop = () => {
  return useMediaQuery({ query: '(min-width: 1025px)' });
};

export const useIsSmallScreen = () => {
  return useMediaQuery({ query: '(max-width: 640px)' });
};

export const useIsLargeScreen = () => {
  return useMediaQuery({ query: '(min-width: 1280px)' });
};

// Responsive component wrapper
export const ResponsiveWrapper = ({ children, mobile, tablet, desktop }) => {
  const isMobile = useIsMobile();
  const isTablet = useIsTablet();
  const isDesktop = useIsDesktop();

  if (isMobile && mobile) return mobile;
  if (isTablet && tablet) return tablet;
  if (isDesktop && desktop) return desktop;

  return children;
};