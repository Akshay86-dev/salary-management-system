import axios from 'axios';

interface ErrorResponse {
  error?: unknown;
  errors?: unknown;
}

const firstMessage = (value: unknown): string | undefined => {
  if (typeof value === 'string') {
    return value;
  }

  if (Array.isArray(value)) {
    return value.map(firstMessage).find((message) => message !== undefined);
  }

  if (value && typeof value === 'object') {
    return Object.values(value).map(firstMessage).find((message) => message !== undefined);
  }
};

export const errorMessage = (error: unknown, fallback: string): string => {
  if (axios.isAxiosError<ErrorResponse>(error)) {
    const responseMessage = firstMessage(error.response?.data?.errors)
      || firstMessage(error.response?.data?.error);
    if (responseMessage) {
      return responseMessage;
    }

    if (error.message) {
      return error.message;
    }
  }

  return error instanceof Error && error.message ? error.message : fallback;
};
