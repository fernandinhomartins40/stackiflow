/**
 * Stacki Configuration
 * Tailwind-Native Visual Website Builder
 */

export const stackiConfig = {
  // Branding
  name: "Stacki",
  version: "0.1.0",
  description: "Tailwind-Native Visual Website Builder",
  
  // Features
  features: {
    tailwindNative: true,
    cleanCodeExport: true,
    selfHosting: true,
    simplifiedUI: true,
  },
  
  // Tailwind Configuration
  tailwind: {
    // Default Tailwind config for Stacki projects
    defaultConfig: {
      content: ["./src/**/*.{html,js,ts,jsx,tsx}"],
      theme: {
        extend: {
          // Stacki custom design tokens
        }
      },
      plugins: [],
    },
    
    // Enhanced utilities for visual builder
    enhancedUtilities: [
      "spacing",
      "colors", 
      "typography",
      "layout",
      "effects"
    ]
  },
  
  // Export Settings
  export: {
    format: "html-tailwind",
    cleanOutput: true,
    vendorLockIn: false,
    includeConfig: true
  },
  
  // UI Configuration
  ui: {
    theme: "stacki-default",
    simplifiedPanels: true,
    tailwindFirst: true,
    hideComplexOptions: true
  }
};

export default stackiConfig;