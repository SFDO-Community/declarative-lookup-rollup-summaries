---
layout: default
title: Developer Setup
nav_order: 2
parent: About Us & Contribution
has_children: false
---

# Installing the Source Code (Developers)

If you want to deploy the unmanaged version of this to your sandbox or production org, clone this repo and use the Salesforce DX toolchain for deployment. However the recommended deployment for these orgs is via the managed package links above.

# Contributing to Declarative Rollup Summary Tools

This project now uses [Salesforce DX](https://trailhead.salesforce.com/content/learn/modules/sfdx_app_dev) and [CumulusCI (CCI)](https://trailhead.salesforce.com/en/content/learn/trails/build-applications-with-cumulusci) for development and packaging. You can use either tool chain to contribute.

It's easy:

0. Have VS Code with [Salesforce DX Extended](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-expanded) setup and running

1. Clone this repo  
   A. If using windows: LF normalize "MetadataService.cls","MetadataServiceTest.cls"  
   &nbsp;Ex: In VS code you can change the file from `CRLF` to `LF` within the program settings.
2. run `npm ci` - this will ensure our code formatting rules apply (via Prettier), and installs packages from the package-lock.json file
3. create a _new branch_ from `main`, all branches must start with `feature/`, e.g. `feature/newSetupUX`(use a descriptive name)
4. Deploy code to a Scratch Org via CCI or DX  
    A. If using SFDX: append the scratch org creation command with "--nonamespace"  
   &nbsp;Ex: `sfdx force:org:create -f orgs/feature.json --nonamespace -a myTestOrgAlias`
5. Work on it

When done:

- Open up a PR and fill out the template. Once done, one of two things will happen
  1. If you are a DLRS team member, successful builds and reviews are required for merge
  2. If you are not a member (yet) then a team member will pick up your PR, close it and open a new PR with your changes. That way your contribution will be preserved. From there it is back to 1)
