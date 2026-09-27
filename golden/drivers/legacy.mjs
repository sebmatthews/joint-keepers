// Driver for the legacy Web Forms app: turns each plain-language step into clicks and typing.
// The modern app gets its own driver, doing the same steps against its own screens.

export function legacyDriver(page, baseUrl) {
  const url = (path) => new URL(path, baseUrl).toString();
  const submit = (selector) => Promise.all([page.waitForNavigation({ waitUntil: 'load' }), page.click(selector)]);

  return {
    async openHoldings() {
      await page.goto(url('Default.aspx'), { waitUntil: 'load' });
    },
    async searchHoldings({ term }) {
      await page.fill('#txtSearch', term);
      await submit('#btnSearch');
    },
    async openHolding({ holding }) {
      await page.goto(url('Default.aspx'), { waitUntil: 'load' });
      const row = page.locator('table.grid tr', { hasText: holding });
      await Promise.all([page.waitForNavigation({ waitUntil: 'load' }), row.locator('a').first().click()]);
    },
    async openAnimal({ tag }) {
      await Promise.all([page.waitForNavigation({ waitUntil: 'load' }), page.click(`a:text-is("${tag}")`)]);
    },
    async registerAnimal({ tag, species, dob, keeper, additionalKeepers = [] }) {
      await page.fill('#txtTag', tag);
      await page.selectOption('#ddlSpecies', { label: species });
      await page.fill('#txtDob', dob);
      await page.selectOption('#ddlKeeper', { label: keeper });
      // Additional keepers exist only once the joint keepers change is made (IDs fixed in docs/joint-keepers-law.md).
      for (const [i, extra] of additionalKeepers.entries()) {
        await page.selectOption(`#ddlKeeper${i + 2}`, { label: extra });
      }
      await submit('#btnRegister');
    },
    async addKeeper({ keeper }) {
      if (keeper) await page.selectOption('#ddlAddKeeper', { label: keeper });
      await submit('#btnAddKeeper');
    },
    async recordMovement({ tag, from, to, date }) {
      await page.goto(url('Movement.aspx'), { waitUntil: 'load' });
      await page.fill('#txtTag', tag);
      await page.selectOption('#ddlFrom', { label: from });
      await page.selectOption('#ddlTo', { label: to });
      await page.fill('#txtDate', date);
      await submit('#btnRecord');
    },

    // What the screen shows, in a form both apps can produce: any message, and the rows of every table.
    async readScreen() {
      return page.evaluate(() => {
        const text = (el) => el.textContent.replace(/\s+/g, ' ').trim();
        const messages = [...document.querySelectorAll('.message')].map(text).filter(Boolean);
        const tables = [...document.querySelectorAll('table.grid')].map((t) =>
          [...t.querySelectorAll('tr')].map((tr) => [...tr.querySelectorAll('th, td')].map(text)));
        return { messages, tables };
      });
    },
  };
}
