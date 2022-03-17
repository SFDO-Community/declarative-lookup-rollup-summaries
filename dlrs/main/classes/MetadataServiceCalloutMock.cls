@isTest
public class MetadataServiceCalloutMock implements WebServiceMock {
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
    MetadataService.createMetadataResponse_element responseElement = new MetadataService.createMetadataResponse_element();
    MetadataService.SaveResult res = new MetadataService.SaveResult();
    res.success = true;
    res.fullName = 'myTestResult';
    responseElement.result = new List<MetadataService.SaveResult>{ res };

    response.put('response_x', responseElement);
  }
}
