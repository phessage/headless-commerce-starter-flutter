import { expect, test } from '@playwright/test';

test('compiled Flutter web bootstraps one store ID and updates cart', async ({ page }) => {
  await page.route('https://api.1ecomm.com/v1/headless/stores/**', (route) => route.fulfill({ json: { data: { storeId: '01f5b02f-d7c0-42cd-b880-59f78ea70aa3', apiUrl: 'https://sandbox.test', publishableKey: 'pk_test_demo', apiVersion: 'v1', capabilities: ['catalog', 'cart', 'checkout-preparation'] } } }));
  await page.route('https://sandbox.test/v1/headless/products', (route) => route.fulfill({ json: { data: [{ id: 'p1', name: 'Traverse Pack', description: 'Pack', available: true, price: { amount: '20', currency: 'USD' } }], nextCursor: null, requestId: 'r' } }));
  await page.route('https://sandbox.test/v1/headless/carts', (route) => route.fulfill({ status: 201, json: { data: { items: [] }, cartToken: `hc_${'a'.repeat(43)}`, created: true, requestId: 'r' } }));
  await page.route('https://sandbox.test/v1/headless/carts/current/items', (route) => route.fulfill({ status: 201, json: { data: { items: [{ id: 'line', quantity: 1 }] }, requestId: 'r' } }));
  const bootstrapResponse = page.waitForResponse((response) => response.url().includes('/v1/headless/stores/') && response.status() === 200);
  const catalogResponse = page.waitForResponse((response) => response.url() === 'https://sandbox.test/v1/headless/products' && response.status() === 200);
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await Promise.all([bootstrapResponse, catalogResponse]);
  const accessibility = page.getByRole('button', { name: 'Enable accessibility' });
  await expect(accessibility).toBeVisible();
  // Flutter intentionally positions this control outside the viewport and may
  // attach its listener after the element exists. Retry the real activation
  // event until the compiled semantics tree exposes the fetched product.
  await expect.poll(async () => {
    await accessibility.dispatchEvent('click');
    return page.getByText('Traverse Pack').count();
  }, { timeout: 20_000 }).toBeGreaterThan(0);
  await expect(page.getByText('Traverse Pack')).toBeVisible({ timeout: 20_000 });
  await page.getByText('Add Traverse Pack to cart').click();
  await expect(page.getByText('Cart 1')).toBeVisible();
});
