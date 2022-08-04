---
layout: default
title: Installation
nav_order: 2
has_children: true
---

Needs Content
{: .label .label-red }

# Installation

Install the latest version of DLRS into your production, sandbox, or scratch org via :
<br/><br/>
[Salesforce.org MetaDeploy](https://install.salesforce.org/products/dlrs/latest){: .btn .btn-blue }
<br/>

Here is the App and Objects that are installed. You can see there are two permission sets that can be used to give access.
![Installed Components](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/InstalledComponents.PNG)

## Permissions

You can install the package for Admins only and open up permissions for all users/profiles with the options below or install for all users.

![Install for Admins](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/Install-Admins-Only.PNG)

There are two types of DLRS Users:

### Admin

Kind of a tool admin user that both configures and activates the rollups (this has to be an admin to deploy and manage the trigger for example). This user also needs full read/write access to all the objects in the package.

### User

Then there is the users that don't directly use the tool, but indirectly invoke its rollups. These users need read access to all the objects in the package. You don't however need to give them access to the app, tabs or Visualforce pages for example since they don't need to be able to access the tools admin UI.
