import { Temporal } from "@js-temporal/polyfill";

/**
 * Tab interface based on W3C recommendations re. tablist/tab/tabpanel roles.
 * see: https://www.w3.org/WAI/ARIA/apg/patterns/tabs/examples/tabs-manual/
 */
class TabInterface extends HTMLElement {
  #tabs = null;
  #tabPanels = null;

  constructor() {
    super();
  }

  connectedCallback() {
    this.attachShadow({ mode: "open" });
    this.shadowRoot.innerHTML = `
        <style>
            :host {
                [role="tablist"] {
                    display: grid;
                    grid-auto-flow: column;
                }

                [role="tab"] {
                    cursor: pointer;
                }

                ::slotted([role="tab"][aria-selected="false"]) {
                        opacity: 0.5;
                    }

                ::slotted([role="tab"][aria-selected="false"]:hover),
                ::slotted([role="tab"][aria-selected="false"]:focus),
                ::slotted([role="tab"][aria-selected="false"]:active),
                ::slotted([role="tab"][aria-selected="false"][aria-selected="true"]) {
                   opacity: 1;
                }

                ::slotted(button[role="tab"]) {
                    all: unset;
                }

                /* Ensure the focus ring remains in place as per accessibility guidelines. */
                ::slotted(button[role="tab"]:focus) {
                    outline: revert;
                }

                ::slotted([role="tabpanel"][aria-hidden="true"]) {
                    display: none;
                }
            }
        </style>
        <nav role="tablist">
            <slot id="tabSlot" name="tab"></slot>
        </nav>
        <div class="tab-panels">
            <slot id="tabpanelSlot" name="tabpanel"></slot>
        </div>
    `;

    // Technically the tabs and panels are children of the slots themselves,
    // so need to grab those first.
    const tabSlot = this.shadowRoot.querySelector("#tabSlot");
    const tabpanelSlot = this.shadowRoot.querySelector("#tabpanelSlot");
    // Can now grab the actual slot elements:
    this.#tabs = tabSlot.assignedElements();
    this.#tabPanels = tabpanelSlot.assignedElements();
    // The tab-related aria ARIA attributes are added here; they only make sense
    // if JS is enabled.
    this.#tabs.forEach((tab, index) => {
      tab.id = `tab-${index}`;
      tab.setAttribute("role", "tab");
      tab.setAttribute("aria-selected", index === 0 ? "true" : "false");
      tab.setAttribute("aria-controls", `tabpanel-${index}`);
      if (index !== 0) tab.setAttribute("tabindex", "-1");
      // Don't want to do this, but I'm having a severe issue getting useful
      // event objects from tab clicks:
      tab.addEventListener("click", this, true);
    });

    this.#tabPanels.forEach((tabPanel, index) => {
      tabPanel.id = `tabpanel-${index}`;
      tabPanel.setAttribute("role", "tabpanel");
      tabPanel.setAttribute("aria-labelledby", `tab-${index}`);
      tabPanel.setAttribute("aria-hidden", index === 0 ? "false" : "true");
      tabPanel.classList.toggle("is-hidden", index !== 0);
    });

    // Add event here, then use standard `handleEvent`
  }

  handleEvent(event) {
    this[`handle${event.type}`](event);
  }

  handleclick(event) {
    if (event.currentTarget.id.startsWith("tab-")) {
      const selectedTabIndex = this.#tabs.indexOf(event.currentTarget);

      const selectedTab = this.#tabs[selectedTabIndex];
      const selectedTabpanel = this.#tabPanels[selectedTabIndex];

      if (!selectedTab || !selectedTabpanel) {
        throw new Error("Trying to select a non-existant tab");
      }

      this.#tabs.forEach((tab, index) => {
        tab.setAttribute(
          "aria-selected",
          index === selectedTabIndex ? "true" : "false",
        );
        if (index !== selectedTabIndex) {
          tab.setAttribute("tabindex", "-1");
        } else {
          tab.removeAttribute("tabindex");
        }
      });

      this.#tabPanels.forEach((tabPanel, index) => {
        tabPanel.setAttribute(
          "aria-hidden",
          index === selectedTabIndex ? "false" : "true",
        );
        tabPanel.classList.toggle("is-hidden", index !== selectedTabIndex);
      });
    }
  }
}

customElements.define("tab-interface", TabInterface);

/**
 * @param {string} elementDt - a valid ISO 8106 date string
 * @returns {string}
 *
 * NOTE: just using en-GB rather than relying on browser to infer as it should be
 * in actual app (I want the format to reflect local idioms & language).
 */
function relativeDayFormat(elementDt) {
  const plainDateNow = Temporal.Now.plainDateISO();
  const plainDateOfEl = Temporal.Instant.from(elementDt).toZonedDateTimeISO(
    "UTC",
  )
    .toPlainDate();

  const numberOfDays = plainDateNow.until(plainDateOfEl).days;

  if (numberOfDays < 2) {
    return new Intl.RelativeTimeFormat("en-GB", { numeric: "auto" }).format(
      numberOfDays,
      "day",
    );
  } else {
    // NOTE: the Temporal polyfill does include patch Intl to allow using
    // Temporal objects directly. However, what it doesn't seem to support
    // is RelativeTimeFormat, so need to use `Date` object in this case.
    return new Intl.DateTimeFormat("en-GB", { weekday: "long" }).format(
      new Date(elementDt),
    );
  }
}

/**
 * Given a `time` element with a valid `datetime` attribute, converts it to
 * local relative time string for today/tomorrow, and prints local name of day
 * for subsequent days.
 */
class RelativeDay extends HTMLTimeElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const elementDt = this.getAttribute("datetime");
    this.textContent = relativeDayFormat(elementDt);
  }
}

customElements.define("relative-day", RelativeDay, { extends: "time" });

