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
    Map<String, List<Map<String, Object>>> changes
  ) {
    Map<String, List<TriggerGenerationService.GeneratedCode>> changesByType = (Map<String, List<TriggerGenerationService.GeneratedCode>>) JSON.deserialize(
      JSON.serialize(changes),
      Map<String, List<TriggerGenerationService.GeneratedCode>>.class
    );

    Blob packagedZip = TriggerGenerationService.getZipFromChangeSet(
      changesByType.get('deploy'),
      changesByType.get('delete')
    );
    MetadataRestService.DeployOptions options = new MetadataRestService.DeployOptions();
    options.runTests = new List<String>();
    options.testLevel = 'RunSpecifiedTests';
    for (
      TriggerGenerationService.GeneratedCode cde : changesByType.get('deploy')
    ) {
      if (cde.mdtType == 'ApexClass') {
        options.runTests.add(cde.assetName);
      }
    }
    if (options.runTests.isEmpty()) {
      options.runTests.add('FakeTest');
    }
    options.allowMissingFiles = false;
    options.purgeOnDelete = false;
    options.rollbackOnError = true;

    return new MetadataRestService().deployZipAsync(packagedZip, options);
  }
}
