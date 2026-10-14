@IsTest
private class MetadataRestServiceTest {
  private static final Id FAKE_ID = '0Af000000004CVY';

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

  private static String makeDeployRequestResultJson(
    Id id,
    String status,
    Boolean success
  ) {
    return '{"id":"' +
      id +
      '","deployResult":{"id":"' +
      id +
      '","status":"' +
      status +
      '","success":' +
      success +
      ',"done":true}}';
  }

  @IsTest
  static void testGetInstanceReturnsSameSingletonInstance() {
    MetadataRestService instance1 = MetadataRestService.getInstance();
    MetadataRestService instance2 = MetadataRestService.getInstance();

    Assert.areEqual(
      instance1,
      instance2,
      'Expected getInstance() to always return the same singleton instance'
    );
  }

  @IsTest
  static void testCheckAPIConnectionReturnsTrueOnSuccess() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(200, '{}'));
    Test.setMock(HttpCalloutMock.class, mock);

    Boolean result = MetadataRestService.checkAPIConnection();

    Assert.isTrue(
      result,
      'Expected true when the API responds with status 200'
    );
    Assert.areEqual(1, mock.callCount);
    Assert.areEqual('GET', mock.requests[0].getMethod());
    Assert.isTrue(
      mock.requests[0].getEndpoint().endsWith('/limits'),
      'Expected the limits endpoint to be used'
    );
  }

  @IsTest
  static void testCheckAPIConnectionThrowsOnNonSuccessStatus() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(500, '{"error":"boom"}'));
    Test.setMock(HttpCalloutMock.class, mock);

    try {
      MetadataRestService.checkAPIConnection();
      Assert.fail(
        'Expected an exception when the API responds with a non-200 status'
      );
    } catch (MetadataRestService.MetadataRestServiceException e) {
      Assert.isTrue(
        e.getMessage().contains('500'),
        'Expected the failing status code to be included in the exception message'
      );
    }
  }

  @IsTest
  static void testRetrieveBestApiVersionReturnsHighestVersionAndCachesIt() {
    MetadataRestService.componentApiVersion = null;
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(
      makeJsonResponse(
        200,
        '[{"version":"68.0"},{"version":"70.0"},{"version":"69.0"}]'
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    String firstResult = MetadataRestService.retrieveBestApiVersion();
    String secondResult = MetadataRestService.retrieveBestApiVersion();

    Assert.areEqual(
      '70.0',
      firstResult,
      'Expected the highest version in the response'
    );
    Assert.areEqual(
      firstResult,
      secondResult,
      'Expected the cached value to be returned on a subsequent call'
    );
    Assert.areEqual(
      1,
      mock.callCount,
      'Expected only one callout since the result is cached after the first call'
    );
  }

  @IsTest
  static void testRetrieveBestApiVersionReturnsFallbackWithoutCachingOnNon200Status() {
    MetadataRestService.componentApiVersion = null;

    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(500, '{}'));
    mock.responses.add(makeJsonResponse(500, '{}'));
    Test.setMock(HttpCalloutMock.class, mock);

    String firstResult = MetadataRestService.retrieveBestApiVersion();
    String secondResult = MetadataRestService.retrieveBestApiVersion();

    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      firstResult
    );
    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      secondResult
    );
    // Unlike the exception path, a non-200 status is never cached, so every
    // call re-attempts the callout.
    Assert.areEqual(
      2,
      mock.callCount,
      'Expected a fresh callout attempt on every call since a non-200 status is not cached'
    );
  }

  @IsTest
  static void testRetrieveBestApiVersionCachesFallbackOnCalloutException() {
    MetadataRestService.componentApiVersion = null;

    ThrowingCalloutMock mock = new ThrowingCalloutMock();
    Test.setMock(HttpCalloutMock.class, mock);

    String firstResult = MetadataRestService.retrieveBestApiVersion();
    String secondResult = MetadataRestService.retrieveBestApiVersion();

    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      firstResult
    );
    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      secondResult
    );
    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      MetadataRestService.componentApiVersion,
      'Expected the fallback to be cached after a callout exception'
    );
    Assert.areEqual(
      1,
      mock.callCount,
      'Expected only one callout attempt; the second call should use the cached fallback'
    );
  }

  @IsTest
  static void testDeployZipSendsExpectedMultipartRequestAndParsesResponse() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'Succeeded', true)
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    MetadataRestService.DeployOptions options = new MetadataRestService.DeployOptions();
    options.testLevel = 'RunSpecifiedTests';
    options.runTests = new List<String>{ 'SomeTest' };
    Blob zipFile = Blob.valueOf('fake zip bytes');

    MetadataRestService.DeployRequestResult result = MetadataRestService.getInstance()
      .deployZip(zipFile, options);

    Assert.areEqual(1, mock.callCount, 'Expected exactly one callout');
    Assert.areEqual(FAKE_ID, result.id);
    Assert.areEqual('Succeeded', result.deployResult.status);
    Assert.isTrue(result.deployResult.success);

    HttpRequest sentRequest = mock.requests[0];
    Assert.areEqual('POST', sentRequest.getMethod());
    Assert.isTrue(
      sentRequest.getEndpoint().endsWith('/metadata/deployRequest'),
      'Expected the deploy endpoint to be used'
    );
    Assert.areEqual(
      'multipart/form-data; boundary=CONTENT_BOUNDARY_MARK',
      sentRequest.getHeader('Content-Type')
    );

    String bodyText = sentRequest.getBodyAsBlob().toString();
    Assert.isTrue(
      bodyText.contains('Content-Disposition: form-data; name="json"'),
      'Expected the DeployOptions JSON part to be present'
    );
    Assert.isTrue(
      bodyText.contains('"testLevel":"RunSpecifiedTests"'),
      'Expected the serialized DeployOptions to be embedded in the request body'
    );
    Assert.isTrue(
      bodyText.contains(
        'Content-Disposition: form-data; name="file"; filename="deploy.zip"'
      ),
      'Expected the zip file part to be present'
    );
    Assert.isTrue(
      bodyText.contains('fake zip bytes'),
      'Expected the zip file bytes to be embedded in the request body'
    );
  }

  @IsTest
  static void testDeployZipThrowsOnUnparseableResponse() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(200, 'not valid json'));
    Test.setMock(HttpCalloutMock.class, mock);

    try {
      MetadataRestService.getInstance()
        .deployZip(
          Blob.valueOf('fake zip bytes'),
          new MetadataRestService.DeployOptions()
        );
      Assert.fail(
        'Expected an exception when the response body cannot be parsed'
      );
    } catch (MetadataRestService.MetadataRestServiceException e) {
      Assert.areEqual(
        'not valid json',
        e.getMessage(),
        'Expected the raw response body to be used as the exception message'
      );
    }
  }

  @IsTest
  static void testGetDeployStatusSendsExpectedRequestAndParsesResponse() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'Succeeded', true)
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    MetadataRestService.DeployRequestResult result = MetadataRestService.getInstance()
      .getDeployStatus(FAKE_ID, true);

    Assert.areEqual(1, mock.callCount);
    Assert.areEqual(FAKE_ID, result.id);
    Assert.areEqual('Succeeded', result.deployResult.status);

    HttpRequest sentRequest = mock.requests[0];
    Assert.areEqual('GET', sentRequest.getMethod());
    Assert.isTrue(
      sentRequest.getEndpoint()
        .contains(
          '/metadata/deployRequest/' + FAKE_ID + '?includeDetails=true'
        ),
      'Expected the deployment id and includeDetails flag to be reflected in the endpoint'
    );
  }

  @IsTest
  static void testGetDeployStatusThrowsOnUnparseableResponse() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(200, 'not valid json'));
    Test.setMock(HttpCalloutMock.class, mock);

    try {
      MetadataRestService.getInstance().getDeployStatus(FAKE_ID, false);
      Assert.fail(
        'Expected an exception when the response body cannot be parsed'
      );
    } catch (MetadataRestService.MetadataRestServiceException e) {
      Assert.areEqual('not valid json', e.getMessage());
    }
  }

  @IsTest
  static void testRequestUsesNamedCredentialWhenConfigured() {
    insert new DeclarativeLookupRollupSummaries__c(
      NamedCredentialForApi__c = 'MyNamedCred'
    );

    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'Succeeded', true)
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    MetadataRestService.getInstance().getDeployStatus(FAKE_ID, false);
    Test.stopTest();

    HttpRequest sentRequest = mock.requests[0];
    Assert.isTrue(
      sentRequest.getEndpoint().startsWith('callout:MyNamedCred'),
      'Expected the configured named credential to be used as the callout endpoint'
    );
    Assert.areEqual(
      'Bearer {!$Credential.OAuthToken}',
      sentRequest.getHeader('Authorization'),
      'Expected the named credential OAuth token merge field to be used instead of the session Id'
    );
  }

  @IsTest
  static void testDeployZipAsyncRunsDeployThenStatusCheckToCompletion() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    // 1st callout: the deploy POST kicked off by deployZip().
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'InProgress', false)
      )
    );
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'Succeeded', true)
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    Id jobId = MetadataRestService.getInstance()
      .deployZipAsync(
        Blob.valueOf('fake zip bytes'),
        new MetadataRestService.DeployOptions()
      );
    Test.stopTest();

    Assert.areEqual(
      2,
      mock.callCount,
      'Expected a deploy callout followed by a status-check callout'
    );
    AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :jobId];
    Assert.areEqual('Completed', job.Status);
  }

  @IsTest
  static void testDeployZipAsyncCatchesFailureWithoutFailingTheJob() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(makeJsonResponse(200, 'not valid json'));
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    Id jobId = MetadataRestService.getInstance()
      .deployZipAsync(
        Blob.valueOf('fake zip bytes'),
        new MetadataRestService.DeployOptions()
      );
    Test.stopTest();

    Assert.areEqual(
      1,
      mock.callCount,
      'Expected only the deploy callout; no status check once the deploy itself failed'
    );
    AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :jobId];
    Assert.areEqual(
      'Completed',
      job.Status,
      'Expected the queueable to swallow the deployment failure rather than fail the job'
    );
  }

  @IsTest
  static void testGetDeployStatusAsyncChecksStatusToCompletion() {
    HttpCalloutMockImpl mock = new HttpCalloutMockImpl();
    mock.responses.add(
      makeJsonResponse(
        200,
        makeDeployRequestResultJson(FAKE_ID, 'Succeeded', true)
      )
    );
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    Id jobId = MetadataRestService.getInstance()
      .getDeployStatusAsync(FAKE_ID, true);
    Test.stopTest();

    Assert.areEqual(1, mock.callCount);
    AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :jobId];
    Assert.areEqual('Completed', job.Status);
    Assert.isTrue(
      mock.requests[0].getEndpoint().contains('includeDetails=true'),
      'Expected the includeDetails flag to be passed through to the request'
    );
  }

  @IsTest
  static void testDeploymentZipBuilderAddForDeploymentValidatesArguments() {
    MetadataRestService.DeploymentZipBuilder builder = new MetadataRestService.DeploymentZipBuilder();
    List<MetadataRestService.DeploymentFile> files = new List<MetadataRestService.DeploymentFile>{
      new MetadataRestService.DeploymentFile(
        'classes/Foo.cls',
        'public class Foo {}'
      )
    };

    try {
      builder.addForDeployment(null, 'Foo', files);
      Assert.fail('Expected an exception for a blank mdtType');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('mdtType'));
    }

    try {
      builder.addForDeployment('ApexClass', '', files);
      Assert.fail('Expected an exception for a blank mdtName');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('mdtName'));
    }

    try {
      builder.addForDeployment(
        'ApexClass',
        'Foo',
        new List<MetadataRestService.DeploymentFile>()
      );
      Assert.fail('Expected an exception for an empty files list');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('files'));
    }
  }

  @IsTest
  static void testDeploymentZipBuilderIncludesPostDestructionManifest() {
    MetadataRestService.DeploymentZipBuilder builder = new MetadataRestService.DeploymentZipBuilder();
    builder.addForPostDestruction('ApexTrigger', 'OldTrigger');

    Blob zip = builder.buildZip();

    Set<String> entryNames = new Set<String>();
    Compression.ZipReader reader = new Compression.ZipReader(zip);
    for (Compression.ZipEntry entry : reader.getEntries()) {
      entryNames.add(entry.getName());
    }

    Assert.isTrue(
      entryNames.contains('destructiveChangesPost.xml'),
      'Expected a post-destruction manifest to be present'
    );
    Assert.isFalse(
      entryNames.contains('destructiveChangesPre.xml'),
      'Expected no pre-destruction manifest when nothing is scheduled for pre-destruction'
    );
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

  private class ThrowingCalloutMock implements HttpCalloutMock {
    public Integer callCount = 0;

    public HTTPResponse respond(HTTPRequest req) {
      callCount++;
      throw new System.CalloutException('Simulated network failure');
    }
  }
}
