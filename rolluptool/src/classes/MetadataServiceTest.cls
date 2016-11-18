/**
 * Copyright (c) 2012, FinancialForce.com, inc
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
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
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
 * This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
 *   You should follow the usual practices to cover your other code, as shown in the MetadataCreateJobTest.cls
 **/ 
@isTest  
private class MetadataServiceTest
{    
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            return;
        }
    }    
        
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {   
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
    }
        
    @IsTest
    private static void coverGeneratedCodeTypes()
    {              
        // Reference types
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.WorkflowRule();
        new MetadataService.RecordTypeTranslation();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.CodeCoverageWarning();
        new MetadataService.FlowApexPluginCall();
        new MetadataService.FlowInputValidationRule();
        new MetadataService.FlowFormula();
        new MetadataService.PasswordPolicies();
        new MetadataService.QueueSobject();
        new MetadataService.PicklistValueTranslation();
        new MetadataService.CustomDataType();
        new MetadataService.PrimaryTabComponents();
        new MetadataService.WorkflowEmailRecipient();
        new MetadataService.DescribeMetadataResult();
        new MetadataService.RecordType();
        new MetadataService.Scontrol();
        new MetadataService.DashboardComponent();
        new MetadataService.FilterItem();
        new MetadataService.Profile();
        new MetadataService.ReportFilter();
        new MetadataService.PermissionSetApexClassAccess();
        new MetadataService.LogInfo();
        new MetadataService.Layout();
        new MetadataService.WebLink();
        new MetadataService.WorkflowTaskTranslation();
        new MetadataService.FlowElement();
        new MetadataService.ObjectNameCaseValue();
        new MetadataService.FlowInputFieldAssignment();
        new MetadataService.CustomDataTypeTranslation();
        new MetadataService.DashboardComponentSection();
        new MetadataService.ReportTypeColumn();
        new MetadataService.CallOptions_element();
        new MetadataService.CustomFieldTranslation();
        new MetadataService.AnalyticSnapshot();
        new MetadataService.FlowRule();
        new MetadataService.FlowRecordUpdate();
        new MetadataService.CustomSite();
        new MetadataService.ReportBlockInfo();
        new MetadataService.describeMetadataResponse_element();
        new MetadataService.ScontrolTranslation();
        new MetadataService.DeployMessage();
        new MetadataService.FlowSubflowInputAssignment();
        new MetadataService.Group_x();
        new MetadataService.ReportColumn();
        new MetadataService.ReportType();
        new MetadataService.CustomPageWebLink();
        new MetadataService.CodeCoverageResult();
        new MetadataService.ApexComponent();
        new MetadataService.WorkflowKnowledgePublish();
        new MetadataService.NetworkAccess();
        new MetadataService.Workflow();
        new MetadataService.RecordTypePicklistValue();
        new MetadataService.describeMetadata_element();
        new MetadataService.DashboardFilterColumn();
        new MetadataService.FlowChoice();
        new MetadataService.ReportParam();
        new MetadataService.RoleOrTerritory();
        new MetadataService.FlowStep();
        new MetadataService.FlowApexPluginCallInputParameter();
        new MetadataService.WorkflowActionReference();
        new MetadataService.ProfileObjectPermissions();
        new MetadataService.Role();
        new MetadataService.RetrieveResult();
        new MetadataService.SecuritySettings();
        new MetadataService.WorkflowTimeTrigger();
        new MetadataService.retrieve_element();
        new MetadataService.DescribeMetadataObject();
        new MetadataService.DashboardFilterOption();
        new MetadataService.LayoutColumn();
        new MetadataService.WorkflowOutboundMessage();
        new MetadataService.RunTestSuccess();
        new MetadataService.Queue();
        new MetadataService.ListViewFilter();
        new MetadataService.CustomField();
        new MetadataService.WorkflowTask();
        new MetadataService.deployResponse_element();
        new MetadataService.DataCategory();
        new MetadataService.FlowOutputFieldAssignment();
        new MetadataService.EmailTemplate();
        new MetadataService.ReportAggregateReference();
        new MetadataService.ObjectUsage();
        new MetadataService.FileProperties();
        new MetadataService.CustomTabTranslation();
        new MetadataService.BusinessProcess();
        new MetadataService.Flow();
        new MetadataService.PermissionSet();
        new MetadataService.PermissionSetObjectPermissions();
        new MetadataService.ReportCrossFilter();
        new MetadataService.Report();
        new MetadataService.FlowSubflowOutputAssignment();
        new MetadataService.ListView();
        new MetadataService.FlowRecordCreate();
        new MetadataService.DashboardTableColumn();
        new MetadataService.AsyncResult();
        new MetadataService.ArticleTypeChannelDisplay();
        new MetadataService.checkRetrieveStatus_element();
        new MetadataService.ProfileLayoutAssignment();
        new MetadataService.ReportFolder();
        new MetadataService.FlowTextTemplate();
        new MetadataService.RelatedListItem();
        new MetadataService.FlowNode();
        new MetadataService.RetrieveRequest();
        new MetadataService.ListMetadataQuery();
        new MetadataService.FlowConnector();
        new MetadataService.CustomApplicationComponent();
        new MetadataService.FlowRecordLookup();
        new MetadataService.FieldSet();
        new MetadataService.ProfileApexClassAccess();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.CustomDataTypeComponentTranslation();
        new MetadataService.FlowRecordDelete();
        new MetadataService.FlowDecision();
        new MetadataService.ReportTypeSectionTranslation();
        new MetadataService.IpRange();
        new MetadataService.FlowApexPluginCallOutputParameter();
        new MetadataService.ReportBucketField();
        new MetadataService.CustomLabel();
        new MetadataService.Attachment();
        new MetadataService.SharingRules();
        new MetadataService.CustomConsoleComponents();
        new MetadataService.Portal();
        new MetadataService.DomainWhitelist();
        new MetadataService.ChartSummary();
        new MetadataService.RunTestFailure();
        new MetadataService.Territory();
        new MetadataService.SharedTo();
        new MetadataService.FlowRecordFilter();
        new MetadataService.SubtabComponents();
        new MetadataService.FlowScreen();
        new MetadataService.WorkflowAlert();
        new MetadataService.Picklist();
        new MetadataService.ReportLayoutSection();
        new MetadataService.SummaryLayoutItem();
        new MetadataService.LayoutSection();
        new MetadataService.ReportTimeFrameFilter();
        new MetadataService.LayoutSectionTranslation();
        new MetadataService.DataCategoryGroup();
        new MetadataService.listMetadata_element();
        new MetadataService.ValidationRule();
        new MetadataService.WorkspaceMapping();
        new MetadataService.MetadataWithContent();
        new MetadataService.ValidationRuleTranslation();
        new MetadataService.Metadata();
        new MetadataService.ReportBucketFieldValue();
        new MetadataService.HomePageLayout();
        new MetadataService.FlowSubflow();
        new MetadataService.FlowScreenField();
        new MetadataService.SiteWebAddress();
        new MetadataService.RetrieveMessage();
        new MetadataService.Dashboard();
        new MetadataService.EmailFolder();
        new MetadataService.SessionHeader_element();
        new MetadataService.SummaryLayout();
        new MetadataService.FlowCondition();
        new MetadataService.DeployOptions();
        new MetadataService.FlowAssignment();
        new MetadataService.ProfileApplicationVisibility();
        new MetadataService.CustomApplicationComponents();
        new MetadataService.FlowElementReferenceOrValue();
        new MetadataService.EntitlementTemplate();
        new MetadataService.ProfileTabVisibility();
        new MetadataService.ActionOverride();
        new MetadataService.WorkspaceMappings();
        new MetadataService.WorkflowAction();
        new MetadataService.DashboardFolder();
        new MetadataService.PermissionSetApexPageAccess();
        new MetadataService.LayoutTranslation();
        new MetadataService.CustomObject();
        new MetadataService.Translations();
        new MetadataService.ApexTrigger();
        new MetadataService.ReportTypeTranslation();
        new MetadataService.FlowAssignmentItem();
        new MetadataService.CustomApplicationTranslation();
        new MetadataService.CustomLabels();
        new MetadataService.PackageTypeMembers();
        new MetadataService.PicklistValue();
        new MetadataService.RemoteSiteSetting();
        new MetadataService.deploy_element();
        new MetadataService.retrieveResponse_element();
        new MetadataService.ArticleTypeTemplate();
        new MetadataService.ReportGrouping();
        new MetadataService.PermissionSetFieldPermissions();
        new MetadataService.AnalyticSnapshotMapping();
        new MetadataService.SharingRecalculation();
        new MetadataService.ProfileLoginIpRange();
        new MetadataService.WebLinkTranslation();
        new MetadataService.ObjectRelationship();
        new MetadataService.ListPlacement();
        new MetadataService.SiteRedirectMapping();
        new MetadataService.WorkflowFieldUpdate();
        new MetadataService.LetterheadLine();
        new MetadataService.CustomTab();
        new MetadataService.FlowChoiceUserInput();
        new MetadataService.Letterhead();
        new MetadataService.ReportTypeColumnTranslation();
        new MetadataService.CustomPageWebLinkTranslation();
        new MetadataService.DocumentFolder();
        new MetadataService.FlowConstant();
        new MetadataService.ProfileRecordTypeVisibility();
        new MetadataService.PackageVersion();
        new MetadataService.CustomLabelTranslation();
        new MetadataService.ReportChart();
        new MetadataService.checkRetrieveStatusResponse_element();
        new MetadataService.ProfileFieldLevelSecurity();
        new MetadataService.SharingReason();
        new MetadataService.RunTestsResult();
        new MetadataService.PermissionSetUserPermission();
        new MetadataService.MiniLayout();
        new MetadataService.FlowVariable();
        new MetadataService.ProfileLoginHours();
        new MetadataService.DashboardFilter();
        new MetadataService.CodeLocation();
        new MetadataService.ReportBucketFieldSourceValue();
        new MetadataService.FieldSetItem();
        new MetadataService.ReportFilterItem();
        new MetadataService.FlowDynamicChoiceSet();
        new MetadataService.CustomDataTypeComponent();
        new MetadataService.CustomObjectTranslation();
        new MetadataService.CustomApplication();
        new MetadataService.ReportAggregate();
        new MetadataService.ApexClass();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.Package_x();
        new MetadataService.SessionSettings();
        new MetadataService.Document();
        new MetadataService.Folder();
        new MetadataService.DeployResult();
        new MetadataService.LayoutItem();
        new MetadataService.ProfileApexPageAccess();
        new MetadataService.SharingReasonTranslation();
        new MetadataService.checkDeployStatusResponse_element();
        new MetadataService.ReportColorRange();
        new MetadataService.SearchLayouts();
        new MetadataService.LetterheadHeaderFooter();
        new MetadataService.HomePageComponent();
        new MetadataService.MobileSettings();
        new MetadataService.EscalationRules();
        new MetadataService.KnowledgeAnswerSettings();
        new MetadataService.ExternalDataSource();
        new MetadataService.EntitlementProcess();
        new MetadataService.IdeasSettings();
        new MetadataService.Country();
        new MetadataService.ReputationLevels();
        new MetadataService.KnowledgeSitesSettings();
        new MetadataService.AddressSettings();
        new MetadataService.ProfileExternalDataSourceAccess();
        new MetadataService.CallCenterItem();
        new MetadataService.CallCenter();
        new MetadataService.PermissionSetExternalDataSourceAccess();
        new MetadataService.PermissionSetTabSetting();
        new MetadataService.AuthProvider();
        new MetadataService.EmailToCaseSettings();
        new MetadataService.EscalationAction();
        new MetadataService.State();
        new MetadataService.AssignmentRule();
        new MetadataService.AutoResponseRule();
        new MetadataService.CaseSettings();
        new MetadataService.ChatterAnswersSettings();
        new MetadataService.CountriesAndStates();
        new MetadataService.SFDCMobileSettings();
        new MetadataService.EntitlementProcessMilestoneItem();
        new MetadataService.TouchMobileSettings();
        new MetadataService.AssignmentRules();
        new MetadataService.ContractSettings();
        new MetadataService.KnowledgeCaseSettings();
        new MetadataService.ChatterAnswersReputationLevel();
        new MetadataService.KnowledgeSettings();
        new MetadataService.Community();
        new MetadataService.AutoResponseRules();
        new MetadataService.EmailToCaseRoutingAddress();
        new MetadataService.RuleEntry();
        new MetadataService.EntitlementSettings();
        new MetadataService.ApexPage();
        new MetadataService.WorkflowSend();
        new MetadataService.ChatterMobileSettings();
        new MetadataService.CallCenterSection();
        new MetadataService.EntitlementProcessMilestoneTimeTrigger();
        new MetadataService.StaticResource();
        new MetadataService.MilestoneType();
        new MetadataService.FiscalYearSettings();
        new MetadataService.CompanySettings();
        new MetadataService.WebToCaseSettings();
        new MetadataService.EscalationRule();
        new MetadataService.DashboardMobileSettings();
        new MetadataService.FieldOverride();
        new MetadataService.QuotasSettings();
        new MetadataService.Skill();
        new MetadataService.AgentConfigProfileAssignments();
        new MetadataService.LiveAgentSettings();
        new MetadataService.SkillAssignments();
        new MetadataService.ActivitiesSettings();
        new MetadataService.LiveAgentConfig();
        new MetadataService.ApprovalPageField();
        new MetadataService.QuickActionList();
        new MetadataService.LiveChatButtonDeployments();
        new MetadataService.InstalledPackage();
        new MetadataService.PushNotification();
        new MetadataService.LiveChatAgentConfig();
        new MetadataService.AdjustmentsSettings();                               
        new MetadataService.ForecastingSettings();                                
        new MetadataService.QuickActionListItem();           
        new MetadataService.Branding();          
        new MetadataService.QuickActionLayoutItem();                     
        new MetadataService.OpportunityListFieldsSelectedSettings();        
        new MetadataService.ApprovalStepRejectBehavior();
        new MetadataService.FolderShare();   
        new MetadataService.ApprovalEntryCriteria();                                
        new MetadataService.ProductSettings();                                
        new MetadataService.OpportunitySettings();              
        new MetadataService.LiveChatDeployment();                                
        new MetadataService.QuickActionLayoutColumn();           
        new MetadataService.GlobalQuickActionTranslation();      
        new MetadataService.ApprovalStepApprover();                                
        new MetadataService.QuoteSettings();         
        new MetadataService.LiveChatButton();                                
        new MetadataService.Network();
        new MetadataService.LiveChatDeploymentDomainWhitelist();
        new MetadataService.KnowledgeLanguageSettings();
        new MetadataService.Approver();
        new MetadataService.SamlSsoConfig();
        new MetadataService.ApprovalSubmitter();
        new MetadataService.KeyboardShortcuts();
        new MetadataService.ApprovalStep();
        new MetadataService.AgentConfigAssignments();
        new MetadataService.QuickAction();
        new MetadataService.DefaultShortcut();
        new MetadataService.ApprovalAction();
        new MetadataService.KnowledgeLanguage();
        new MetadataService.LiveChatButtonSkills();
        new MetadataService.SkillUserAssignments();
        new MetadataService.NextAutomatedApprover();
        new MetadataService.ApprovalProcess();
        new MetadataService.QuickActionLayout();
        new MetadataService.PushNotifications();
        new MetadataService.ForecastRangeSettings();
        new MetadataService.IdeaReputationLevel();
        new MetadataService.NetworkTabSet();
        new MetadataService.SkillProfileAssignments();
        new MetadataService.CustomShortcut();
        new MetadataService.PagesToOpen();
        new MetadataService.AgentConfigUserAssignments();
        new MetadataService.NetworkMemberGroup();
        new MetadataService.FindSimilarOppFilter();
        new MetadataService.QuickActionTranslation();               
        new MetadataService.WorkflowFlowActionParameter();
        new MetadataService.ConnectedAppOauthConfig();
        new MetadataService.FlowLoop();
        new MetadataService.renameMetadata_element();
        new MetadataService.ForecastingTypeSettings();
        new MetadataService.PermissionSetApplicationVisibility();
        new MetadataService.FeedLayout();
        new MetadataService.AppMenuItem();
        new MetadataService.deleteMetadataResponse_element();
        new MetadataService.ConnectedAppAttribute();
        new MetadataService.ReportChartComponentLayoutItem();
        new MetadataService.AppMenu();
        new MetadataService.ConnectedAppIpRange();
        new MetadataService.Error();
        new MetadataService.ComponentInstanceProperty();
        new MetadataService.BusinessHoursEntry();
        new MetadataService.RelatedContent();
        new MetadataService.SupervisorAgentConfigSkills();
        new MetadataService.ComponentInstance();
        new MetadataService.SidebarComponent();
        new MetadataService.Holiday();
        new MetadataService.SaveResult();
        new MetadataService.readMetadataResponse_element();
        new MetadataService.FlexiPageRegion();
        new MetadataService.deleteMetadata_element();
        new MetadataService.ConnectedAppMobileDetailConfig();
        new MetadataService.AccountSettings();
        new MetadataService.PermissionSetRecordTypeVisibility();
        new MetadataService.OrderSettings();
        new MetadataService.ProfileUserPermission();
        new MetadataService.LookupFilterTranslation();
        new MetadataService.WorkflowFlowAction();
        new MetadataService.ConnectedApp();
        new MetadataService.SiteDotCom();
        new MetadataService.createMetadataResponse_element();
        new MetadataService.updateMetadata_element();
        new MetadataService.LookupFilter();
        new MetadataService.updateMetadataResponse_element();
        new MetadataService.FlexiPage();
        new MetadataService.ConnectedAppSamlConfig();
        new MetadataService.createMetadata_element();
        new MetadataService.FeedLayoutComponent();
        new MetadataService.PostTemplate();
        new MetadataService.RelatedContentItem();
        new MetadataService.readMetadata_element();
        new MetadataService.ReadWorkflowRuleResult();
        new MetadataService.readWorkflowRuleResponse_element();
        new MetadataService.ReadSamlSsoConfigResult();
        new MetadataService.readSamlSsoConfigResponse_element();
        new MetadataService.ReadCustomLabelResult();
        new MetadataService.readCustomLabelResponse_element();
        new MetadataService.ReadBusinessHoursEntryResult();
        new MetadataService.readBusinessHoursEntryResponse_element();
        new MetadataService.ReadMobileSettingsResult();
        new MetadataService.readMobileSettingsResponse_element();
        new MetadataService.ReadChatterAnswersSettingsResult();
        new MetadataService.readChatterAnswersSettingsResponse_element();
        new MetadataService.ReadSharingRulesResult();
        new MetadataService.readSharingRulesResponse_element();
        new MetadataService.ReadPortalResult();
        new MetadataService.readPortalResponse_element();
        new MetadataService.ReadSkillResult();
        new MetadataService.readSkillResponse_element();
        new MetadataService.ReadEscalationRulesResult();
        new MetadataService.readEscalationRulesResponse_element();
        new MetadataService.ReadCustomDataTypeResult();
        new MetadataService.readCustomDataTypeResponse_element();
        new MetadataService.ReadExternalDataSourceResult();
        new MetadataService.readExternalDataSourceResponse_element();
        new MetadataService.ReadEntitlementProcessResult();
        new MetadataService.readEntitlementProcessResponse_element();
        new MetadataService.ReadRecordTypeResult();
        new MetadataService.readRecordTypeResponse_element();
        new MetadataService.ReadScontrolResult();
        new MetadataService.readScontrolResponse_element();
        new MetadataService.ReadDataCategoryGroupResult();
        new MetadataService.readDataCategoryGroupResponse_element();
        new MetadataService.ReadValidationRuleResult();
        new MetadataService.readValidationRuleResponse_element();
        new MetadataService.ReadProfileResult();
        new MetadataService.readProfileResponse_element();
        new MetadataService.ReadIdeasSettingsResult();
        new MetadataService.readIdeasSettingsResponse_element();
        new MetadataService.ReadConnectedAppResult();
        new MetadataService.readConnectedAppResponse_element();
        new MetadataService.ReadApexPageResult();
        new MetadataService.readApexPageResponse_element();
        new MetadataService.ReadProductSettingsResult();
        new MetadataService.readProductSettingsResponse_element();
        new MetadataService.ReadLiveAgentSettingsResult();
        new MetadataService.readLiveAgentSettingsResponse_element();
        new MetadataService.ReadOpportunitySettingsResult();
        new MetadataService.readOpportunitySettingsResponse_element();
        new MetadataService.ReadLiveChatDeploymentResult();
        new MetadataService.readLiveChatDeploymentResponse_element();
        new MetadataService.ReadActivitiesSettingsResult();
        new MetadataService.readActivitiesSettingsResponse_element();
        new MetadataService.ReadLayoutResult();
        new MetadataService.readLayoutResponse_element();
        new MetadataService.ReadWebLinkResult();
        new MetadataService.readWebLinkResponse_element();
        new MetadataService.ReadSiteDotComResult();
        new MetadataService.readSiteDotComResponse_element();
        new MetadataService.ReadCompanySettingsResult();
        new MetadataService.readCompanySettingsResponse_element();
        new MetadataService.ReadHomePageLayoutResult();
        new MetadataService.readHomePageLayoutResponse_element();
        new MetadataService.ReadDashboardResult();
        new MetadataService.readDashboardResponse_element();
        new MetadataService.ReadAssignmentRulesResult();
        new MetadataService.readAssignmentRulesResponse_element();
        new MetadataService.ReadAnalyticSnapshotResult();
        new MetadataService.readAnalyticSnapshotResponse_element();
        new MetadataService.ReadEscalationRuleResult();
        new MetadataService.readEscalationRuleResponse_element();
        new MetadataService.ReadCustomSiteResult();
        new MetadataService.readCustomSiteResponse_element();
        new MetadataService.ReadGroupResult();
        new MetadataService.readGroupResponse_element();
        new MetadataService.ReadReportTypeResult();
        new MetadataService.readReportTypeResponse_element();
        new MetadataService.ReadQuickActionResult();
        new MetadataService.readQuickActionResponse_element();
        new MetadataService.ReadCustomPageWebLinkResult();
        new MetadataService.readCustomPageWebLinkResponse_element();
        new MetadataService.ReadApexComponentResult();
        new MetadataService.readApexComponentResponse_element();
        new MetadataService.ReadEntitlementTemplateResult();
        new MetadataService.readEntitlementTemplateResponse_element();
        new MetadataService.ReadFlexiPageResult();
        new MetadataService.readFlexiPageResponse_element();
        new MetadataService.ReadWorkflowResult();
        new MetadataService.readWorkflowResponse_element();
        new MetadataService.ReadWorkflowActionResult();
        new MetadataService.readWorkflowActionResponse_element();
        new MetadataService.ReadAddressSettingsResult();
        new MetadataService.readAddressSettingsResponse_element();
        new MetadataService.ReadContractSettingsResult();
        new MetadataService.readContractSettingsResponse_element();
        new MetadataService.ReadCustomObjectResult();
        new MetadataService.readCustomObjectResponse_element();
        new MetadataService.ReadTranslationsResult();
        new MetadataService.readTranslationsResponse_element();
        new MetadataService.ReadRoleOrTerritoryResult();
        new MetadataService.readRoleOrTerritoryResponse_element();
        new MetadataService.ReadApexTriggerResult();
        new MetadataService.readApexTriggerResponse_element();
        new MetadataService.ReadCustomLabelsResult();
        new MetadataService.readCustomLabelsResponse_element();
        new MetadataService.ReadSecuritySettingsResult();
        new MetadataService.readSecuritySettingsResponse_element();
        new MetadataService.ReadCallCenterResult();
        new MetadataService.readCallCenterResponse_element();
        new MetadataService.ReadPicklistValueResult();
        new MetadataService.readPicklistValueResponse_element();
        new MetadataService.ReadRemoteSiteSettingResult();
        new MetadataService.readRemoteSiteSettingResponse_element();
        new MetadataService.ReadQuoteSettingsResult();
        new MetadataService.readQuoteSettingsResponse_element();
        new MetadataService.ReadSynonymDictionaryResult();
        new MetadataService.readSynonymDictionaryResponse_element();
        new MetadataService.ReadPostTemplateResult();
        new MetadataService.readPostTemplateResponse_element();
        new MetadataService.ReadCustomTabResult();
        new MetadataService.readCustomTabResponse_element();
        new MetadataService.ReadLetterheadResult();
        new MetadataService.readLetterheadResponse_element();
        new MetadataService.ReadInstalledPackageResult();
        new MetadataService.readInstalledPackageResponse_element();
        new MetadataService.ReadQueueResult();
        new MetadataService.readQueueResponse_element();
        new MetadataService.ReadAuthProviderResult();
        new MetadataService.readAuthProviderResponse_element();
        new MetadataService.ReadEntitlementSettingsResult();
        new MetadataService.readEntitlementSettingsResponse_element();
        new MetadataService.ReadCustomFieldResult();
        new MetadataService.readCustomFieldResponse_element();
        new MetadataService.ReadStaticResourceResult();
        new MetadataService.readStaticResourceResponse_element();
        new MetadataService.ReadEmailTemplateResult();
        new MetadataService.readEmailTemplateResponse_element();
        new MetadataService.ReadSharingReasonResult();
        new MetadataService.readSharingReasonResponse_element();
        new MetadataService.ReadLiveChatButtonResult();
        new MetadataService.readLiveChatButtonResponse_element();
        new MetadataService.ReadNetworkResult();
        new MetadataService.readNetworkResponse_element();
        new MetadataService.ReadApprovalProcessResult();
        new MetadataService.readApprovalProcessResponse_element();
        new MetadataService.ReadMilestoneTypeResult();
        new MetadataService.readMilestoneTypeResponse_element();
        new MetadataService.ReadAssignmentRuleResult();
        new MetadataService.readAssignmentRuleResponse_element();
        new MetadataService.ReadCompactLayoutResult();
        new MetadataService.readCompactLayoutResponse_element();
        new MetadataService.ReadLiveChatAgentConfigResult();
        new MetadataService.readLiveChatAgentConfigResponse_element();
        new MetadataService.ReadAccountSettingsResult();
        new MetadataService.readAccountSettingsResponse_element();
        new MetadataService.ReadBusinessProcessResult();
        new MetadataService.readBusinessProcessResponse_element();
        new MetadataService.ReadFlowResult();
        new MetadataService.readFlowResponse_element();
        new MetadataService.ReadAutoResponseRuleResult();
        new MetadataService.readAutoResponseRuleResponse_element();
        new MetadataService.ReadPermissionSetResult();
        new MetadataService.readPermissionSetResponse_element();
        new MetadataService.ReadBusinessHoursSettingsResult();
        new MetadataService.readBusinessHoursSettingsResponse_element();
        new MetadataService.ReadForecastingSettingsResult();
        new MetadataService.readForecastingSettingsResponse_element();
        new MetadataService.ReadReportResult();
        new MetadataService.readReportResponse_element();
        new MetadataService.ReadAppMenuResult();
        new MetadataService.readAppMenuResponse_element();
        new MetadataService.ReadListViewResult();
        new MetadataService.readListViewResponse_element();
        new MetadataService.ReadOrderSettingsResult();
        new MetadataService.readOrderSettingsResponse_element();
        new MetadataService.ReadCustomObjectTranslationResult();
        new MetadataService.readCustomObjectTranslationResponse_element();
        new MetadataService.ReadCustomApplicationResult();
        new MetadataService.readCustomApplicationResponse_element();
        new MetadataService.ReadKnowledgeSettingsResult();
        new MetadataService.readKnowledgeSettingsResponse_element();
        new MetadataService.ReadCaseSettingsResult();
        new MetadataService.readCaseSettingsResponse_element();
        new MetadataService.ReadApexClassResult();
        new MetadataService.readApexClassResponse_element();
        new MetadataService.ReadPackageResult();
        new MetadataService.readPackageResponse_element();
        new MetadataService.ReadCommunityResult();
        new MetadataService.readCommunityResponse_element();
        new MetadataService.ReadDocumentResult();
        new MetadataService.readDocumentResponse_element();
        new MetadataService.ReadAutoResponseRulesResult();
        new MetadataService.readAutoResponseRulesResponse_element();
        new MetadataService.ReadFolderResult();
        new MetadataService.readFolderResponse_element();
        new MetadataService.ReadCustomApplicationComponentResult();
        new MetadataService.readCustomApplicationComponentResponse_element();
        new MetadataService.ReadFieldSetResult();
        new MetadataService.readFieldSetResponse_element();
        new MetadataService.ReadSharingSetResult();
        new MetadataService.readSharingSetResponse_element();
        new MetadataService.ReadHomePageComponentResult();
        new MetadataService.readHomePageComponentResponse_element();
        new MetadataService.ReadResult();
        new MetadataService.BusinessHoursSettings();
        new MetadataService.FeedLayoutFilter();
        new MetadataService.ReportHistoricalSelector();
        new MetadataService.ConnectedAppCanvasConfig();
        new MetadataService.DeployDetails();
        new MetadataService.ReportDataCategoryFilter();
        new MetadataService.SynonymGroup();
        new MetadataService.renameMetadataResponse_element();
        new MetadataService.cancelDeploy_element();
        new MetadataService.CancelDeployResult();
        new MetadataService.SynonymDictionary();
        new MetadataService.cancelDeployResponse_element();
        new MetadataService.CompactLayout();
        new MetadataService.AccessMapping();
        new MetadataService.Container();
        new MetadataService.DeleteResult();
        new MetadataService.SharingSet();
        new MetadataService.ReputationPointsRule();
        new MetadataService.FlowActionCallInputParameter();
        new MetadataService.CustomMetadata();
        new MetadataService.VisualizationPlugin();
        new MetadataService.RelatedList();
        new MetadataService.FlowActionCallOutputParameter();
        new MetadataService.FlowActionCall();
        new MetadataService.CustomPermission();
        new MetadataService.ReputationLevelDefinitions();
        new MetadataService.PermissionSetCustomPermissions();
        new MetadataService.upsertMetadata_element();
        new MetadataService.ProfileCustomPermissions();
        new MetadataService.AgentConfigButtons();
        new MetadataService.AgentConfigSkills();
        new MetadataService.upsertMetadataResponse_element();
        new MetadataService.ReputationLevel();
        new MetadataService.ReadWorkflowAlertResult();
        new MetadataService.readWorkflowAlertResponse_element();
        new MetadataService.ReadCustomPermissionResult();
        new MetadataService.readCustomPermissionResponse_element();
        new MetadataService.ReadSiteDotComResult();
        new MetadataService.ReadEmailFolderResult();
        new MetadataService.readEmailFolderResponse_element();
        new MetadataService.ReadCustomMetadataResult();
        new MetadataService.readCustomMetadataResponse_element();
        new MetadataService.ReadAnalyticSnapshotResult();
        new MetadataService.readAnalyticSnapshotResponse_element();
        new MetadataService.ReadVisualizationPluginResult();
        new MetadataService.readVisualizationPluginResponse_element();
        new MetadataService.ReadEscalationRuleResult();
        new MetadataService.ReadMarketingActionSettingsResult();
        new MetadataService.readMarketingActionSettingsResponse_element();
        new MetadataService.ReadWorkflowKnowledgePublishResult();
        new MetadataService.readWorkflowKnowledgePublishResponse_element();
        new MetadataService.ReadDashboardFolderResult();
        new MetadataService.readDashboardFolderResponse_element();
        new MetadataService.ReadWorkflowSendResult();
        new MetadataService.readWorkflowSendResponse_element();
        new MetadataService.ReadWorkflowOutboundMessageResult();
        new MetadataService.readWorkflowOutboundMessageResponse_element();
        new MetadataService.ReadWorkflowFieldUpdateResult();
        new MetadataService.readWorkflowFieldUpdateResponse_element();
        new MetadataService.ReadDocumentFolderResult();
        new MetadataService.readDocumentFolderResponse_element();
        new MetadataService.ReadWorkflowTaskResult();
        new MetadataService.readWorkflowTaskResponse_element();
        new MetadataService.ReadNameSettingsResult();
        new MetadataService.readNameSettingsResponse_element();
        new MetadataService.ReadReportFolderResult();
        new MetadataService.readReportFolderResponse_element();
        new MetadataService.ReadCustomApplicationComponentResult();
        new MetadataService.NameSettings();
        new MetadataService.ReputationPointsRules();
        new MetadataService.FlowMetadataValue();
        new MetadataService.VisualizationResource();
        new MetadataService.MarketingActionSettings();
        new MetadataService.VisualizationType();
        new MetadataService.CustomMetadataValue();
        new MetadataService.HistoryRetentionPolicy();
        new MetadataService.UpsertResult();
        new MetaDataService.Territory2RuleAssociation();
        new MetadataService.ManagedTopics();
        new MetaDataService.XOrgHub();
        new MetaDataService.FlowWaitEventInputParameter();
        new MetadataService.ManagedTopic();
        new MetadataService.Territory2RuleItem();
        new MetadataService.DataPipeline();
        new MetadataService.UiPlugin();
        new MetadataService.Territory2Rule();
        new MetaDataService.XOrgHubSharedObject();
        new MetadataService.Territory2Type();
        new MetadataService.CorsWhitelistOrigin();
        new MetadataService.StandardFieldTranslation();
        new MetadataService.Territory2Model();
        new MetadataService.PersonListSettings();
        new MetadataService.ChannelLayoutItem();
        new MetadataService.FlowWait();
        new MetadataService.Territory2Settings();
        new MetadataService.FieldValue();
        new MetadataService.ChannelLayout();
        new MetadataService.ReadXOrgHubResult();
        new MetadataService.readXOrgHubResponse_element();
        new MetadataService.ReadAuraDefinitionBundleResult();
        new MetadataService.readAuraDefinitionBundleResponse_element();
        new MetadataService.ReadTerritory2SettingsResult();
        new MetadataService.readTerritory2SettingsResponse_element();
        new MetadataService.ReadTerritory2TypeResult();
        new MetadataService.readTerritory2TypeResponse_element();
        new MetadataService.ReadQuoteSettingsResult();
        new MetadataService.readQuoteSettingsResponse_element();
        new MetadataService.ReadCorsWhitelistOriginResult();
        new MetadataService.readCorsWhitelistOriginResponse_element();
        new MetadataService.ReadManagedTopicsResult();
        new MetadataService.readManagedTopicsResponse_element();
        new MetadataService.ReadTerritory2Result();
        new MetadataService.readTerritory2Response_element();
        new MetadataService.ReadCommunityResult();
        new MetadataService.readCommunityResponse_element();
        new MetadataService.ReadDocumentResult();
        new MetadataService.readDocumentResponse_element();
        new MetadataService.ReadTerritory2ModelResult();
        new MetadataService.readTerritory2ModelResponse_element();
        new MetadataService.FlowWaitEventOutputParameter();
        new MetadataService.FlowWaitEvent();
        new MetadataService.CustomPermissionDependencyRequired();
        new MetadataService.ReputationBranding();
        new MetadataService.AuraDefinitionBundle();
        new MetadataService.FeedItemSettings();
        new MetadataService.FlowBaseElement();
        new MetadataService.Territory2();        
        new MetaDataService.deployRecentValidationResponse_element();
        new MetaDataService.SharingCriteriaRule();
        new MetaDataService.ActionLinkGroupTemplate();
        new MetaDataService.MatchingRule();
        new MetaDataService.describeValueType_element();
        new MetaDataService.LicensedCustomPermissions();
        new MetaDataService.MatchingRuleItem();
        new MetaDataService.MarketingResourceType();
        new MetaDataService.SharingBaseRule();
        new MetaDataService.MatchingRules();
        new MetaDataService.deployRecentValidation_element();
        new MetaDataService.ActionLinkTemplate();
        new MetaDataService.SharingTerritoryRule();
        new MetaDataService.PersonalJourneySettings();
        new MetaDataService.LicenseDefinition();
        new MetaDataService.AccountSharingRuleSettings();
        new MetaDataService.NamedCredential();
        new MetaDataService.DescribeValueTypeResult();
        new MetaDataService.ReadSharingTerritoryRuleResult();
        new MetaDataService.readSharingTerritoryRuleResponse_element();
        new MetadataService.ReadPersonalJourneySettingsResult();
        new MetaDataService.readPersonalJourneySettingsResponse_element();
        new MetaDataService.ReadMarketingResourceTypeResult();
        new MetaDataService.readMarketingResourceTypeResponse_element();
        new MetaDataService.ReadSharingCriteriaRuleResult();
        new MetaDataService.readSharingCriteriaRuleResponse_element();
        new MetaDataService.ReadLicenseDefinitionResult();
        new MetaDataService.readLicenseDefinitionResponse_element();
        new MetaDataService.ReadActionLinkGroupTemplateResult();
        new MetaDataService.readActionLinkGroupTemplateResponse_element();
        new MetaDataService.ReadNamedCredentialResult();
        new MetaDataService.readNamedCredentialResponse_element();
        new MetaDataService.ReadSharingOwnerRuleResult();
        new MetaDataService.readSharingOwnerRuleResponse_element();
        new MetaDataService.ReadSharingBaseRuleResult();
        new MetaDataService.readSharingBaseRuleResponse_element();
        new MetaDataService.ReadMatchingRulesResult();
        new MetaDataService.readMatchingRulesResponse_element();
        new MetaDataService.ReadMatchingRuleResult();
        new MetaDataService.readMatchingRuleResponse_element();
        new MetaDataService.SharingOwnerRule();
        new MetaDataService.PicklistEntry();
        new MetaDataService.ValueTypeField();        
    }
}