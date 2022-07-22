import os

for x in range(1, 393):
    obj_name = 'Test{counter}__c'.format(counter=x)

    folder_path = '../unpackaged/config/mock/objects/{name}'.format(name=obj_name)
    print(folder_path)

    file_name = '{folder}/{name}.object-meta.xml'.format(folder=folder_path, name=obj_name);
    print(file_name)

    os.makedirs(folder_path, exist_ok=True)

    file_contents = """
    <?xml version="1.0" encoding="UTF-8" ?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <actionOverrides>
        <actionName>Accept</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>CancelEdit</actionName>1
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>Clone</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>Delete</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>Edit</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>Follow</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>List</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>New</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>SaveEdit</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>Tab</actionName>
        <type>Default</type>
    </actionOverrides>
    <actionOverrides>
        <actionName>View</actionName>
        <type>Default</type>
    </actionOverrides>
    <allowInChatterGroups>false</allowInChatterGroups>
    <compactLayoutAssignment>SYSTEM</compactLayoutAssignment>
    <deploymentStatus>Deployed</deploymentStatus>
    <deprecated>false</deprecated>
    <enableActivities>false</enableActivities>
    <enableBulkApi>true</enableBulkApi>
    <enableFeeds>false</enableFeeds>
    <enableHistory>false</enableHistory>
    <enableReports>false</enableReports>
    <enableSearch>true</enableSearch>
    <enableSharing>true</enableSharing>
    <enableStreamingApi>true</enableStreamingApi>
    <label>Test Object {counter}</label>
    <nameField>
        <label>Test Object {counter} Name</label>
        <type>Text</type>
    </nameField>
    <pluralLabel>Test Objects {counter}</pluralLabel>
    <searchLayouts />
    <sharingModel>Read</sharingModel>
</CustomObject>
    """.format(counter=x)

    fp = open(file_name, 'w')
    fp.write(file_contents)
    fp.close()
