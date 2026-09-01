import { expect, test } from "@playwright/test";
test("prepares a real fixture cart in compiled Flutter web", async ({
  page,
}) => {
  await page.goto("/");
  const add = page.getByText("Add Best Sellers — sample listing to cart");
  await expect(add).toBeVisible({ timeout: 20000 });
  const added = page.waitForResponse(
    (r) =>
      r.url().endsWith("/v1/headless/carts/current/items") &&
      r.status() === 201,
  );
  await add.click();
  await added;
  await expect(page.getByText("Cart 1")).toBeVisible();
  for (const [label, value] of [
    ["First name", "Headless"],
    ["Last name", "Fixture"],
    ["Email", "flutter-live@example.test"],
    ["Address", "1 Test Way"],
    ["City", "Vancouver"],
    ["State / province", "BC"],
    ["Postal code", "V6B1A1"],
  ] as const)
    await page.getByLabel(label).fill(value);
  const prepared = page.waitForResponse(
    (r) =>
      r.url().endsWith("/v1/headless/carts/current/checkout") &&
      r.request().method() === "PATCH" &&
      r.status() === 200,
  );
  await page.getByText("Load checkout choices").click();
  await prepared;
  await page.getByRole("button", { name: "Shipping method" }).click();
  const shippingSelected = page.waitForResponse(
    (r) => r.url().endsWith("/checkout/shipping-method") && r.status() === 200,
  );
  await page.getByRole("menuitem").first().click();
  await shippingSelected;
  await page.getByRole("button", { name: "Payment method" }).click();
  const paymentSelected = page.waitForResponse(
    (r) => r.url().endsWith("/checkout/payment-method") && r.status() === 200,
  );
  await page.getByRole("menuitem").first().click();
  await paymentSelected;
  await expect(page.getByRole("group", { name: /No preparation gaps/ })).toBeVisible();
  const placed = page.waitForResponse((r) => r.url().endsWith("/checkout/order") && r.request().method() === "POST" && r.status() === 201);
  await page.getByText("Place pending order").click();
  const body = await (await placed).json(); expect(body.data.requiresPayment).toBe(false); expect(body.data.paymentStatus).toBe("pending");
  await expect(page.getByRole("group", { name: new RegExp(`Order confirmation Order ${body.data.orderNumber} placed`) })).toBeVisible();
});
