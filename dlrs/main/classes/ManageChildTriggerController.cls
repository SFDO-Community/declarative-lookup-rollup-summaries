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
    options.testLevel = 'NoTestRun';

    return System.enqueueJob(new DeploymentQueueable(packagedZip, options));
  }

  public class DeploymentQueueable implements Queueable, Database.AllowsCallouts {
    Blob zippedPackaged;
    MetadataRestService.DeployOptions opts;

    public DeploymentQueueable(
      Blob zippedPackage,
      MetadataRestService.DeployOptions options
    ) {
      this.zippedPackaged = zippedPackage;
      this.opts = options;
    }

    public void execute(QueueableContext ctx) {
      MetadataRestService svc = new MetadataRestService();
      MetadataRestService.DeployRequestResult res = svc.deployZip(
        this.zippedPackaged,
        this.opts
      );
      System.debug('Dep Id:' + res.id);
      System.debug('Results:' + res);
    }
  }
}
