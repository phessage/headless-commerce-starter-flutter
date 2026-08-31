import { defineConfig, devices } from "@playwright/test";
if (!process.env.HEADLESS_API_URL || !process.env.HEADLESS_PUBLISHABLE_KEY)
  throw new Error(
    "Live E2E requires HEADLESS_API_URL and HEADLESS_PUBLISHABLE_KEY",
  );
export default defineConfig({
  testDir: "e2e-live",
  use: { baseURL: "http://127.0.0.1:4181" },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1600, height: 1200 },
      },
    },
  ],
  webServer: {
    command: "npx http-server build/web -p 4181 -c-1",
    url: "http://127.0.0.1:4181",
    reuseExistingServer: false,
  },
});
