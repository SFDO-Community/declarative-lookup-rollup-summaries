import { defineConfig, globalIgnores } from "eslint/config";
import eslintPluginLwc from "@lwc/eslint-plugin-lwc";
import salesforceLwcConfig from "@salesforce/eslint-config-lwc";

export default defineConfig([
  globalIgnores([
    "node_modules",
    ".sfdx",
    "**/staticresources/**/*.js",
    "dlrs/main/lwc/classSchedulerModal/cronstrue.js"
  ]),
  // LWC configuration for force-app/main/default/lwc
  {
    files: ["dlrs/main/lwc/**/*.js"],
    extends: [salesforceLwcConfig.configs.recommended]
  },

  // LWC configuration with override for LWC test files
  {
    files: ["dlrs/main/lwc/**/*.test.js"],
    extends: [salesforceLwcConfig.configs.recommended],
    rules: {
      "@lwc/lwc/no-unexpected-wire-adapter-usages": "off"
    }
  }
]);
