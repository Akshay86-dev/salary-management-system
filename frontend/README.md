# Salary Management System Frontend

React frontend for the Salary Management System, built with Vite, TypeScript, and integrated with the Rails backend.

## Features

- **React 18** with TypeScript support
- **Vite** as build tool and dev server
- **JWT Authentication** with Axios interceptors
- **Dark/Light Theme** with persistent user preference
- **React Router v6** for client-side routing
- **Context API** for state management (Auth & Theme)

## Architecture

### Project Structure
```
frontend/
├── src/
│   ├── components/
│   │   └── layout/          # Reusable layout components
│   ├── contexts/              # React context providers
│   │   ├── AuthContext.tsx    # JWT authentication state
│   │   └── ThemeContext.tsx   # Dark/light theme state
│   ├── pages/                 # Page components (route handlers)
│   │   ├── Login.tsx
│   │   ├── Dashboard.tsx
│   │   ├── Departments.tsx
│   │   └── Employees.tsx
│   ├── services/              # API client and services
│   │   └── api.ts             # Axios instance with JWT interceptors
│   └── styles/
│       ├── index.css          # Base styles and utilities
│       └── theme.css          # Theme variables (dark/light)
├── App.tsx                    # Root component with routes
└── main.tsx                   # Application entry point
```

### Authentication Flow

1. User logs in via `/login` route with email/password
2. Credentials are sent to Rails API (`POST /users/sign_in`)
3. Devise-JWT returns a JWT token in the Authorization header
4. Token is stored in localStorage
5. Subsequent API requests include `Authorization: Bearer <JWT>` header
6. Token expires after 24 hours (configured in Devise initializer)

### JWT Storage

JWT tokens are stored in `localStorage`. This provides:
- Persistence across page reloads
- Easy access from JavaScript
- Automatic cleanup on logout or token expiration

Note: For production, consider using httpOnly cookies for enhanced security.

## Development

### Running the Dev Server

From the frontend directory:
```bash
cd frontend
npm install       # or yarn install
npm run dev       # Starts Vite dev server on http://localhost:5173
```

### Building for Production

```bash
npm run build
```

The build output goes to `public/vite/` in the Rails root, which is served by Rails.

### Environment Variables

| Variable | Description |
|----------|-------------|
| `VITE_API_URL` | API base URL (optional, defaults to relative `/api/v1`) |

## Theme System

The application supports both light and dark modes:

- **System preference**: Automatically detects user's OS theme preference
- **Manual toggle**: User can switch between light/dark mode via navbar button
- **Persistence**: Theme preference is saved to localStorage

Theme variables are CSS custom properties defined in `src/styles/theme.css`.

## API Client

The Axios client (`src/services/api.ts`) includes:

- **Request interceptor**: Automatically adds JWT Authorization header
- **Response interceptor**: Handles 401 (redirects to login) and 403 errors
- **API methods**: Organized wrappers for auth, departments, and employees endpoints

## Integration with Rails Backend

The frontend is designed to work in two modes:

### Development
- Frontend: `http://localhost:5173` (Vite dev server)
- Backend: `http://localhost:3000` (Rails server)
- API requests proxied via Vite configuration

### Production
- Single origin: Rails serves both frontend assets and API
- Frontend built assets placed in `public/vite/`
- Rails routes catch all non-API routes and render the React app

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start Vite development server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint |
| `npm run type-check` | Run TypeScript type checking