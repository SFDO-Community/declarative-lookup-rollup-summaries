import { LightningElement, api, track } from "lwc";
import SR_URL from "@salesforce/resourceUrl/wheresiwyg";

const DEFAULT_CONFIG = {
  filterLogic: "1",
  filters: [
    {
      num: 1,
      subjects: [""],
      operator: "=",
      values: [""]
    }
  ]
};

export default class WhereSIWYG extends LightningElement {
  @api
  setQuery(val) {
    this.filterConfig = DEFAULT_CONFIG;
    this.sendQueryString(val);
    this.query = val;
  }

  @api
  mode;

  @api
  baseObject;

  @track
  filterConfig = DEFAULT_CONFIG;

  parsedQuery;
  query;
  testVal;

  queryOnChange(event) {
    this.sendQueryString(event.currentTarget.value);
    this.publishNewQuery(event.currentTarget.value);
  }

  connectedCallback() {
    window.addEventListener("message", this.onQueryParserMessage.bind(this));
  }
  disconnectedCallback() {
    window.removeEventListener("message", this.messageListener);
  }

  valueChangeHandler;

  get soqlBuilderSrcUrl() {
    return `${SR_URL}/parser/index.html`;
  }

  sendQueryString(query) {
    if (this.template.querySelector("iframe")) {
      this.template.querySelector("iframe").contentWindow.postMessage(
        {
          query
        },
        "*"
      );
    }
  }

  sendFilterCriteria(filterConfig) {
    if (this.template.querySelector("iframe")) {
      this.template.querySelector("iframe").contentWindow.postMessage(
        {
          filterConfig
        },
        "*"
      );
    }
  }

  addFilter() {
    const num = this.filterConfig.filters.length + 1;
    this.filterConfig.filters.push({
      num,
      operator: "=",
      subjects: [""],
      values: [""]
    });
    // TODO: this might need to be smarter
    this.filterConfig.filterLogic += ` AND ${num}`;
  }

  handleUpdateItem(event) {
    console.log({ ...event.detail });
    this.filterConfig.filters[event.detail.index] = event.detail.config;
    this.sendFilterCriteria(this.filterConfig);
  }

  updateFilterLogic(event) {
    this.filterConfig.filterLogic = event.target.value;
    this.sendFilterCriteria(this.filterConfig);
  }

  onQueryParserMessage(event) {
    console.log(event);
    // TODO: capture referenced fields so we can bubble them to the parent component
    if (event.data.filterConfig) {
      this.filterConfig = event.data.filterConfig;
    } else {
      this.query = event.data.query;
      this.publishNewQuery(this.query);
    }
  }

  publishNewQuery(query) {
    this.dispatchEvent(
      new CustomEvent("querychanged", {
        detail: { query, referencedFields: [["Name"]] }
      })
    );
  }
}
