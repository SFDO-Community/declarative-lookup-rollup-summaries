/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

/**
 * Handles the Manage Trigger VF pages
 **/
public with sharing class RollupController {
  public MetadataRestService.DeployRequestResult deployRequestResult {
    get;
    private set;
  }

  public RollupSummary RollupSummary { get; private set; }
  public Boolean Deployed { get; private set; }
  public Boolean ParentMergeable { get; private set; }
  public Boolean MetadataConnectionError { get; private set; }
  public List<String> apexCodeToDisplay { get; private set; }
  public List<TriggerGenerationService.GeneratedCode> existingCode {
    get;
    private set;
  }

  public Boolean ParentTriggerRequired;
  public Integer deployCount;

  public RollupController(ApexPages.StandardController standardController) {
    // Query Lookup Rollup Summary record
    this(
      new RollupSummariesSelector(true, true)
        .selectById(new Set<String>{ (String) standardController.getId() })[0]
    );
  }

  public Boolean getParentTriggerRequired() {
    System.debug('getParentTriggerRequired');
    return this.ParentTriggerRequired;
  }

  public void setParentTriggerRequired(Boolean value) {
    System.debug('setParentTriggerRequired:' + value);
    this.ParentTriggerRequired = value;
    init();
  }

  @TestVisible
  private RollupController(RollupSummary rollupSummary) {
    this.Deployed = false;
    this.RollupSummary = rollupSummary;

    // Metadata API connection?
    try {
      MetadataRestService.checkAPIConnection();
    } catch (Exception e) {
      System.debug(e);
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Salesforce API connection failure'
        )
      );
      return;
    }

    // Initialise view state
    init();
  }

  public PageReference deployZip() {
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.Info,
        Deployed ? 'Removing...' : 'Deploying...'
      )
    );

    List<TriggerGenerationService.GeneratedCode> generatedApex = TriggerGenerationService.generateApexForRollup(
      this.RollupSummary
    );
    List<TriggerGenerationService.GeneratedCode> itemsToDestroy = new List<TriggerGenerationService.GeneratedCode>();
    List<TriggerGenerationService.GeneratedCode> itemsToDeploy = new List<TriggerGenerationService.GeneratedCode>();

    List<String> testClassesToRun = new List<String>();

    for (TriggerGenerationService.GeneratedCode gc : generatedApex) {
      if ('ApexClass'.equals(gc.mdtType)) {
        testClassesToRun.add(gc.assetName);
      }
    }
    if (this.Deployed) {
      for (TriggerGenerationService.GeneratedCode gc : generatedApex) {
        if (String.isNotBlank(gc.existingBody)) {
          itemsToDestroy.add(gc);
        }
      }
    } else {
      for (TriggerGenerationService.GeneratedCode gc : generatedApex) {
        if ('ApexClass'.equals(gc.mdtType)) {
          testClassesToRun.add(gc.assetName);
        }
        if (this.RollupSummary.ChildObject.equals(gc.sObjectName)) {
          itemsToDeploy.add(gc);
        } else if (
          this.RollupSummary.ParentObject.equals(gc.sObjectName) &&
          ParentTriggerRequired
        ) {
          itemsToDeploy.add(gc);
        }
      }
    }

    Blob deploymentZip = TriggerGenerationService.getZipFromChangeSet(
      itemsToDeploy,
      itemsToDestroy
    );

    MetadataRestService.DeployOptions options = new MetadataRestService.DeployOptions();
    options.testLevel = 'RunSpecifiedTests';
    options.runTests = new List<String>(testClassesToRun);
    options.allowMissingFiles = false;
    options.purgeOnDelete = false;
    options.rollbackOnError = true;

    MetadataRestService svc = MetadataRestService.getInstance();
    this.deployRequestResult = svc.deployZip(deploymentZip, options);
    return null;
  }

  public PageReference checkAsyncRequest() {
    // Check the status of the retrieve request
    MetadataRestService svc = MetadataRestService.getInstance();
    this.deployRequestResult = svc.getDeployStatus(
      this.deployRequestResult.id,
      true
    );
    MetadataRestService.DeployResult depRes = this.deployRequestResult.deployResult;
    if (depRes.done) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Info,
          this.Deployed ? 'Remove complete.' : 'Deployment complete.'
        )
      );

      // Deployment errors?
      if (depRes.details != null && depRes.details.componentFailures != null)
        for (
          MetadataRestService.DeployMessage deployMessage : depRes.details.componentFailures
        )
          if (deployMessage.problem != null)
            ApexPages.addMessage(
              new ApexPages.Message(
                ApexPages.Severity.Error,
                deployMessage.fileName +
                  ' (Line: ' +
                  deployMessage.lineNumber +
                  ': Column:' +
                  deployMessage.columnNumber +
                  ') : ' +
                  deployMessage.problem
              )
            );
      // Test errors?
      MetadataRestService.RunTestsResult runTestResult = depRes.details.runTestResult;
      if (runTestResult.numFailures > 0)
        for (
          MetadataRestService.RunTestFailure testFailure : runTestResult.failures
        )
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.Error,
              testFailure.name +
                '.' +
                testFailure.methodName +
                ' ' +
                testFailure.message +
                ' ' +
                testFailure.stackTrace
            )
          );
      // Code coverage warnings?
      if (runTestResult.codeCoverageWarnings != null)
        for (
          MetadataRestService.CodeCoverageWarning codeCoverageWarning : runTestResult.codeCoverageWarnings
        )
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.Warning,
              (codeCoverageWarning.namespace != null
                  ? codeCoverageWarning.namespace + '.'
                  : '') +
                codeCoverageWarning.name +
                ':' +
                codeCoverageWarning.message
            )
          );

      this.deployRequestResult = null;

      // If this was an undeploy and was successful?
      if (this.Deployed && !ApexPages.hasMessages(ApexPages.Severity.Error)) {
        // Determine active rollups for this child and deactivate them
        List<RollupSummary> rollups = new RollupSummariesSelector()
          .selectActiveByChildObject(
            RollupSummaries.CalculationMode.Realtime,
            new Set<String>{ RollupSummary.ChildObject }
          );
        List<LookupRollupSummary__c> recordsToUpdate = new List<LookupRollupSummary__c>();
        for (RollupSummary rollup : rollups) {
          // TODO: Can only auto deactivate Custom Object based rollups
          if (rollup.Record instanceof LookupRollupSummary__c) {
            rollup.Active = false;
            recordsToUpdate.add((LookupRollupSummary__c) rollup.Record);
          }
        }
        update recordsToUpdate;
      }

      // Initialise view state to try again
      this.ParentTriggerRequired = null;
      this.Deployed = false;
      init();
    } else {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Info,
          (Deployed ? 'Removing...' : 'Deploying...') +
          '.'.repeat(deployCount++)
        )
      );
    }
    return null;
  }

  private void init() {
    deployCount = 0;

    this.apexCodeToDisplay = new List<String>();
    this.existingCode = new List<TriggerGenerationService.GeneratedCode>();
    List<TriggerGenerationService.GeneratedCode> generatedApex = TriggerGenerationService.generateApexForRollup(
      this.RollupSummary
    );

    // TODO: cleanup evaluations here

    for (TriggerGenerationService.GeneratedCode gc : generatedApex) {
      if (this.RollupSummary.ChildObject.equals(gc.sObjectName)) {
        apexCodeToDisplay.add(gc.existingBody ?? gc.body);
        if (String.isNotBlank(gc.existingBody)) {
          this.Deployed = true;
          this.existingCode.add(gc);
        }
      } else if (this.RollupSummary.ParentObject.equals(gc.sObjectName)) {
        this.ParentMergeable = true;
        this.ParentTriggerRequired = this.ParentTriggerRequired ??
          this.ParentMergeable;
        if (this.ParentTriggerRequired == true) {
          if (this.Deployed == false || String.isNotBlank(gc.existingBody)) {
            apexCodeToDisplay.add(gc.existingBody ?? gc.body);
          }
          if (String.isNotBlank(gc.existingBody)) {
            this.existingCode.add(gc);
          }
        }
      }
    }

    // Deprication warning
    if (RollupSummary.Record instanceof LookupRollupSummary__c) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Warning,
          'Use of the Lookup Rollup Summaries tab is still functional but no longer being enhanced. Consider using the Manage Lookup Rollup Summaries tab.'
        )
      );
    }

    // Message to confirm current status
    if (this.Deployed) {
      for (TriggerGenerationService.GeneratedCode gc : this.existingCode) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.Info,
            gc.mdtType + ' <b>' + gc.assetName + '</b> is installed.'
          )
        );
      }
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Info,
          'Click <b>Remove</b> to uninstall the Apex Trigger and Apex Class for this child object.'
        )
      );
    } else {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Info,
          'Click <b>Deploy</b> to install the Apex Trigger and Apex Class for this child object.'
        )
      );
    }
  }
}
