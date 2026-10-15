@IsTest
private class TriggerGenerationServiceTest {
  private static final String FAKE_API_VERSION = '61.0';

  private static String oppTriggerName =
    Utilities.componentPrefix() + 'OpportunityTrigger';
  private static String oppTestName =
    Utilities.componentPrefix() + 'OpportunityTest';
  private static String accTriggerName =
    Utilities.componentPrefix() + 'AccountTrigger';
  private static String accTestName =
    Utilities.componentPrefix() + 'AccountTest';
  private static String contactTriggerName =
    Utilities.componentPrefix() + 'ContactTrigger';
  private static String contactTestName =
    Utilities.componentPrefix() + 'ContactTest';
  private static String leadTriggerName =
    Utilities.componentPrefix() + 'LeadTrigger';
  private static String leadTestName = Utilities.componentPrefix() + 'LeadTest';

  @IsTest
  static void testGenerateApexForRollupSameObjectSkipsParentCode() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;

    List<TriggerGenerationService.GeneratedCode> generated = TriggerGenerationService.generateApexForRollup(
      makeRollupSummary('Lead', 'Lead')
    );

    // Child == Parent, so only the child's trigger + test class are generated.
    Assert.areEqual(
      2,
      generated.size(),
      'Expected only child trigger + test class when child and parent are the same object'
    );

    TriggerGenerationService.GeneratedCode triggerCode = generated[0];
    Assert.areEqual('ApexTrigger', triggerCode.mdtType);
    Assert.areEqual(leadTriggerName, triggerCode.assetName);
    Assert.areEqual(FAKE_API_VERSION, triggerCode.apiVersion);
    Assert.isTrue(
      triggerCode.body.contains('trigger LeadTrigger on Lead'),
      'Expected the trigger body to declare a trigger on the child object'
    );
    Assert.areEqual(
      new List<String>{ leadTestName },
      triggerCode.testedBy,
      'Expected the trigger to record its generated test class as covering it'
    );

