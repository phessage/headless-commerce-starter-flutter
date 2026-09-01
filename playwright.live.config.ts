import { defineConfig, devices } from "@playwright/test";
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
