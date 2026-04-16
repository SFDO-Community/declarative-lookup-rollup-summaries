public with sharing class MetadataRestService {
  @TestVisible
  private static String FALLBACK_COMPONENT_API_VERSION = '66.0';

  @TestVisible
  private static String componentApiVersion;

  private static final String BOUNDARY_STRING = 'CONTENT_BOUNDARY_MARK';

  public MetadataRestService() {
  }

  /**
   * Call salesforce API to get current max supported API version
   */
  public static String retrieveBestApiVersion() {
    // use the cached value if it is set
    if (componentApiVersion != null) {
      return componentApiVersion;
    }

    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    // submit a Versions request
    req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/');
    // Salesforce REST API Dev Guide says this endpoint doesn't need authentication

    try {
      Http http = new Http();
      HTTPResponse res = http.send(req);
      if (res.getStatusCode() != 200) {
        return FALLBACK_COMPONENT_API_VERSION;
      }
      String body = res.getBody();
      List<Object> data = (List<Object>) JSON.deserializeUntyped(body);
      Decimal maxVersion = Decimal.valueOf(FALLBACK_COMPONENT_API_VERSION);
      for (Object obj : data) {
        Map<String, Object> apiV = (Map<String, Object>) obj;
        Decimal newV = Decimal.valueOf((String) apiV.get('version'));
        if (newV > maxVersion) {
          maxVersion = newV;
        }
      }
      componentApiVersion = String.valueOf(maxVersion);
      return componentApiVersion;
    } catch (Exception e) {
      System.debug(e);
      componentApiVersion = FALLBACK_COMPONENT_API_VERSION;
      return FALLBACK_COMPONENT_API_VERSION;
    }
  }

  /**
   * Deploy a zip file to Salesforce's Metadata REST API using configured deployment options
   *
   * @param zipFile the packaged zip file to be deployed
   * @param options the options used to configure the deployment behavior
   */
  public DeployRequestResult deployZip(Blob zipFile, DeployOptions options) {
    String path =
      '/services/data/v' +
      // uses known fixed API version, not the dynamic latest
      // we expect Salesforce will change the DeployResult shape over time and want to control when we get that
      FALLBACK_COMPONENT_API_VERSION +
      '/metadata/deployRequest';
    HttpRequest req = createRequest(path);
    req.setMethod('POST');
    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=' + BOUNDARY_STRING
    );

    req.setBodyAsBlob(getDeployRequestMultiPartBody(zipFile, options));
    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug('Status:' + res.getStatus());
    String body = res.getBody();
    System.debug(body);
    DeployRequestResult depRes = (DeployRequestResult) JSON.deserialize(
      body,
      DeployRequestResult.class
    );
    return depRes;
  }

  public DeployRequestResult getDeployStatus(Id deploymentId) {
    String path =
      '/services/data/v' +
      // uses known fixed API version, not the dynamic latest
      // we expect Salesforce will change the DeployResult shape over time and want to control when we get that
      FALLBACK_COMPONENT_API_VERSION +
      '/metadata/deployRequest/' +
      deploymentId;
    HttpRequest req = createRequest(path);
    req.setMethod('GET');

    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug('Status:' + res.getStatus());
    String body = res.getBody();
    System.debug(body);
    DeployRequestResult depRes = (DeployRequestResult) JSON.deserialize(
      body,
      DeployRequestResult.class
    );
    return depRes;
  }

  private HTTPRequest createRequest(String path) {
    HttpRequest req = new HttpRequest();
    String sessionId = UserInfo.getSessionId();
    String endpoint = URL.getOrgDomainUrl().toExternalForm();
    String namedCredApiName = DeclarativeLookupRollupSummaries__c.getInstance()
      .NamedCredentialForApi__c;
    if (String.isNotBlank(namedCredApiName)) {
      endpoint = String.format(
        'callout:{0}',
        new List<String>{ namedCredApiName }
      );
      sessionId = '{!$Credential.OAuthToken}';
    }
    if (String.isNotBlank(path)) {
      endpoint += path;
    }

    req.setEndpoint(endpoint);
    req.setHeader('Authorization', 'Bearer ' + sessionId);
    return req;
  }

  /**
   * Given a zip file and DeployOptions, build a binary multi-part payload for the HTTP Request
   *
   * @param zipFile the packaged zip file to be deployed
   * @param options the deploy options that should be serialized into the API request
   */
  private Blob getDeployRequestMultiPartBody(
    Blob zipFile,
    DeployOptions options
  ) {
    // pack the DeployOptions class in a container so we get the expected JSON output
    Map<String, Object> depOptsContainer = new Map<String, Object>{
      'deployOptions' => options
    };
    /* Build a multi-part HTTP request, the first part is JSON with the DeployOptions, the second part is the binary file
    important to understand how this works because we're not really sending strings over the wire.
    everything is normalized to Blob then those blobs are converted to HEX strings, we do this because then we can combine HEX string
    once that is all ready then we convert the unified HEX into a final Blob payload that has it all together
    alternate options juggle BASE64 encoding and have to mess with padding when combining encoded text. We get to skip all of that. */
    String multiPartOpeningText =
      // multipart structure is defined in RFC2046 section 5.1.1
      '--' +
      BOUNDARY_STRING +
      '\n' +
      'Content-Disposition: form-data; name="json"\n' +
      'Content-Type: application/json\n\n' +
      JSON.serialize(depOptsContainer) +
      '\n\n' +
      '--' +
      BOUNDARY_STRING +
      '\n' +
      'Content-Disposition: form-data; name="file"; filename="deploy.zip"\n' +
      'Content-Type: application/zip\n\n';

    // All of the encoding happens here to attempt to minimize our memory footprint.
    // We don't want to run out of heap space because we were holding three or four different copies of our data
    return EncodingUtil.convertFromHex(
      EncodingUtil.convertToHex(Blob.valueOf(multiPartOpeningText)) +
        EncodingUtil.convertToHex(zipFile) +
        EncodingUtil.convertToHex(Blob.valueOf('\n--' + BOUNDARY_STRING + '--'))
    );
  }

  public class DeployOptions {
    public Boolean allowMissingFiles;
    public Boolean checkOnly = false;
    public Boolean ignoreWarnings = false;
    public Boolean purgeOnDelete;
    public Boolean rollbackOnError = false;
    public List<String> runTests;
    public Boolean singlePackage = true;
    public String testLevel;
  }

  public class DeployResult {
    public Id id;
    public Id canceledBy;
    public String canceledByName;
    public Boolean checkOnly;
    public DateTime completedDate;
    public Id createdBy;
    public String createdByName;
    public DateTime createdDate;
    // public DeployDetails details;
    public Boolean done;
    public String errorMessage;
    public String errorStatusCode;
    public Boolean ignoreWarnings;
    public DateTime lastModifiedDate;
    public Integer numberComponentErrors;
    public Integer numberComponentsTotal;
    public Integer numberTestErrors;
    public Integer numberTestsCompleted;
    public Integer numberTestsTotal;
    public Boolean runTestsEnabled;
    public Boolean rollbackOnError;
    public DateTime startDate;
    public String stateDetail;
    public String status;
    public Boolean success;
  }

  // some day if/when we need it
  // public class DeployDetails {
  // }

  public class DeployRequestResult {
    public Id id;
    public DeployOptions deployOptions;
    public DeployResult deployResult;
  }
}
