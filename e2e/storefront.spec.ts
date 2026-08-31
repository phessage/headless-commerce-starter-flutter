import { expect, test } from '@playwright/test';

test('compiled Flutter web app renders and updates cart', async ({ page }) => {
  await page.goto('/');
  await page
    .getByRole('button', { name: 'Enable accessibility' })
    .dispatchEvent('click');

  await expect(page.getByText('Traverse Pack')).toBeVisible({ timeout: 20_000 });
  await page.getByText('Add Traverse Pack to cart').click();
  await expect(page.getByText('Cart 1')).toBeVisible();
  await expect(page.getByText('Add Winter Quilt to cart')).toBeVisible();
});
