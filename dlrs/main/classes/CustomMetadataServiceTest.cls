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

@IsTest
private class CustomMetadataServiceTest {
  @IsTest
  static void testInitiateMetadataSave() {
    try {
      CustomMetadataService.initiateMetadataSave(
        new List<LookupRollupSummary2__mdt>{
          new LookupRollupSummary2__mdt(
            DeveloperName = 'TestRec',
            Label = 'Test Rec',
            Active__c = true,
            RowLimit__c = 100
          )
        }
      );
      Assert.fail('Expected to fail starting the deployment');
    } catch (System.AsyncException e) {
      Assert.areEqual(
        'Metadata cannot be deployed from within a test',
        e.getMessage()
      );
    }
  }

  @IsTest
  static void testDeleteMetadataAsync() {
    Test.startTest();
    Test.setMock(
      WebServiceMock.class,
      new MetadataServiceDeleteSuccessCalloutMock()
    );
    CustomMetadataService.deleteMetadataAsync(
      LookupRollupSummary2__mdt.getSObjectType(),
      new List<String>{ 'LookupRollupSummary2__mdt.Test123' }
    );
    Test.stopTest();
  }

  @IsTest
  static void testDeleteMetadataAsyncFailed() {
    Test.startTest();
    Test.setMock(
      WebServiceMock.class,
      new MetadataServiceDeleteFailureCalloutMock()
    );
    CustomMetadataService.deleteMetadataAsync(
      LookupRollupSummary2__mdt.getSObjectType(),
      new List<String>{ 'LookupRollupSummary2__mdt.Test123' }
    );
    Test.stopTest();
  }

  @IsTest
  static void testApexMdApiDeployCallback() {
    CustomMetadataService.ApexMdApiDeployCallback cb = new CustomMetadataService.ApexMdApiDeployCallback();
    Metadata.DeployResult result = new Metadata.DeployResult();
    result.status = Metadata.DeployStatus.Succeeded;
    Metadata.DeployMessage messageObj = new Metadata.DeployMessage();
    messageObj.changed = true;
    messageObj.success = true;
    messageObj.fullName = 'TestRec';
    messageObj.componentType = 'CustomMetadata';
    messageObj.fullName = 'LookupRollupSummary2__mdt.TestRec';
    Metadata.DeployDetails deployDetailsObj = new Metadata.DeployDetails();
    deployDetailsObj.componentSuccesses.add(messageObj);
    result.details = deployDetailsObj;
    Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

    // Invoke the callback's handleResult method.
    cb.handleResult(result, context);

    // expected Platform Event publishing DML
    Assert.areEqual(1, Limits.getDmlStatements());
    Assert.areEqual(1, Limits.getDmlRows());
  }

  public class MetadataServiceDeleteSuccessCalloutMock implements WebServiceMock {
    public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType
    ) {
      System.debug(request);
      MetadataService.deleteMetadataResponse_element responseElement = new MetadataService.deleteMetadataResponse_element();
      // MetadataService.createMetadataResponse_element responseElement = new MetadataService.createMetadataResponse_element();
      MetadataService.DeleteResult res = new MetadataService.DeleteResult();
      res.success = true;
      res.fullName = 'myTestResult';
      responseElement.result = new List<MetadataService.DeleteResult>{ res };

      response.put('response_x', responseElement);
    }
  }

  public class MetadataServiceDeleteFailureCalloutMock implements WebServiceMock {
    public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType
    ) {
      System.debug(request);
      MetadataService.deleteMetadataResponse_element responseElement = new MetadataService.deleteMetadataResponse_element();
      // MetadataService.createMetadataResponse_element responseElement = new MetadataService.createMetadataResponse_element();
      MetadataService.DeleteResult res = new MetadataService.DeleteResult();
      res.success = false;
      res.errors = new List<MetadataService.Error>();
      MetadataService.Error err = new MetadataService.Error();
      err.message = 'Test Error';
      err.statusCode = 'Error Code';
      err.fields = new List<String>{ 'Field__1', 'Field_2' };
      res.errors.add(err);
      res.fullName = 'myTestResult';
      responseElement.result = new List<MetadataService.DeleteResult>{ res };

      response.put('response_x', responseElement);
    }
  }
}
