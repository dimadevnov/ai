const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com', 'http://yourdomain.com']
    : ['http://localhost:3000'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

app.use(express.json({ limit: '10mb' }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Chat endpoint that proxies to Groq API
app.post('/api/chat', async (req, res) => {
  try {
    const { message, history = [] } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ 
        error: 'Message is required and must be a string' 
      });
    }

    if (!process.env.GROQ_API_KEY) {
      console.error('GROQ_API_KEY is not configured');
      return res.status(500).json({ 
        error: 'Server configuration error' 
      });
    }

    // Prepare messages for Groq API
    const messages = [
      {
        role: 'system',
        content: 'You are a helpful AI assistant. Provide clear, concise, and accurate responses. Be friendly and professional.'
      },
      ...history,
      {
        role: 'user',
        content: message
      }
    ];

    console.log('Sending request to Groq API:', { messageCount: messages.length });

    const response = await axios.post('https://api.groq.com/openai/v1/chat/completions', {
      model: 'mixtral-8x7b-32768', // You can change this to other Groq models
      messages: messages,
      max_tokens: 1000,
      temperature: 0.7,
      top_p: 1,
      stream: false
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
        'Content-Type': 'application/json'
      },
      timeout: 30000 // 30 seconds timeout
    });

    const assistantResponse = response.data.choices[0]?.message?.content;
    
    if (!assistantResponse) {
      console.error('Invalid response from Groq API:', response.data);
      return res.status(500).json({ 
        error: 'Invalid response from AI service' 
      });
    }

    console.log('Successfully received response from Groq API');

    res.json({ 
      response: assistantResponse,
      model: response.data.model,
      usage: response.data.usage
    });

  } catch (error) {
    console.error('Error in chat endpoint:', error.message);
    
    if (error.response) {
      // Groq API error
      console.error('Groq API error:', {
        status: error.response.status,
        data: error.response.data
      });
      
      if (error.response.status === 401) {
        return res.status(500).json({ 
          error: 'AI service authentication failed' 
        });
      } else if (error.response.status === 429) {
        return res.status(429).json({ 
          error: 'AI service rate limit exceeded. Please try again later.' 
        });
      } else if (error.response.status >= 500) {
        return res.status(503).json({ 
          error: 'AI service is currently unavailable' 
        });
      }
    } else if (error.code === 'ECONNABORTED') {
      return res.status(408).json({ 
        error: 'Request timeout. Please try again.' 
      });
    }

    res.status(500).json({ 
      error: 'Internal server error' 
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
