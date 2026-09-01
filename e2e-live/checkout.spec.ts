import { expect, test } from "@playwright/test";
test("places and renders a real non-hosted order in compiled Flutter web", async ({
  page,
}) => {
  await page.goto("/");
  const add = page.getByText("Add Best Sellers — sample listing to cart");
  await expect(add).toBeVisible({ timeout: 20000 });
  const added = page.waitForResponse(
    (r) =>
      r.url().endsWith("/v1/headless/carts/current/items") &&
      r.request().method() === "POST",
  );
  await add.click();
  const addResponse = await added;
  expect(addResponse.status(), await addResponse.text()).toBe(201);
  await expect(page.getByText("Cart 1")).toBeVisible();
  for (const [label, value] of [
    ["First name", "Headless"],
    ["Last name", "Fixture"],
    ["Email", "flutter-live@example.test"],
    ["Address", "1 Test Way"],
    ["City", "Vancouver"],
    ["State / province", "BC"],
    ["Postal code", "V6B1A1"],
  ] as const) {
    const field = page.getByLabel(label, { exact: true });
    await field.scrollIntoViewIfNeeded();
    await field.click();
    await field.press("ControlOrMeta+A");
    await field.pressSequentially(value, { delay: 20 });
    await expect(field).toHaveValue(value);
  }
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
  const placed = page.waitForResponse((r) => r.url().endsWith("/checkout/order") && r.request().method() === "POST");
  await page.getByText("Place pending order").click();
  const response = await placed;
  const body = await response.json();
  expect(response.status(), JSON.stringify(body)).toBe(201);
  expect(body.data.requiresPayment).toBe(false); expect(body.data.paymentStatus).toBe("pending");
  console.log(`Flutter live order: ${body.data.orderNumber}`);
  await expect(page.getByRole("group", { name: new RegExp(`Order confirmation Order ${body.data.orderNumber} placed`) })).toBeVisible();
  await page.reload();
  await page.getByLabel("Order number", { exact: true }).fill(body.data.orderNumber);
  await page.getByLabel("Order email", { exact: true }).fill("flutter-live@example.test");
  const lookedUp = page.waitForResponse(
    (r) => r.url().endsWith("/v1/headless/orders/lookup") && r.status() === 201,
  );
  await page.getByText("Check order status").click();
  await lookedUp;
  await expect(
    page.getByRole("group", {
      name: new RegExp(
        `Order lookup result Order ${body.data.orderNumber}.*Items: 1`,
      ),
    }),
  ).toBeVisible();
});
