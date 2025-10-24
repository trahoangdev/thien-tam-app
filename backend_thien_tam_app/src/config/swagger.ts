import swaggerJsdoc from 'swagger-jsdoc';
import { Express } from 'express';
import swaggerUi from 'swagger-ui-express';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Thien Tam App API',
      version: '1.0.0',
      description: 'API documentation for Thien Tam Buddhist Reading App',
      contact: {
        name: 'Thien Tam App Team',
        email: 'support@thientam.app',
      },
    },
    servers: [
      {
        url: process.env.API_BASE_URL || 'http://localhost:4000',
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Reading: {
          type: 'object',
          properties: {
            _id: {
              type: 'string',
              description: 'Unique identifier for the reading',
            },
            title: {
              type: 'string',
              description: 'Title of the reading',
            },
            body: {
              type: 'string',
              description: 'Content of the reading',
            },
            date: {
              type: 'string',
              format: 'date',
              description: 'Date of the reading (YYYY-MM-DD)',
            },
            topicSlugs: {
              type: 'array',
              items: {
                type: 'string',
              },
              description: 'Array of topic slugs',
            },
            keywords: {
              type: 'array',
              items: {
                type: 'string',
              },
              description: 'Array of keywords',
            },
            source: {
              type: 'string',
              description: 'Source of the reading',
            },
            lang: {
              type: 'string',
              description: 'Language code',
              example: 'vi',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Creation timestamp',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'Last update timestamp',
            },
          },
        },
        Topic: {
          type: 'object',
          properties: {
            _id: {
              type: 'string',
              description: 'Unique identifier for the topic',
            },
            name: {
              type: 'string',
              description: 'Name of the topic',
            },
            slug: {
              type: 'string',
              description: 'URL-friendly slug for the topic',
            },
            description: {
              type: 'string',
              description: 'Description of the topic',
            },
            isActive: {
              type: 'boolean',
              description: 'Whether the topic is active',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Creation timestamp',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'Last update timestamp',
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            _id: {
              type: 'string',
              description: 'Unique identifier for the user',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
            },
            name: {
              type: 'string',
              description: 'User full name',
            },
            role: {
              type: 'string',
              enum: ['user', 'admin'],
              description: 'User role',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Creation timestamp',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'Last update timestamp',
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Error message',
            },
            error: {
              type: 'string',
              description: 'Detailed error information (development only)',
            },
          },
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/*.ts'], // Path to the API docs
};

const specs = swaggerJsdoc(options);

export const setupSwagger = (app: Express) => {
  // Swagger UI
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, {
    explorer: true,
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'Thien Tam App API Documentation',
  }));

  // JSON endpoint
  app.get('/api-docs.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(specs);
  });
};
