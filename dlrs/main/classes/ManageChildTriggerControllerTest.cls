@IsTest
private class ManageChildTriggerControllerTest {
  private static final String FAKE_API_VERSION = '61.0';

  private static RollupSummary makeAndCacheRollupSummary(
    Id rollupId,
    String childObject,
    String parentObject
  ) {
    RollupSummary summary = new RollupSummary(
      new LookupRollupSummary2__mdt(
        Id = rollupId,
        DeveloperName = 'Fake_Rollup',
        Label = 'Fake Rollup',
        ChildObject__c = childObject,
        ParentObject__c = parentObject,
        Active__c = true,
        CalculationMode__c = 'Realtime',
        TestCodeSeeAllData__c = false
      )
    );
    RollupSummariesSelector.setRollupCache(
      true,
      true,
      new List<RollupSummary>{ summary }
    );
    return summary;
  }

  private static Map<String, Blob> extractZipEntries(Blob zip) {
    Map<String, Blob> entries = new Map<String, Blob>();
    Compression.ZipReader reader = new Compression.ZipReader(zip);
    for (Compression.ZipEntry entry : reader.getEntries()) {
      entries.put(entry.getName(), reader.extract(entry));
    }
    return entries;
  }

  @IsTest
  static void testGetChildTriggerInfoReturnsGeneratedCodeForTheSelectedRollup() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    Id rollupId = prefix + '00000000000000D';
    makeAndCacheRollupSummary(rollupId, 'Lead', 'Lead');

    List<TriggerGenerationService.GeneratedCode> generated = ManageChildTriggerController.getChildTriggerInfo(
      rollupId
    );

    Assert.areEqual(
      2,
      generated.size(),
      'Expected the generated code for the rollup found by the given Id'
    );
    Assert.areEqual('LeadTrigger', generated[0].assetName);
    Assert.areEqual('LeadTest', generated[1].assetName);
  }

  @IsTest
  static void testStartDeploymentBuildsZipAndDeployOptionsFromSelectedChanges() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    Id rollupId = prefix + '00000000000000D';
    makeAndCacheRollupSummary(rollupId, 'Opportunity', 'Account');

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    Map<String, Map<String, List<String>>> changes = new Map<String, Map<String, List<String>>>{
      'deploy' => new Map<String, List<String>>{
        'ApexTrigger' => new List<String>{ 'OpportunityTrigger' },
        'ApexClass' => new List<String>{ 'OpportunityTest' }
      },
      'delete' => new Map<String, List<String>>{
        'ApexTrigger' => new List<String>{ 'AccountTrigger' }
      }
    };

    Id result = ManageChildTriggerController.startDeployment(
      rollupId,
      changes,
      'RunSpecifiedTests',
      new List<String>{ 'SomeExplicitlyRequestedTest' }
    );

    Assert.areEqual(
      stub.resultId,
      result,
      'Expected the Id returned by deployZipAsync() to be returned'
    );
    Assert.areEqual(
      1,
      stub.deployZipAsyncCallCount,
      'Expected exactly one deployment to be kicked off'
    );

    MetadataRestService.DeployOptions options = stub.lastOptions;
    Assert.areEqual('RunSpecifiedTests', options.testLevel);
    Assert.isFalse(
      options.allowMissingFiles,
      'Expected allowMissingFiles to always be false'
    );
    Assert.isFalse(
      options.purgeOnDelete,
      'Expected purgeOnDelete to always be false'
    );
    Assert.isTrue(
      options.rollbackOnError,
      'Expected rollbackOnError to always be true'
    );
    Assert.isTrue(
      new Set<String>(options.runTests)
        .containsAll(
          new Set<String>{ 'OpportunityTest', 'SomeExplicitlyRequestedTest' }
        ),
      'Expected runTests to include both the deployed test class and the explicitly requested test'
    );

    Map<String, Blob> entries = extractZipEntries(stub.lastZip);
    Assert.isTrue(
      entries.containsKey('triggers/OpportunityTrigger.trigger'),
      'Expected the deployed trigger body to be included'
    );
    Assert.isTrue(
      entries.containsKey('classes/OpportunityTest.cls'),
      'Expected the deployed test class body to be included'
    );
    Assert.isTrue(
      entries.containsKey('destructiveChangesPre.xml'),
      'Expected a destructive changes manifest for the deleted trigger'
    );
    Assert.isFalse(
      entries.containsKey('triggers/AccountTrigger.trigger'),
      'Expected no body file for a trigger being destroyed'
    );
    Assert.isFalse(
      entries.containsKey('classes/AccountTest.cls'),
      'Expected the untouched AccountTest to be excluded from the deployment entirely'
    );
  }

  @IsTest
  static void testStartDeploymentDefaultsPlaceholderTestWhenNoneSelected() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    Id rollupId = prefix + '00000000000000D';
    makeAndCacheRollupSummary(rollupId, 'Lead', 'Lead');

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    Map<String, Map<String, List<String>>> changes = new Map<String, Map<String, List<String>>>{
      'deploy' => new Map<String, List<String>>{
        'ApexTrigger' => new List<String>{ 'LeadTrigger' }
      },
      'delete' => new Map<String, List<String>>()
    };

    ManageChildTriggerController.startDeployment(
      rollupId,
      changes,
      'RunSpecifiedTests',
      new List<String>()
    );

    Assert.areEqual(
      new List<String>{ 'FakeTestDoesntExist' },
      stub.lastOptions.runTests,
      'Expected a placeholder test to be used so the deploy request always has at least one test'
    );
  }

  @IsTest
  static void testStartDeploymentDoesNotSetRunTestsForOtherTestLevels() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    Id rollupId = prefix + '00000000000000D';
    makeAndCacheRollupSummary(rollupId, 'Lead', 'Lead');

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    Map<String, Map<String, List<String>>> changes = new Map<String, Map<String, List<String>>>{
      'deploy' => new Map<String, List<String>>{
        'ApexTrigger' => new List<String>{ 'LeadTrigger' }
      },
      'delete' => new Map<String, List<String>>()
    };

    ManageChildTriggerController.startDeployment(
      rollupId,
      changes,
      'RunLocalTests',
      new List<String>()
    );

    Assert.areEqual('RunLocalTests', stub.lastOptions.testLevel);
    Assert.isNull(
      stub.lastOptions.runTests,
      'Expected runTests to be left unset for test levels other than RunSpecifiedTests'
    );
  }

  private class MetadataRestServiceStub implements System.StubProvider {
    public Integer deployZipAsyncCallCount = 0;
    public Blob lastZip;
    public MetadataRestService.DeployOptions lastOptions;
    public Id resultId = '0Af000000004CVY';

    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (stubbedMethodName == 'deployZipAsync') {
        deployZipAsyncCallCount++;
        lastZip = (Blob) listOfArgs[0];
        lastOptions = (MetadataRestService.DeployOptions) listOfArgs[1];
        return resultId;
      }
      return null;
    }
  }
}
