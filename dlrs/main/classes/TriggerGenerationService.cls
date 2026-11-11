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
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    SObjectType childObjectType = gd.get(summary.ChildObject);
    List<GeneratedCode> generatedCode = new List<GeneratedCode>();
    // generate Child Trigger and supporting Test Class
    generatedCode.addAll(
      generateCode(
        summary.ChildObject,
        summary.TestCode,
        summary.TestCodeSeeAllData,
        childObjectType.getDescribe().isMergeable()
      )
    );

    // Does the parent object support merge?
    SObjectType parentObjectType = gd.get(summary.ParentObject);
    if (
      summary.ChildObject != summary.ParentObject &&
      parentObjectType.getDescribe().isMergeable()
    ) {
      // generate Parent Trigger and supporting Test Class
      generatedCode.addAll(
        generateCode(
          summary.ParentObject,
          summary.TestCodeParent,
          summary.TestCodeSeeAllData,
          parentObjectType.getDescribe().isMergeable()
        )
      );
    }

    return generatedCode;
  }

  public static Blob getZipFromChangeSet(
    List<GeneratedCode> changesToDeploy,
    List<GeneratedCode> changesToDestroy
  ) {
    MetadataRestService.DeploymentZipBuilder builder = new MetadataRestService.DeploymentZipBuilder();
    List<String> apexTestClasses = new List<String>();
    for (GeneratedCode gc : changesToDeploy) {
      List<MetadataRestService.DeploymentFile> files = new List<MetadataRestService.DeploymentFile>();

      Map<String, String> mdtInfo = MDT_INFO.get(gc.mdtType);
      String apexXml = getMdtXmlContent(gc.mdtType, gc.apiVersion);
      files.add(
        new MetadataRestService.DeploymentFile(
          String.format(
            '{0}/{1}.{2}-meta.xml',
            new List<String>{
              mdtInfo.get('folder'),
              gc.assetName,
              mdtInfo.get('fileSuffix')
            }
          ),
          apexXml
        )
      );
      files.add(
        new MetadataRestService.DeploymentFile(
          String.format(
            '{0}/{1}.{2}',
            new List<String>{
              mdtInfo.get('folder'),
              gc.assetName,
              mdtInfo.get('fileSuffix')
            }
          ),
          gc.body
        )
      );
      builder.addForDeployment(gc.mdtType, gc.assetName, files);
    }

    for (GeneratedCode gc : changesToDestroy) {
      builder.addForPreDestruction(gc.mdtType, gc.assetName);
    }

    return builder.buildZip();
  }

  private static List<GeneratedCode> generateCode(
    String sObjectName,
    String testMethodBody,
    Boolean testSeesAllData,
    Boolean supportsMerging
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
      generatedTrigger.rollupsUsingThisCode = countRollupsUsingTrigger(
        sObjectName,
        supportsMerging
      );
      generatedTrigger.setExisting(triggerObj.Body, triggerObj.ApiVersion);
    }

    String expectedTestClassName = RollupSummaries.makeTriggerTestName(
      sObjectName
    );
    generatedTrigger.addTestedBy(expectedTestClassName);

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

  /**
   * Get a list of active rollups, optionally including those where this object is the parent and not just the child
   */
  private static List<String> countRollupsUsingTrigger(
    String objectName,
    Boolean includeAsParent
  ) {
    RollupSummariesSelector selector = new RollupSummariesSelector(true, true);
    List<RollupSummaries.CalculationMode> calculationModes = new List<RollupSummaries.CalculationMode>{
      RollupSummaries.CalculationMode.Realtime,
      RollupSummaries.CalculationMode.Scheduled
    };
    Set<String> objNames = new Set<String>{ objectName };
    Set<String> rollupNames = new Set<String>();
    for (
      RollupSummary sum : selector.selectActiveByChildObject(
        calculationModes,
        objNames
      )
    ) {
      rollupNames.add(sum.UniqueName);
    }

    if (includeAsParent == true) {
      for (
        RollupSummary sum : selector.selectActiveByParentObject(
          calculationModes,
          objNames
        )
      ) {
        rollupNames.add(sum.UniqueName);
      }
    }
    return new List<String>(rollupNames);
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
    public List<String> rollupsUsingThisCode;
    @AuraEnabled
    public String existingBody;
    @AuraEnabled
    public String existingApiVersion;
    @AuraEnabled
    public List<String> testedBy = new List<String>();

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
      this.rollupsUsingThisCode = new List<String>();
    }

    public void addTestedBy(String testClassName) {
      testedBy.add(testClassName);
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
    // before insert is used to help the generated test code succeed more often
    return '''
    /**
     * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
     **/
    trigger ${triggerName} on ${sObjectName}
        (before insert, after delete, after insert, after undelete, after update)
    {
        ${namespacePrefix}RollupService.triggerHandler(Schema.${sObjectName}.SObjectType);
    }'''
      .template(
        new Map<String, String>{
          'triggerName' => triggerName,
          'sObjectName' => sObjectName,
          'namespacePrefix' => String.isNotBlank(namespace)
            ? namespace + '.'
            : ''
        }
      );
  }

  public static String generateTestClassBody(
    String sObjectName,
    String className,
    String methodBody,
    String triggerName,
    Boolean seesAllData
  ) {
    String namespace = Utilities.namespace();
    Map<String, String> templateData = new Map<String, String>{
      'className' => className,
      'triggerName' => triggerName,
      'seesAllDataString' => (seesAllData == true ? '(SeeAllData=true)' : ''),
      'sObjectName' => sObjectName,
      'namespacePrefix' => String.isNotBlank(namespace) ? namespace + '.' : ''
    };
    // default the testMethodBody, might be overwritten by configuration
    String testMethodBody = '''
      // Force the ${triggerName} to be invoked, fails the test if org config or other Apex code prevents this.
              SObject obj = new Schema.${sObjectName}();
              ${namespacePrefix}RollupService.testHandler(obj);
              Assert.isNotNull(obj);'''
      .template(templateData);
    if (String.isNotBlank(methodBody)) {
      testMethodBody = methodBody;
    }
    templateData.put('testMethodBody', testMethodBody);
    // Deploy generated code
    // TODO: when non-beta add "testFor" annotation
    return '''
    /**
     * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
     **/
    @IsTest
    private class ${className}
    {
        @IsTest${seesAllDataString}
        private static void testTrigger()
        {
            ${testMethodBody}
        }
    }'''
      .template(templateData);
  }

  private static String getMdtXmlContent(String mdtType, String apiVersion) {
    return '''
      <?xml version="1.0" encoding="UTF-8"?>
      <${mdtType} xmlns="http://soap.sforce.com/2006/04/metadata">
        <apiVersion>${apiVersion}</apiVersion>
        <status>Active</status>
      </${mdtType}>'''
      .template(
        new Map<String, String>{
          'mdtType' => mdtType,
          'apiVersion' => apiVersion
        }
      );
  }
}
