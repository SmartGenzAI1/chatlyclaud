// Security headers and configurations for Chatly Web App

// Content Security Policy
const csp = {
  'default-src': ["'self'"],
  'script-src': [
    "'self'",
    "'unsafe-inline'", // Only for development, remove in production
    "'unsafe-eval'", // Only for Flutter Web, remove if possible
    "https://*.firebaseio.com",
    "https://*.googleapis.com",
    "https://*.gstatic.com"
  ],
  'style-src': [
    "'self'",
    "'unsafe-inline'",
    "https://*.googleapis.com"
  ],
  'img-src': [
    "'self'",
    "data:",
    "https:",
    "blob:"
  ],
  'media-src': [
    "'self'",
    "data:",
    "https:",
    "blob:"
  ],
  'connect-src': [
    "'self'",
    "https://*.firebaseio.com",
    "https://*.googleapis.com",
    "https://*.gstatic.com",
    "wss://*.firebaseio.com",
    "https://*.google.com"
  ],
  'font-src': [
    "'self'",
    "https://*.googleapis.com",
    "data:"
  ],
  'object-src': ["'none'"],
  'base-uri': ["'self'"],
  'form-action': ["'self'"],
  'frame-ancestors': ["'none'"],
  'upgrade-insecure-requests': []
};

// Security headers middleware
function setSecurityHeaders(req, res, next) {
  // Content Security Policy
  const cspString = Object.entries(csp)
    .map(([directive, sources]) => {
      const sourceList = sources.length > 0 ? sources.join(' ') : '';
      return `${directive} ${sourceList}`;
    })
    .join('; ');
  
  res.setHeader('Content-Security-Policy', cspString);
  
  // Other security headers
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  
  // Remove server information
  res.removeHeader('X-Powered-By');
  
  next();
}

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests from these origins
    const allowedOrigins = [
      'https://chatly.app',
      'https://www.chatly.app',
      'https://chatly-web.vercel.app',
      'https://chatly.pages.dev',
      'http://localhost:5000', // Development
      'http://127.0.0.1:5000' // Development
    ];
    
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

// Rate limiting configuration
const rateLimitConfig = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
};

// Input validation middleware
function validateInput(req, res, next) {
  // Sanitize request body
  if (req.body) {
    for (const key in req.body) {
      if (typeof req.body[key] === 'string') {
        // Basic XSS prevention
        req.body[key] = req.body[key].replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
        req.body[key] = req.body[key].replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '');
      }
    }
  }
  
  // Validate content length
  if (req.body && req.body.message) {
    if (req.body.message.length > 10000) {
      return res.status(400).json({ error: 'Message too long' });
    }
  }
  
  next();
}

// Security utilities
const securityUtils = {
  // Generate secure random string
  generateSecureId: function(length = 32) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  },
  
  // Hash function for sensitive data
  hashData: function(data) {
    // Simple hash for client-side use
    let hash = 0;
    if (data.length === 0) return hash.toString();
    for (let i = 0; i < data.length; i++) {
      const char = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.toString();
  },
  
  // Check if request is from a bot
  isBotRequest: function(userAgent) {
    const botPatterns = [
      /bot/i,
      /crawler/i,
      /spider/i,
      /scraper/i,
      /curl/i,
      /wget/i
    ];
    
    return botPatterns.some(pattern => pattern.test(userAgent));
  }
};

// Export for use in server
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    setSecurityHeaders,
    corsOptions,
    rateLimitConfig,
    validateInput,
    securityUtils
  };
}

// For browser usage
if (typeof window !== 'undefined') {
  window.ChatlySecurity = securityUtils;
}