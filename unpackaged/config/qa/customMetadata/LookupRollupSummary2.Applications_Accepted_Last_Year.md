<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Applications Accepted Last Year</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>AggregateAllRows__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>AggregateOperation__c</field>
        <value xsi:type="xsd:string">Count</value>
    </values>
    <values>
        <field>AggregateResultField__c</field>
        <value xsi:type="xsd:string">No_of_Applications_Accepted_Last_Year__c</value>
    </values>
    <values>
        <field>CalculationMode__c</field>
        <value xsi:type="xsd:string">Realtime</value>
    </values>
    <values>
        <field>CalculationSharingMode__c</field>
        <value xsi:type="xsd:string">System</value>
    </values>
    <values>
        <field>ChildObject__c</field>
        <value xsi:type="xsd:string">Application__c</value>
    </values>
    <values>
        <field>ConcatenateDelimiter__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>FieldToAggregate__c</field>
        <value xsi:type="xsd:string">Id</value>
    </values>
    <values>
        <field>FieldToOrderBy__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ParentObject__c</field>
        <value xsi:type="xsd:string">Account</value>
    </values>
    <values>
        <field>RelationshipCriteriaFields__c</field>
        <value xsi:type="xsd:string">Start_Date__c
Application_Status__c</value>
    </values>
    <values>
        <field>RelationshipCriteria__c</field>
        <value xsi:type="xsd:string">(Start_Date__c= Last_Year AND Application_Status__c =&apos;Accepted&apos;)</value>
    </values>
    <values>
        <field>RelationshipField__c</field>
        <value xsi:type="xsd:string">Applying_School__c</value>
    </values>
    <values>
        <field>RowLimit__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>TestCode2__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>TestCodeParent__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>TestCodeSeeAllData__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>TestCode__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
