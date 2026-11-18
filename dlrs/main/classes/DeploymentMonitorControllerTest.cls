@IsTest
private class DeploymentMonitorControllerTest {
  private static final Id FAKE_DEPLOYMENT_ID = '0Af000000004CVY';

  @IsTest
  static void testRequestDeploymentStatusCheckSuccess() {
    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    DeploymentMonitorController.requestDeploymentStatusCheck(
      FAKE_DEPLOYMENT_ID
    );

    Assert.areEqual(
      1,
      stub.getDeployStatusAsyncCallCount,
      'Expected exactly one call to getDeployStatusAsync()'
    );
    Assert.areEqual(
      FAKE_DEPLOYMENT_ID,
      stub.lastDeploymentId,
      'Expected the deployment id to be passed through unchanged'
    );
    Assert.areEqual(
      true,
      stub.lastIncludeDetails,
      'Expected requestDeploymentStatusCheck() to always request details'
    );
  }

  @IsTest
  static void testRequestDeploymentStatusCheckWrapsExceptionAsAuraHandled() {
    MetadataRestServiceStub stub = new MetadataRestServiceStub();
    stub.exceptionToThrow = new MetadataRestService.MetadataRestServiceException(
      'Callout failed'
    );
    MetadataRestService.myInstance = (MetadataRestService) Test.createStub(
      MetadataRestService.class,
      stub
    );

    try {
      DeploymentMonitorController.requestDeploymentStatusCheck(
        FAKE_DEPLOYMENT_ID
      );
      Assert.fail(
        'Expected an AuraHandledException when getDeployStatusAsync() throws'
      );
    } catch (AuraHandledException e) {
      Assert.isNotNull(
        e.getMessage(),
        'Expected the underlying exception to be wrapped as an AuraHandledException'
      );
    }
    Assert.areEqual(
      1,
      stub.getDeployStatusAsyncCallCount,
      'Expected exactly one call attempt before the exception surfaced'
    );
  }

  private class MetadataRestServiceStub implements System.StubProvider {
    public Integer getDeployStatusAsyncCallCount = 0;
    public Id lastDeploymentId;
    public Boolean lastIncludeDetails;
    public Exception exceptionToThrow;

    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (stubbedMethodName == 'getDeployStatusAsync') {
        getDeployStatusAsyncCallCount++;
        lastDeploymentId = (Id) listOfArgs[0];
        lastIncludeDetails = (Boolean) listOfArgs[1];
        if (exceptionToThrow != null) {
          throw exceptionToThrow;
        }
        return null;
      }
      return null;
    }
  }
}
