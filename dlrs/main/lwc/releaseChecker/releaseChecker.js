import { LightningElement } from "lwc";
import latestReleaseWarning from "@salesforce/label/c.LatestReleaseWarning";
import latestReleaseLink from "@salesforce/label/c.LatestReleaseLink";

const LATEST_RELEASE_URL =
  "https://api.github.com/repos/SFDO-Community/declarative-lookup-rollup-summaries/releases/latest";
//TODO abstract into a custom label or something else
const CURRENT_RELEASE = "2.14";

export default class ReleaseChecker extends LightningElement {
  latestRelease;
  labels = {
    latestReleaseWarning: latestReleaseWarning,
    latestReleaseLink: latestReleaseLink
  };

  get notOnLatestRelease() {
    return !!(this.latestRelease && this.latestRelease !== CURRENT_RELEASE);
  }

  connectedCallback() {
    fetch(LATEST_RELEASE_URL)
      .then((response) => {
        console.log(response);
        return response.json();
      })
      .then((response) => {
        console.log(response);
        this.latestRelease = response.name;
      })
      .catch((error) => {
        console.log(error);
      });
  }
}
