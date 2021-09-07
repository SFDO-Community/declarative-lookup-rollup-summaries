*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot
Library         cumulusci.robotframework.PageObjects

Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser


*** Test Cases ***

Via API
    ${first_name} =       Get fake data  first_name
    ${last_name} =        Get fake data  last_name

    ${contact_id} =       Salesforce Insert  Contact
    ...                     FirstName=${first_name}
    ...                     LastName=${last_name}

    &{contact} =          Salesforce Get  Contact  ${contact_id}
    Validate Contact      ${contact_id}  ${first_name}  ${last_name}

Via UI
    ${first_name} =       Get fake data  first_name
    ${last_name} =        Get fake data  last_name

    Go to page            Home  Contact
    Click Object Button   New
    Wait for modal        New  Contact

    Populate Form
    ...                   First Name=${first_name}
    ...                   Last Name=${last_name}
    Click Modal Button    Save

    Wait Until Modal Is Closed

    ${contact_id} =       Get Current Record Id
    Store Session Record  Contact  ${contact_id}
    Validate Contact      ${contact_id}  ${first_name}  ${last_name}


*** Keywords ***

Validate Contact
    [Arguments]          ${contact_id}  ${first_name}  ${last_name}
    [Documentation]
    ...  Given a contact id, validate that the contact has the
    ...  expected first and last name both through the detail page in
    ...  the UI and via the API.

    # Validate via UI
    Go to page             Detail   Contact  ${contact_id}
    Page Should Contain    ${first_name} ${last_name}

    # Validate via API
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    Should Be Equal  ${first_name}  ${contact}[FirstName]
    Should Be Equal  ${last_name}  ${contact}[LastName]
