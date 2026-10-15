@IsTest
private class RollupControllerTest {
  private static final Id FAKE_ID = '0Af000000004CVY';
  private static final String FAKE_API_VERSION = '61.0';

  private static String contactTriggerName =
    Utilities.componentPrefix() + 'ContactTrigger';
  private static String contactTestName =
    Utilities.componentPrefix() + 'ContactTest';
  private static String accTriggerName =
    Utilities.componentPrefix() + 'AccountTrigger';
  private static String accTestName =
    Utilities.componentPrefix() + 'AccountTest';

  private static HttpCalloutMockImpl mockSuccessfulApiConnection() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(200, '{}'));
    Test.setMock(HttpCalloutMock.class, mock);
    return mock;
  }

  private static RollupSummary makeRollupSummary(
    String childObject,
    String parentObject
  ) {
    return new RollupSummary(
      new LookupRollupSummary__c(
        Name = 'Test Rollup',
        ChildObject__c = childObject,
        ParentObject__c = parentObject,
        FieldToAggregate__c = 'Amount',
        AggregateOperation__c = 'Sum',
        AggregateResultField__c = 'AnnualRevenue',
        Active__c = true,
        CalculationMode__c = 'Realtime'
      )
    );
  }

  private static RollupController makeController(
    String childObject,
    String parentObject
  ) {
    mockSuccessfulApiConnection();
    return new RollupController(makeRollupSummary(childObject, parentObject));
  }

  private static Boolean hasMessage(
    ApexPages.Severity severity,
    String containsText
  ) {
    for (ApexPages.Message m : ApexPages.getMessages()) {
      if (
        m.getSeverity() == severity && m.getSummary().contains(containsText)
      ) {
        return true;
      }
    }
    return false;
  }

  private static HttpResponse makeJsonResponse(
    Integer statusCode,
    String body
  ) {
    HttpResponse res = new HttpResponse();
    res.setStatusCode(statusCode);
    res.setHeader('Content-Type', 'application/json');
    res.setBody(body);
    return res;
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
  static void testConstructorAddsErrorMessageWhenApiConnectionFails() {
    RollupController controller = new RollupController(
      makeRollupSummary('Lead', 'Lead')
    );

    Assert.isFalse(
      controller.Deployed,
      'Expected Deployed to remain false when the connection check fails'
    );
    Assert.isNull(
      controller.apexCodeToDisplay,
      'Expected init() to never run when the connection check fails'
    );
    Assert.isTrue(
      hasMessage(ApexPages.Severity.ERROR, 'Salesforce API connection failure'),
      'Expected a connection failure error message to be added'
    );
  }

  @IsTest
  static void testStandardControllerConstructorDelegatesToRollupSummaryConstructor() {
    LookupRollupSummary__c rec = new LookupRollupSummary__c(
      Name = 'Test Rollup',
      ChildObject__c = 'Lead',
      ParentObject__c = 'Lead',
      RelationshipField__c = 'OwnerId',
      FieldToAggregate__c = 'AnnualRevenue',
      AggregateOperation__c = 'Sum',
      AggregateResultField__c = 'NumberOfEmployees',
      Active__c = false,
      CalculationMode__c = 'Realtime'
    );
    insert rec;
    RollupSummariesSelector.setRollupCache(
      true,
      true,
      new List<RollupSummary>{ new RollupSummary(rec) }
    );

    Test.startTest();
    mockSuccessfulApiConnection();
    RollupController controller = new RollupController(
      new ApexPages.StandardController(rec)
    );
    Test.stopTest();

    Assert.isFalse(controller.Deployed);
    Assert.areEqual(
      2,
      controller.apexCodeToDisplay.size(),
      'Expected the record found by the StandardController Id to be used'
    );
  }

  @IsTest
  static void testConstructorInitializesViewStateForSingleObjectRollup() {
    RollupController controller = makeController('Lead', 'Lead');

    Assert.isFalse(controller.Deployed);
    Assert.isNull(
      controller.ParentMergeable,
      'Expected the parent branch to never run when child and parent are the same object'
    );
    Assert.areEqual(
      2,
      controller.apexCodeToDisplay.size(),
      'Expected the trigger + test class bodies for the child object'
    );
    Assert.isTrue(controller.existingCode.isEmpty());
    Assert.isTrue(
      hasMessage(
        ApexPages.Severity.WARNING,
        'Lookup Rollup Summaries tab is still functional'
      ),
      'Expected the legacy custom-object deprecation warning'
    );
    Assert.isTrue(
      hasMessage(ApexPages.Severity.INFO, 'Click <b>Deploy</b>'),
      'Expected the not-yet-deployed prompt message'
    );
  }

  @IsTest
  static void testConstructorInitializesViewStateForDifferentMergeableParent() {
    RollupController controller = makeController('Contact', 'Account');

    Assert.isFalse(controller.Deployed);
    Assert.isTrue(
      controller.ParentMergeable,
      'Expected Account (the parent) to be recognized as mergeable'
    );
    Assert.isTrue(
      controller.getParentTriggerRequired(),
      'Expected ParentTriggerRequired to default to ParentMergeable when unset'
    );
    Assert.areEqual(
      4,
      controller.apexCodeToDisplay.size(),
      'Expected trigger + test bodies for both the child and parent objects'
    );
  }

  @IsTest
  static void testSetParentTriggerRequiredFalseExcludesParentCode() {
    RollupController controller = makeController('Contact', 'Account');

    controller.setParentTriggerRequired(false);

    Assert.isFalse(controller.getParentTriggerRequired());
    Assert.areEqual(
      2,
      controller.apexCodeToDisplay.size(),
      'Expected only the child trigger + test bodies once the parent trigger is opted out of'
    );
  }

  @IsTest
  static void testDeployZipDeploysChildOnlyWhenParentTriggerNotRequired() {
    RollupController controller = makeController('Contact', 'Account');
    controller.setParentTriggerRequired(false);

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.deployZipResult = makeDeployRequestResult(FAKE_ID, false, null);
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    controller.deployZip();

    Assert.areEqual(1, stub.deployZipCallCount);
    Assert.areEqual(FAKE_ID, controller.deployRequestResult.id);

    Assert.areEqual('RunSpecifiedTests', stub.lastDeployOptions.testLevel);
    Assert.isFalse(stub.lastDeployOptions.allowMissingFiles);
    Assert.isFalse(stub.lastDeployOptions.purgeOnDelete);
    Assert.isTrue(stub.lastDeployOptions.rollbackOnError);

    Map<String, Blob> entries = extractZipEntries(stub.lastZip);
    Assert.isTrue(
      entries.containsKey('triggers/' + contactTriggerName + '.trigger')
    );
    Assert.isTrue(entries.containsKey('classes/' + contactTestName + '.cls'));
    Assert.isFalse(
      entries.containsKey('triggers/' + accTriggername + '.trigger'),
      'Expected the parent trigger to be excluded once its deployment was opted out of'
    );
    Assert.isFalse(
      entries.containsKey('classes/' + accTestName + '.cls'),
      'Expected the parent test class to be excluded once its deployment was opted out of'
    );
  }

  @IsTest
  static void testDeployZipDeploysChildAndParentWhenParentTriggerRequired() {
    RollupController controller = makeController('Contact', 'Account');
    // Left at its default (ParentMergeable coalesces ParentTriggerRequired to true).

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.deployZipResult = makeDeployRequestResult(FAKE_ID, false, null);
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    controller.deployZip();

    Map<String, Blob> entries = extractZipEntries(stub.lastZip);
    Assert.isTrue(
      entries.containsKey('triggers/' + contactTriggerName + '.trigger')
    );
    Assert.isTrue(entries.containsKey('classes/' + contactTestName + '.cls'));
    Assert.isTrue(
      entries.containsKey('triggers/' + accTriggerName + '.trigger'),
      'Expected the parent trigger to be included when its deployment is required'
    );
    Assert.isTrue(
      entries.containsKey('classes/' + accTestName + '.cls'),
      'Expected the parent test class to be included when its deployment is required'
    );
  }

  @IsTest
  static void testCheckAsyncRequestShowsProgressMessageWhenNotDone() {
    RollupController controller = makeController('Lead', 'Lead');

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.deployZipResult = makeDeployRequestResult(FAKE_ID, false, null);
    stub.getDeployStatusResult = makeDeployRequestResult(FAKE_ID, false, null);
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    controller.deployZip();
    controller.checkAsyncRequest();

    Assert.areEqual(1, stub.getDeployStatusCallCount);
    Assert.areEqual(FAKE_ID, stub.lastGetDeployStatusId);
    Assert.isNotNull(
      controller.deployRequestResult,
      'Expected the in-flight result to be kept while the deployment is still running'
    );
    Assert.areEqual(1, controller.deployCount);
    Assert.isTrue(
      hasMessage(ApexPages.Severity.INFO, 'Deploying...'),
      'Expected a progress message while the deployment is not yet done'
    );
  }

  @IsTest
  static void testCheckAsyncRequestCompletesClearsResultAndReinitializes() {
    RollupController controller = makeController('Lead', 'Lead');

    MetadataRestService.DeployDetails details = new MetadataRestService.DeployDetails();
    details.runTestResult = new MetadataRestService.RunTestsResult();
    details.runTestResult.numFailures = 0;

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.deployZipResult = makeDeployRequestResult(FAKE_ID, false, null);
    stub.getDeployStatusResult = makeDeployRequestResult(
      FAKE_ID,
      true,
      details
    );
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    controller.deployZip();
    controller.checkAsyncRequest();

    Assert.isNull(
      controller.deployRequestResult,
      'Expected the result to be cleared once the deployment is done'
    );
    Assert.isTrue(
      hasMessage(ApexPages.Severity.INFO, 'Deployment complete.'),
      'Expected a completion message'
    );
    // init() runs again once the deployment finishes, repopulating view state.
    Assert.areEqual(2, controller.apexCodeToDisplay.size());
  }

  @IsTest
  static void testCheckAsyncRequestReportsComponentAndTestFailures() {
    RollupController controller = makeController('Lead', 'Lead');

    MetadataRestService.DeployMessage failedComponent = new MetadataRestService.DeployMessage();
    failedComponent.fileName = 'LeadTrigger.trigger';
    failedComponent.lineNumber = 3;
    failedComponent.columnNumber = 5;
    failedComponent.problem = 'Invalid trigger syntax';

    MetadataRestService.RunTestFailure testFailure = new MetadataRestService.RunTestFailure();
    testFailure.name = 'LeadTest';
    testFailure.methodName = 'testTrigger';
    testFailure.message = 'System.AssertException: boom';
    testFailure.stackTrace = 'Class.LeadTest.testTrigger: line 5';

    MetadataRestService.CodeCoverageWarning coverageWarning = new MetadataRestService.CodeCoverageWarning();
    coverageWarning.namespace = 'dlrs';
    coverageWarning.name = 'LeadTrigger';
    coverageWarning.message = 'Trigger has no test coverage';

    MetadataRestService.CodeCoverageWarning unnamespacedCoverageWarning = new MetadataRestService.CodeCoverageWarning();
    unnamespacedCoverageWarning.namespace = null;
    unnamespacedCoverageWarning.name = 'LeadTest';
    unnamespacedCoverageWarning.message = 'Test class has no assertions';

    MetadataRestService.DeployDetails details = new MetadataRestService.DeployDetails();
    details.componentFailures = new List<MetadataRestService.DeployMessage>{
      failedComponent
    };
    details.runTestResult = new MetadataRestService.RunTestsResult();
    details.runTestResult.numFailures = 1;
    details.runTestResult.failures = new List<MetadataRestService.RunTestFailure>{
      testFailure
    };
    details.runTestResult.codeCoverageWarnings = new List<MetadataRestService.CodeCoverageWarning>{
      coverageWarning,
      unnamespacedCoverageWarning
    };

    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.deployZipResult = makeDeployRequestResult(FAKE_ID, false, null);
    stub.getDeployStatusResult = makeDeployRequestResult(
      FAKE_ID,
      true,
      details
    );
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    controller.deployZip();
    controller.checkAsyncRequest();

    Assert.isTrue(
      hasMessage(ApexPages.Severity.ERROR, 'Invalid trigger syntax'),
      'Expected the component failure to be reported'
    );
    Assert.isTrue(
      hasMessage(ApexPages.Severity.ERROR, 'System.AssertException: boom'),
      'Expected the test failure to be reported'
    );
    Assert.isTrue(
      hasMessage(
        ApexPages.Severity.WARNING,
        'dlrs.LeadTrigger:Trigger has no test coverage'
      ),
      'Expected the code coverage warning to be reported with its namespace prefix'
    );
    Assert.isTrue(
      hasMessage(
        ApexPages.Severity.WARNING,
        'LeadTest:Test class has no assertions'
      ),
      'Expected a code coverage warning with no namespace to be reported without a prefix'
    );
  }

  private static MetadataRestService.DeployRequestResult makeDeployRequestResult(
    Id id,
    Boolean done,
    MetadataRestService.DeployDetails details
  ) {
    MetadataRestService.DeployRequestResult result = new MetadataRestService.DeployRequestResult();
    result.id = id;
    result.deployResult = new MetadataRestService.DeployResult();
    result.deployResult.id = id;
    result.deployResult.done = done;
    result.deployResult.success = done;
    result.deployResult.status = done ? 'Succeeded' : 'InProgress';
    result.deployResult.details = details;
    return result;
  }

  private class HttpCalloutMockImpl implements HttpCalloutMock {
    public List<HttpRequest> requests = new List<HttpRequest>();
    public List<HttpResponse> responses = new List<HttpResponse>();
    public Integer callCount = 0;

    public HTTPResponse respond(HTTPRequest req) {
      callCount++;
      requests.add(req);
      return responses.remove(0);
    }
  }

  private class MetadataRestServiceStub implements System.StubProvider {
    public Integer deployZipCallCount = 0;
    public Blob lastZip;
    public MetadataRestService.DeployOptions lastDeployOptions;
    public MetadataRestService.DeployRequestResult deployZipResult;

    public Integer getDeployStatusCallCount = 0;
    public Id lastGetDeployStatusId;
    public MetadataRestService.DeployRequestResult getDeployStatusResult;

    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (stubbedMethodName == 'deployZip') {
        deployZipCallCount++;
        lastZip = (Blob) listOfArgs[0];
        lastDeployOptions = (MetadataRestService.DeployOptions) listOfArgs[1];
        return deployZipResult;
      }
      if (stubbedMethodName == 'getDeployStatus') {
        getDeployStatusCallCount++;
        lastGetDeployStatusId = (Id) listOfArgs[0];
        return getDeployStatusResult;
      }
      return null;
    }
  }
}
