public with sharing class ManageChildTriggerController {
  @AuraEnabled
  public static List<TriggerGenerationService.GeneratedCode> getChildTriggerInfo(
    String rollupName
  ) {
    RollupSummary rollup = new RollupSummariesSelector(true, true)
      .selectById(new Set<String>{ rollupName })[0];

    return TriggerGenerationService.generateApexForRollup(rollup);
  }

  @AuraEnabled
  public static Id startDeployment(
    Map<String, List<Map<String, Object>>> changes,
    List<String> testsToRun
  ) {
    Map<String, List<TriggerGenerationService.GeneratedCode>> changesByType = (Map<String, List<TriggerGenerationService.GeneratedCode>>) JSON.deserialize(
      JSON.serialize(changes),
      Map<String, List<TriggerGenerationService.GeneratedCode>>.class
    );

    Blob packagedZip = TriggerGenerationService.getZipFromChangeSet(
      changesByType.get('deploy'),
      changesByType.get('delete')
    );
    Set<String> testClassesToRun = new Set<String>();
    testClassesToRun.addAll(testsToRun);
    for (
      TriggerGenerationService.GeneratedCode generatedCode : changesByType.get(
        'deploy'
      )
    ) {
      // could get fancy and try and see if it has the string "IsTest" somewhere
      if (generatedCode.mdtType == 'ApexClass') {
        testClassesToRun.add(generatedCode.assetName);
      }
    }

    MetadataRestService.DeployOptions options = new MetadataRestService.DeployOptions();
    options.testLevel = 'RunSpecifiedTests';
    options.runTests = new List<String>(testClassesToRun);
    // ensure at least one tests is specified, even if it doesn't exist
    if (options.runTests.isEmpty()) {
      options.runTests.add('FakeTestDoesntExist');
    }
    options.allowMissingFiles = false;
    options.purgeOnDelete = false;
    options.rollbackOnError = true;

    return new MetadataRestService().deployZipAsync(packagedZip, options);
  }
}
