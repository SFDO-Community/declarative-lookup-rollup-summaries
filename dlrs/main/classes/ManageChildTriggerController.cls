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
    String rollupName,
    Map<String, Map<String, List<String>>> changes,
    String testLevel,
    List<String> testsToRun
  ) {
    RollupSummary rollup = new RollupSummariesSelector(true, true)
      .selectById(new Set<String>{ rollupName })[0];
    // regenerate all the code because we don't trust the UI, it can tell us what to do with something but it can't tell us the definition
    List<TriggerGenerationService.GeneratedCode> generatedCode = TriggerGenerationService.generateApexForRollup(
      rollup
    );
    List<TriggerGenerationService.GeneratedCode> codeToDeploy = new List<TriggerGenerationService.GeneratedCode>();
    List<TriggerGenerationService.GeneratedCode> codeToDelete = new List<TriggerGenerationService.GeneratedCode>();
    Map<String, List<String>> toDelete = changes.get('delete');
    Map<String, List<String>> toDeploy = changes.get('deploy');
    // cross-check what the UI wants us to do with what we generated
    for (TriggerGenerationService.GeneratedCode code : generatedCode) {
      if (
        toDelete.containsKey(code.mdtType) &&
        toDelete.get(code.mdtType).contains(code.assetName)
      ) {
        codeToDelete.add(code);
      } else if (
        toDeploy.containsKey(code.mdtType) &&
        toDeploy.get(code.mdtType).contains(code.assetName)
      ) {
        codeToDeploy.add(code);
      }
    }

    Blob packagedZip = TriggerGenerationService.getZipFromChangeSet(
      codeToDeploy,
      codeToDelete
    );
    Set<String> testClassesToRun = new Set<String>();
    testClassesToRun.addAll(testsToRun);
    for (TriggerGenerationService.GeneratedCode code : codeToDeploy) {
      // could get fancy and try and see if it has the string "IsTest" somewhere
      if (code.mdtType == 'ApexClass') {
        testClassesToRun.add(code.assetName);
      }
    }

    MetadataRestService.DeployOptions options = new MetadataRestService.DeployOptions();
    options.testLevel = testLevel;
    if ('RunSpecifiedTests'.equals(options.testLevel)) {
      options.runTests = new List<String>(testClassesToRun);
      // ensure at least one tests is specified, even if it doesn't exist
      if (options.runTests.isEmpty()) {
        options.runTests.add('FakeTestDoesntExist');
      }
    }
    options.allowMissingFiles = false;
    options.purgeOnDelete = false;
    options.rollbackOnError = true;

    return MetadataRestService.getInstance()
      .deployZipAsync(packagedZip, options);
  }
}
