@IsTest
public class RollupDmlGuardTest {
  @IsTest
  static void testRollupDmlGuardChangeNeeded() {
    RollupDmlGuard g = new RollupDmlGuard();
    Account a = new Account(Name = 'Test', NumberOfEmployees = 0);
    insert a;
    a = new Account(Id = a.Id, NumberOfEmployees = 0);

    List<LREngine.Context> ctxList = new List<LREngine.Context>();
    LREngine.Context ctx = new LREngine.Context(
      Account.SObjectType,
      Contact.SObjectType,
      Contact.AccountId.getDescribe()
    );
    ctx.add(
      new LREngine.RollupSummaryField(
        Account.NumberOfEmployees.getDescribe(),
        Contact.Id.getDescribe(),
        LREngine.RollupOperation.Count
      )
    );
    ctxList.add(ctx);
    List<SObject> records = g.getOnlyRecordsNeedingDml(
      ctxList,
      new Map<Id, SObject>{ a.Id => a }
    );
    System.assertEquals(0, records.size());
  }

  @IsTest
  static void testRollupDmlGuardChangeNotNeeded() {
    RollupDmlGuard g = new RollupDmlGuard();
    Account a = new Account(Name = 'Test', NumberOfEmployees = 1);
    insert a;
    a = new Account(Id = a.Id, NumberOfEmployees = 0);

    List<LREngine.Context> ctxList = new List<LREngine.Context>();
    LREngine.Context ctx = new LREngine.Context(
      Account.SObjectType,
      Contact.SObjectType,
      Contact.AccountId.getDescribe()
    );
    ctx.add(
      new LREngine.RollupSummaryField(
        Account.NumberOfEmployees.getDescribe(),
        Contact.Id.getDescribe(),
        LREngine.RollupOperation.Count
      )
    );
    ctxList.add(ctx);
    List<SObject> records = g.getOnlyRecordsNeedingDml(
      ctxList,
      new Map<Id, SObject>{ a.Id => a }
    );
    System.assertEquals(1, records.size());
    System.assertEquals(a.Id, records[0].Id);
    System.assertEquals(0, a.NumberOfEmployees);
  }

  @IsTest
  static void testRollupGuardDisableViaSettings() {
    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableParentDMLCheck__c = true
    );
    insert settings;

    RollupDmlGuard g = new RollupDmlGuard();
    Account a = new Account(Name = 'Test', NumberOfEmployees = 0);
    insert a;
    a = new Account(Id = a.Id, NumberOfEmployees = 0);

    List<LREngine.Context> ctxList = new List<LREngine.Context>();
    LREngine.Context ctx = new LREngine.Context(
      Account.SObjectType,
      Contact.SObjectType,
      Contact.AccountId.getDescribe()
    );
    ctx.add(
      new LREngine.RollupSummaryField(
        Account.NumberOfEmployees.getDescribe(),
        Contact.Id.getDescribe(),
        LREngine.RollupOperation.Count
      )
    );
    ctxList.add(ctx);
    List<SObject> records = g.getOnlyRecordsNeedingDml(
      ctxList,
      new Map<Id, SObject>{ a.Id => a }
    );
    System.assertEquals(1, records.size());
    System.assertEquals(a.Id, records[0].Id);
    System.assertEquals(0, a.NumberOfEmployees);
  }
}
