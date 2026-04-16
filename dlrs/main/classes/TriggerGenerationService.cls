public with sharing class TriggerGenerationService {
  private static final Map<String, Map<String, String>> MDT_INFO = new Map<String, Map<String, String>>{
    'ApexClass' => new Map<String, String>{
      'folder' => 'classes',
      'fileSuffix' => 'cls'
    },
    'ApexTrigger' => new Map<String, String>{
      'folder' => 'triggers',
      'fileSuffix' => 'trigger'
    }
  };

  public static List<GeneratedCode> generateApexForRollup(
    RollupSummary summary
  ) {
    List<GeneratedCode> generatedCode = new List<GeneratedCode>();
    // generate Child Trigger and supporting Test Class
    generatedCode.addAll(
      generateCode(
        summary.ChildObject,
        summary.TestCode,
        summary.TestCodeSeeAllData
      )
    );

    // Does the parent object support merge?
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    SObjectType parentObjectType = gd.get(summary.ParentObject);
    if (parentObjectType.getDescribe().isMergeable()) {
      // generate Parent Trigger and supporting Test Class
      generatedCode.addAll(
        generateCode(
          summary.ParentObject,
          summary.TestCodeParent,
          summary.TestCodeSeeAllData
        )
      );
    }

    return generatedCode;
  }

  public static Blob getZipFromChangeSet(
    List<GeneratedCode> changesToDeploy,
    List<GeneratedCode> changesToDestroy
  ) {
    Compression.ZipWriter writer = new Compression.ZipWriter();

    String packageXml = getPackageXml(changesToDeploy, true);
    writer.addEntry('package.xml', Blob.valueOf(packageXml));
    if (changesToDestroy != null && !changesToDestroy.isEmpty()) {
      String destructiveChangesXml = getPackageXml(changesToDestroy, false);
      writer.addEntry(
        'destructiveChangesPost.xml',
        Blob.valueOf(destructiveChangesXml)
      );
    }

    for (GeneratedCode cde : changesToDeploy) {
      Map<String, String> mdtInfo = MDT_INFO.get(cde.mdtType);
      String apexXml = getMdtXmlContent(cde.mdtType, cde.apiVersion);
      writer.addEntry(
        mdtInfo.get('folder') +
          '/' +
          cde.assetName +
          '.' +
          mdtInfo.get('fileSuffix') +
          '-meta.xml',
        Blob.valueOf(apexXml)
      );
      writer.addEntry(
        mdtInfo.get('folder') +
          '/' +
          cde.assetName +
          '.' +
          mdtInfo.get('fileSuffix'),
        Blob.valueOf(cde.body)
      );
    }

    return writer.getArchive();
  }

  public static String getPackageXml(
    List<GeneratedCode> metadataToDeploy,
    Boolean includeVersion
  ) {
    Map<String, List<String>> itemsByType = new Map<String, List<String>>();
    for (GeneratedCode cde : metadataToDeploy) {
      if (!itemsByType.containsKey(cde.mdtType)) {
        itemsByType.put(cde.mdtType, new List<String>());
      }
      itemsByType.get(cde.mdtType).add(cde.assetName);
    }
    List<String> xmlTypes = new List<String>();
    for (String mdtType : itemsByType.keySet()) {
      List<String> members = new List<String>();
      for (String member : itemsByType.get(mdtType)) {
        members.add('<members>' + member + '</members>');
      }
      xmlTypes.add(
        '<types>' +
          String.join(members, '') +
          '<name>' +
          mdtType +
          '</name></types>'
      );
    }
    if (includeVersion == true) {
      return '<?xml version="1.0" encoding="UTF-8"?>' +
        '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
        String.join(xmlTypes, '') +
        '<version>' +
        MetadataRestService.retrieveBestApiVersion() +
        '</version>' +
        '</Package>';
    } else {
      return '<?xml version="1.0" encoding="UTF-8"?>' +
        '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
        String.join(xmlTypes, '') +
        '</Package>';
    }
  }

  private static List<GeneratedCode> generateCode(
    String sObjectName,
    String testMethodBody,
    Boolean testSeesAllData
  ) {
    String apiVersion = MetadataRestService.retrieveBestApiVersion();

    String expectedTriggerName = RollupSummaries.makeTriggerName(sObjectName);
    String triggerBody = generateTriggerBody(sObjectName, expectedTriggerName);

    GeneratedCode generatedTrigger = new GeneratedCode(
      sObjectName,
      'ApexTrigger',
      expectedTriggerName,
      apiVersion,
      triggerBody
    );

    Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector()
      .selectByName(new Set<String>{ expectedTriggerName });
    ApexTrigger triggerObj = apexTriggers.get(expectedTriggerName);
    if (triggerObj != null) {
      generatedTrigger.setExisting(triggerObj.Body, triggerObj.ApiVersion);
    }

    String expectedTestClassName = RollupSummaries.makeTriggerTestName(
      sObjectName
    );

    String generatedTestBody = generateTestClassBody(
      sobjectName,
      expectedTestClassName,
      testMethodBody,
      expectedTriggerName,
      testSeesAllData
    );

    GeneratedCode generatedTestCode = new GeneratedCode(
      sObjectName,
      'ApexClass',
      expectedTestClassName,
      apiVersion,
      generatedTestBody
    );

    Map<String, ApexClass> apexClasses = new ApexClassesSelector()
      .selectByName(new Set<String>{ expectedTestClassName });
    ApexClass testClassObj = apexClasses.get(expectedTestClassName);
    if (testClassObj != null) {
      generatedTestCode.setExisting(testClassObj.Body, testClassObj.ApiVersion);
    }

    return new List<GeneratedCode>{ generatedTrigger, generatedTestCode };
  }

  public class GeneratedCode {
    @AuraEnabled
    public String sObjectName;
    @AuraEnabled
    public String mdtType;
    @AuraEnabled
    public String assetName;
    @AuraEnabled
    public String apiVersion;
    @AuraEnabled
    public String assetXml;
    @AuraEnabled
    public String body;
    @AuraEnabled
    public String existingBody;
    @AuraEnabled
    public String existingApiVersion;

    public GeneratedCode() {
    }

    public GeneratedCode(
      String sObjectName,
      String mdtType,
      String assetName,
      String apiVersion,
      String body
    ) {
      this.sObjectName = sObjectName;
      this.mdtType = mdtType;
      this.assetName = assetName;
      this.apiVersion = apiVersion;
      this.body = body;
    }

    public void setXmlContent(String xmlBody) {
      this.assetXml = xmlBody;
    }

    public void setExisting(String body, Decimal apiVersion) {
      this.existingBody = body;
      this.existingApiVersion = apiVersion.toString();
    }
  }

  public static String generateTriggerBody(
    String sObjectName,
    String triggerName
  ) {
    // Namespace?
    String namespace = Utilities.namespace();
    // Deploy generated code
    return '/**\n' +
      ' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
      ' **/\n' +
      'trigger ' +
      triggerName +
      ' on ' +
      sObjectName +
      '\n' +
      '    (after delete, after insert, after undelete, after update)\n' +
      '{\n' +
      '    ' +
      (namespace.length() > 0 ? namespace + '.' : '') +
      'RollupService.triggerHandler(' +
      sObjectName +
      '.SObjectType);\n' +
      '}';
  }

  public static String generateTestClassBody(
    String sObjectName,
    String className,
    String methodBody,
    String triggerName,
    Boolean seesAllData
  ) {
    String testMethodBody = null;
    if (String.isNotBlank(methodBody)) {
      testMethodBody = methodBody;
    }
    // Deploy generated code
    return '/**\n' +
      ' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
      ' **/\n' +
      '@IsTest\n' +
      'private class ' +
      className +
      '\n' +
      '{\n' +
      // TODO: when non-beta, add support for "testFor" annotation
      '    @IsTest' +
      (seesAllData == true ? '(SeeAllData=true)' : '') +
      '\n    private static void testTrigger()\n' +
      '    {\n' +
      (testMethodBody ??
        ('        // Force the ' +
        triggerName +
        ' to be invoked, fails the test if org config or other Apex code prevents this.\n' +
        '        SObject obj = new ' +
        sObjectName +
        '();\n' +
        '        ' +
        Utilities.classPrefix() +
        'RollupService.testHandler(obj);\n') +
        '        Assert.isNotNull(obj.Id);') +
      '\n    }\n' +
      '}';
  }

  private static String getMdtXmlContent(String mdtType, String apiVersion) {
    return '<?xml version="1.0" encoding="UTF-8"?>' +
      '<' +
      mdtType +
      ' xmlns="http://soap.sforce.com/2006/04/metadata">' +
      '<apiVersion>' +
      apiVersion +
      '</apiVersion>' +
      '<status>Active</status>' +
      '</' +
      mdtType +
      '>';
  }
}
