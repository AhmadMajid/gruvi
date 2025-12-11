# Movie Search App

A Rails 8 application for searching movies by release date range using The Movie Database (TMDb) API. Implements database caching to reduce redundant API calls.

## Features

- Search movies by date range (start date and end date)
- Multiple sort options: popularity, rating, votes, newest, oldest, alphabetical
- Pagination support
- 24-hour database cache for API requests
- Fragment caching for rendered movie cards
- Modal popups for full movie descriptions
- Tests (models, controllers, integration)

## Tech Stack

- **Ruby**: 3.4.7
- **Rails**: 8.1.1
- **Database**: SQLite
- **Frontend**: Server-side rendered HTML with vanilla JavaScript
- **API**: TMDb (The Movie Database) via `themoviedb-api` gem
- **Testing**: Minitest with Mocha for mocking
- **Assets**: Propshaft (Rails 8 default)
- **JavaScript**: Import maps (no Node.js required)

## Setup Instructions

### Prerequisites

- Ruby 3.x or higher (developed with 3.4.7)
- Rails 8.x (developed with 8.1.1)
- SQLite3
- TMDb API key ([https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api))

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd gruvi
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up environment variables:**
   
   Create a `.env` file in the root directory:
   ```bash
   TMDB_API_KEY=your_tmdb_api_key_here
   ```

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

5. **Start the Rails server:**
   ```bash
   bin/rails server
   ```

6. **Open your browser:**
   
   Navigate to `http://localhost:3000`

### Running Tests

Run the full test suite:
```bash
bin/rails test
```

Run specific test files:
```bash
bin/rails test test/models/movie_test.rb
bin/rails test test/controllers/movies_controller_test.rb
bin/rails test test/integration/movie_search_integration_test.rb
```

## Design Choices & Trade-offs

### 1. Caching Architecture

**Choice:** Three-model architecture for caching with fragment caching for rendered views
- `ApiRequest`: Stores unique API query URLs with timestamps
- `Movie`: Stores movie data with unique `tmdb_id` constraint
- `SearchResult`: Join table linking API requests to movies with position tracking
- Fragment caching: Caches rendered HTML for movie cards and modals

**Why:** 
- Avoids redundant API calls by caching both the request metadata and the actual movie data
- 24-hour cache expiry balances freshness with API rate limits
- Join table preserves search result order and allows tracking which searches returned which movies
- Fragment caching eliminates ERB processing overhead for previously rendered movies

**Trade-offs:**
- More complex than simple cache-aside pattern
- Database storage is slower than memory cache (Redis), but persists across restarts
- Fragment cache automatically invalidates when movie records update (using Rails cache keys)

### 2. Server-Side Rendering with Vanilla JavaScript

**Choice:** Rails views with minimal JavaScript (modals, date formatting)

**Why:**
- No build toolchain required
- Server-side rendering with progressive enhancement

**Trade-offs:**
- Less interactive than React/Vue SPA
- Full page reloads for searches (though Turbo could improve this)
- Limited to what browser JavaScript can do natively

### 3. Sorting & Pagination Implementation

**Choice:** Map user-friendly sort options to TMDb API parameters, cap at 500 pages

**Why:**
- Six sort options implemented: popularity, rating, votes, date (newest/oldest), alphabetical
- Rating sort includes minimum vote count filter (20+)
- Pagination integrated with URL caching

**Trade-offs:**
- Each sort/page combination creates a new cache entry
- Could be more efficient with normalized caching strategy
- 500-page cap is arbitrary but prevents excessive API calls

### 4. Error Handling Strategy

**Choice:** Controller-level rescue blocks with user-friendly messages

**Why:**
- Handles network failures, invalid dates, and API errors
- Displays errors inline
- Logs detailed error information

**Trade-offs:**
- Could implement retry logic for transient failures
- More granular error types would enable better user feedback

## What I'd Improve with More Time

### Performance & Scalability
1. **Redis Caching**: Replace database cache with Redis for faster lookups and better TTL management
2. **Background Jobs**: Move API requests to Solid Queue background jobs to avoid blocking requests

### Features
1. **Advanced Filtering**: Genre, language, rating range, runtime filters
2. **Movie Details Page**: Full movie information with cast, crew, trailers, reviews
3. **User Accounts**: Save searches, create watchlists, favorite movies
4. **Search History**
5. **Autocomplete**: Date pickers with calendar UI
6. **Export Options**: CSV export of search results

### UX Improvements
1. **Loading States**: Skeleton screens and progress indicators during API calls
2. **Infinite Scroll**: Alternative to pagination for better mobile experience
3. **Image Optimization**: Lazy loading
4. **Keyboard Navigation**: Full keyboard support for accessibility
5. **Dark Mode**: Toggle between light and dark themes

### Testing & Quality
1. **Performance Testing**: Benchmark caching effectiveness and query performance
2. **API Contract Tests**: Verify TMDb API response structure hasn't changed
3. **Accessibility Testing**: Ensure WCAG compliance with automated tools
4. **Coverage Analysis**: SimpleCov integration for test coverage reporting

### Production Readiness
1. **Database**: Switch to PostgreSQL for production deployment
2. **Monitoring**: Integrate Sentry for error tracking, New Relic for performance
3. **Rate Limiting**: Rack::Attack to prevent abuse of search endpoint
4. **Security**: Content Security Policy, rate limiting (But the cache indirectly helps with rate limiting)
5. **CI/CD**: GitHub Actions for automated testing and deployment

### Code Quality
1. **Internationalization**: Support multiple languages with I18n
## Use of AI Tools

### AI-Assisted Tasks:
- CSS styling with modern, responsive design
- Debugging test failures