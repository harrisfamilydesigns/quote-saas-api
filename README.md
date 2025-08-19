# Quote SaaS API

A Ruby on Rails API backend for the Quote SaaS application. This API provides the server-side functionality for managing quotes, clients, products, and users.

## Port Information

- **API (Rails)**: Runs on port **7777** in development mode
- **Frontend (Vite)**: Runs on port **7778**

## Technology Stack

- **Ruby Version**: 3.4.2
- **Rails Version**: 8.0.1
- **Database**: PostgreSQL
- **Testing Framework**: RSpec

## Prerequisites

- Ruby 3.4.2
- PostgreSQL
- Bundler

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/harrisfamilydesigns/quote-saas-api.git
   cd quote-saas-api
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Database setup:
   ```bash
   # Create databases
   rails db:create
   
   # Run migrations
   rails db:migrate
   
   # Seed the database (if applicable)
   rails db:seed
   ```

## Usage

### Starting the Server

You can start the server using the provided script:

```bash
./start.sh
```

This will:
- Create necessary directories
- Start the Rails server in the background on port 7777
- Output logs to `log/server.log`

### Stopping the Server

To stop the server:

```bash
./stop.sh
```

This script will:
- Gracefully shut down the Rails server
- Remove PID files
- Provide a summary of stopped services

### Manual Server Control

Alternatively, you can start the server manually:

```bash
# Start the server in the foreground
rails server -p 7777

# Start the server in development mode
RAILS_ENV=development rails server -p 7777
```

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and test

3. Commit your changes:
   ```bash
   git commit -m "Add your meaningful commit message"
   ```

4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```

5. Create a pull request

## API Documentation

API endpoints documentation will be available at `/api/docs` when the server is running (if applicable).

## Deployment

Deployment instructions will be added as they become available.

## License

This project is proprietary and confidential.

## Contributing

Please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct and the process for submitting pull requests.