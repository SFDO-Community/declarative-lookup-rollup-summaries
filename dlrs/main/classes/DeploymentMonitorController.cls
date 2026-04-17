public with sharing class DeploymentMonitorController {
  /**
   * Request a Queueable be started to check on the status of a deployment
   * That status will be reported using the UserNotification platform event
   *
   * @param {deploymentId} id of the Deployment to be checked
   */
  @AuraEnabled
  public static void requestDeploymentStatusCheck(Id deploymentId) {
    try {
      new MetadataRestService().getDeployStatusAsync(deploymentId, true);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
