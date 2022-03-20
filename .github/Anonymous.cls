 // Test data
 LookupRollupSummary2__mdt rollupSummaryA = new LookupRollupSummary2__mdt();
 rollupSummaryA.MasterLabel = 'test';
 rollupSummaryA.DeveloperName = 'test';
 rollupSummaryA.ParentObject__c = 'Account';
 rollupSummaryA.ChildObject__c = 'Opportunity';
 rollupSummaryA.RelationShipField__c = 'AccountId';
 rollupSummaryA.RelationShipCriteria__c = null;
 rollupSummaryA.FieldToAggregate__c = 'Amount';
 rollupSummaryA.AggregateOperation__c = 'Sum';
 rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
 rollupSummaryA.Active__c = false;
 rollupSummaryA.CalculationMode__c = 'Realtime';

 insert rollupSummaryA;