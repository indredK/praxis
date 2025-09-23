// vitest.setup.ts (Corrected Version)

// This directive tells TypeScript to load the jest-dom types.
// It solves type errors (TS2339) in your editor. 🧠
/// <reference types="@testing-library/jest-dom" />

// This import extends Vitest's `expect` with jest-dom matchers at runtime.
// It is the correct, safe way to do this and solves the startup crash.
import '@testing-library/jest-dom/vitest';