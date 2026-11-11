import { LightningElement, api } from "lwc";

import hljs from "./lib/highlight-core.min.js";
import hljsApex from "./lib/apex.min.js";

export default class FormattedApex extends LightningElement {
  @api
  apexCode;

  highlightedCode;

  connectedCallback() {
    hljs.registerLanguage("apex", hljsApex);

    this.highlightedCode = hljs.highlight(this.apexCode, {
      language: "apex"
    }).value;
  }
  renderedCallback() {
    if (this.refs?.codeBlock) {
      // eslint-disable-next-line @lwc/lwc/no-inner-html
      this.refs.codeBlock.innerHTML = this.highlightedCode;
    }
  }
}