    TriggerGenerationService.GeneratedCode testCode = generated[1];
    Assert.areEqual('ApexClass', testCode.mdtType);
    Assert.areEqual(leadTestName, testCode.assetName);
    Assert.areEqual(FAKE_API_VERSION, testCode.apiVersion);
    Assert.isTrue(
      testCode.body.contains('private class ' + leadTestName),
      'Expected the generated test class body to declare the expected class name'
    );
  }

  @IsTest
  static void testGenerateApexForRollupGeneratesParentCodeWhenMergeableAndDifferent() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;

    // Opportunity doesn't support merge but that only matters for its own
    // trigger's "used by" calculation, not for whether it gets a trigger at
    // all. Account supports merge and differs from Opportunity, so its
    // trigger + test class should also be generated.
    List<TriggerGenerationService.GeneratedCode> generated = TriggerGenerationService.generateApexForRollup(
      makeRollupSummary('Opportunity', 'Account')
    );

    Assert.areEqual(
      4,
      generated.size(),
      'Expected child + parent trigger/test when the parent supports merge and differs from the child'
    );
    Assert.areEqual(oppTriggerName, generated[0].assetName);
    Assert.areEqual(oppTestName, generated[1].assetName);
    Assert.areEqual(accTriggerName, generated[2].assetName);
    Assert.areEqual(accTestName, generated[3].assetName);
  }

  @IsTest
  static void testGenerateApexForRollupSkipsParentCodeWhenParentNotMergeable() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;

    // Contact differs from the parent, but Opportunity (as parent here)
    // doesn't support merge, so no parent trigger/test should be generated.
    List<TriggerGenerationService.GeneratedCode> generated = TriggerGenerationService.generateApexForRollup(
      makeRollupSummary('Contact', 'Opportunity')
    );

    Assert.areEqual(
      2,
      generated.size(),
      'Expected only child code since the parent object does not support merge'
    );
    Assert.areEqual(contactTriggerName, generated[0].assetName);
    Assert.areEqual(contactTestName, generated[1].assetName);
  }

  @IsTest
  static void testGenerateApexForRollupHonorsCustomTestCode() {
    MetadataRestService.componentApiVersion = FAKE_API_VERSION;

    RollupSummary summary = makeRollupSummary('Lead', 'Lead');
    summary.TestCode = 'Assert.areEqual(1, 1);';
    summary.TestCodeSeeAllData = true;

    List<TriggerGenerationService.GeneratedCode> generated = TriggerGenerationService.generateApexForRollup(
      summary
    );

    String testBody = generated[1].body;
    Assert.isTrue(
      testBody.contains('@IsTest(SeeAllData=true)'),
      'Expected the SeeAllData annotation to be applied'
    );
    Assert.isTrue(
      testBody.contains('Assert.areEqual(1, 1);'),
      'Expected the custom test method body to be used verbatim'
    );
  }

  @IsTest
  static void testGenerateTriggerBody() {
    String body = TriggerGenerationService.generateTriggerBody(
      'Lead',
      'LeadTrigger'
    );

    Assert.isTrue(
      body.contains('trigger LeadTrigger on Lead'),
      'Expected the trigger declaration to reference the generated name and object'
    );
    Assert.isTrue(
      body.contains('RollupService.triggerHandler(Schema.Lead.SObjectType);'),
      'Expected the trigger body to delegate to RollupService'
    );
  }

  @IsTest
  static void testGenerateTestClassBodyDefaultTemplate() {
    String body = TriggerGenerationService.generateTestClassBody(
      'Lead',
      'LeadTest',
      null,
      'LeadTrigger',
      false
    );

    Assert.isTrue(
      body.contains('private class LeadTest'),
      'Expected the generated class to use the given class name'
    );
    Assert.isTrue(
      body.contains('RollupService.testHandler(obj);'),
      'Expected the default test body to invoke RollupService.testHandler()'
    );
    Assert.isFalse(
      body.contains('SeeAllData=true'),
      'Expected no SeeAllData annotation when seesAllData is false'
    );
  }

  @IsTest
  static void testGenerateTestClassBodyCustomMethodAndSeeAllData() {
    String body = TriggerGenerationService.generateTestClassBody(
      'Lead',
      'LeadTest',
      'Assert.areEqual(1, 1);',
      'LeadTrigger',
      true
    );

    Assert.isTrue(
      body.contains('@IsTest(SeeAllData=true)'),
      'Expected the SeeAllData annotation to be applied when requested'
    );
    Assert.isTrue(
      body.contains('Assert.areEqual(1, 1);'),
      'Expected the custom method body to be used verbatim'
    );
    Assert.isFalse(
      body.contains('RollupService.testHandler'),
      'Expected the custom method body to fully replace the default template'
    );
  }

  @IsTest
  static void testGetZipFromChangeSetBuildsDeployableZip() {
    TriggerGenerationService.GeneratedCode triggerCode = new TriggerGenerationService.GeneratedCode(
      'Lead',
      'ApexTrigger',
      'LeadTrigger',
      FAKE_API_VERSION,
      'trigger LeadTrigger on Lead (before insert) {}'
    );
    TriggerGenerationService.GeneratedCode testCode = new TriggerGenerationService.GeneratedCode(
      'Lead',
      'ApexClass',
      'LeadTest',
      FAKE_API_VERSION,
      '@IsTest private class LeadTest {}'
    );

    Blob zip = TriggerGenerationService.getZipFromChangeSet(
      new List<TriggerGenerationService.GeneratedCode>{ triggerCode, testCode },
      new List<TriggerGenerationService.GeneratedCode>()
    );

    Assert.isNotNull(zip, 'Expected a non-null zip archive to be built');

    Map<String, Blob> entries = extractZipEntries(zip);

    Assert.isTrue(
      entries.containsKey('package.xml'),
      'Expected a package.xml manifest to be present'
    );
    Assert.isTrue(
      entries.containsKey('triggers/LeadTrigger.trigger'),
      'Expected the trigger body file to be present'
    );
    Assert.isTrue(
      entries.containsKey('triggers/LeadTrigger.trigger-meta.xml'),
      'Expected the trigger metadata file to be present'
    );
    Assert.isTrue(
      entries.containsKey('classes/LeadTest.cls'),
      'Expected the test class body file to be present'
    );
    Assert.isTrue(
      entries.containsKey('classes/LeadTest.cls-meta.xml'),
      'Expected the test class metadata file to be present'
    );
    Assert.isFalse(
      entries.containsKey('destructiveChangesPre.xml'),
      'Expected no destructive changes manifest when nothing is being destroyed'
    );

    PackageManifest manifest = parsePackageManifest(
      entries.get('package.xml').toString()
    );
    Assert.areEqual(
      new Set<String>{ 'LeadTrigger' },
      manifest.membersByType.get('ApexTrigger'),
      'Expected package.xml to declare the generated trigger'
    );
    Assert.areEqual(
      new Set<String>{ 'LeadTest' },
      manifest.membersByType.get('ApexClass'),
      'Expected package.xml to declare the generated test class'
    );
    Assert.areEqual(
      MetadataRestService.FALLBACK_COMPONENT_API_VERSION,
      manifest.version,
      'Expected package.xml to declare a package version'
    );
  }

  @IsTest
  static void testGetZipFromChangeSetIncludesDestructiveChanges() {
    TriggerGenerationService.GeneratedCode codeToDestroy = new TriggerGenerationService.GeneratedCode(
      'Lead',
      'ApexTrigger',
      'OldLeadTrigger',
      FAKE_API_VERSION,
      null
    );

    Blob zip = TriggerGenerationService.getZipFromChangeSet(
      new List<TriggerGenerationService.GeneratedCode>(),
      new List<TriggerGenerationService.GeneratedCode>{ codeToDestroy }
    );

    Map<String, Blob> entries = extractZipEntries(zip);

    Assert.isTrue(
      entries.containsKey('destructiveChangesPre.xml'),
      'Expected a pre-destruction manifest to be present when destroying components'
    );
    Assert.isFalse(
      entries.containsKey('triggers/OldLeadTrigger.trigger'),
      'Expected no file body to be written for a component being destroyed'
    );

    PackageManifest manifest = parsePackageManifest(
      entries.get('destructiveChangesPre.xml').toString()
    );
    Assert.areEqual(
      new Set<String>{ 'OldLeadTrigger' },
      manifest.membersByType.get('ApexTrigger'),
      'Expected destructiveChangesPre.xml to declare the trigger being destroyed'
    );
    Assert.isNull(
      manifest.version,
      'Expected destructiveChangesPre.xml to have no <version>, unlike package.xml'
    );
  }

  private static Map<String, Blob> extractZipEntries(Blob zip) {
    Map<String, Blob> entries = new Map<String, Blob>();
    Compression.ZipReader reader = new Compression.ZipReader(zip);
    for (Compression.ZipEntry entry : reader.getEntries()) {
      entries.put(entry.getName(), reader.extract(entry));
    }
    return entries;
  }

  private static PackageManifest parsePackageManifest(String xml) {
    PackageManifest manifest = new PackageManifest();
    Dom.Document doc = new Dom.Document();
    doc.load(xml);
    for (Dom.XmlNode node : doc.getRootElement().getChildElements()) {
      if (node.getName() == 'types') {
        String mdtType;
        Set<String> members = new Set<String>();
        for (Dom.XmlNode typeChild : node.getChildElements()) {
          if (typeChild.getName() == 'name') {
            mdtType = typeChild.getText();
          } else if (typeChild.getName() == 'members') {
            members.add(typeChild.getText());
          }
        }
        manifest.membersByType.put(mdtType, members);
      } else if (node.getName() == 'version') {
        manifest.version = node.getText();
      }
    }
    return manifest;
  }

  private class PackageManifest {
    Map<String, Set<String>> membersByType = new Map<String, Set<String>>();
    String version;
  }

  private static RollupSummary makeRollupSummary(
    String childObject,
    String parentObject
  ) {
    return new RollupSummary(
      new LookupRollupSummary__c(
        ChildObject__c = childObject,
        ParentObject__c = parentObject,
        TestCodeSeeAllData__c = false
      )
    );
  }
}
