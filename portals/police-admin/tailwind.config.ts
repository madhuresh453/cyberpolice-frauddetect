import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: { "2xl": "1400px" },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        cyan: {
          DEFAULT: "hsl(var(--cyan))",
          foreground: "hsl(var(--cyan-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "pulse-slow": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.5" },
        },
        "glow": {
          "0%, 100%": { boxShadow: "0 0 5px hsl(var(--primary)), 0 0 10px hsl(var(--primary))" },
          "50%": { boxShadow: "0 0 20px hsl(var(--primary)), 0 0 30px hsl(var(--primary))" },
        },
        "slide-up": {
          "0%": { transform: "translateY(10px)", opacity: "0" },
          "100%": { transform: "translateY(0)", opacity: "1" },
        },
        "fade-in": {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        "shimmer": {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
        "counter": {
          "0%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-50%)", opacity: "0" },
          "100%": { transform: "translateY(0)", opacity: "1" },
        },
      },
      animation: {
        "pulse-slow": "pulse-slow 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "glow": "glow 2s ease-in-out infinite",
        "slide-up": "slide-up 0.3s ease-out",
        "fade-in": "fade-in 0.5s ease-out",
        "shimmer": "shimmer 2s infinite",
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-cyber": "linear-gradient(135deg, hsl(var(--primary)) 0%, hsl(var(--cyan)) 100%)",
        "gradient-card": "linear-gradient(135deg, hsl(var(--card)) 0%, hsl(var(--card)) 100%)",
        "shimmer-gradient": "linear-gradient(90deg, transparent 0%, rgba(255,255,255,0.05) 50%, transparent 100%)",
      },
      boxShadow: {
        "cyber": "0 0 15px -3px hsl(var(--primary) / 0.3), 0 0 6px -4px hsl(var(--primary) / 0.2)",
        "cyber-lg": "0 0 30px -5px hsl(var(--primary) / 0.4), 0 0 10px -5px hsl(var(--primary) / 0.3)",
        "glass": "0 4px 30px rgba(0, 0, 0, 0.1)",
        "glow": "0 0 20px hsl(var(--primary) / 0.5)",
        "card-hover": "0 8px 30px rgba(0, 0, 0, 0.12)",
      },
      backdropBlur: {
        xs: "2px",
      },
    },
  },
  plugins: [],
};

export default config;