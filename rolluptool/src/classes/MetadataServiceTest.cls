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
			else if(request instanceof MetadataService.update_element)
				response.put('response_x', new MetadataService.updateResponse_element());
			else if(request instanceof MetadataService.listMetadata_element)
				response.put('response_x', new MetadataService.listMetadataResponse_element());
			else if(request instanceof MetadataService.checkStatus_element)
				response.put('response_x', new MetadataService.checkStatusResponse_element());
			else if(request instanceof MetadataService.create_element)
				response.put('response_x', new MetadataService.createResponse_element());
			else if(request instanceof MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof MetadataService.delete_element)
				response.put('response_x', new MetadataService.deleteResponse_element());
			else if(request instanceof MetadataService.describeMetadata_element)
				response.put('response_x', new MetadataService.describeMetadataResponse_element());
			else if(request instanceof MetadataService.deploy_element)
				response.put('response_x', new MetadataService.deployResponse_element());
			return;
		}
	}    
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.create(null);
        metaDataPort.deleteMetadata(null);
        metaDataPort.updateMetadata(null);		
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations()
    {    	
    	// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null);
        metaDataPort.updateMetadata(null);
        metaDataPort.listMetadata(null, null);
        metaDataPort.checkStatus(null);
        metaDataPort.describeMetadata(null);
        metaDataPort.checkRetrieveStatus(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null);
    }
        
	@IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.WorkflowRule();
        new MetadataService.AccountOwnerSharingRule();
        new MetadataService.RecordTypeTranslation();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.CodeCoverageWarning();
        new MetadataService.FlowApexPluginCall();
        new MetadataService.FlowInputValidationRule();
        new MetadataService.FlowFormula();
        new MetadataService.CustomObjectCriteriaBasedSharingRule();
        new MetadataService.PasswordPolicies();
        new MetadataService.QueueSobject();
        new MetadataService.CaseSharingRules();
        new MetadataService.PicklistValueTranslation();
        new MetadataService.OpportunityOwnerSharingRule();
        new MetadataService.ContactOwnerSharingRule();
        new MetadataService.CustomDataType();
        new MetadataService.PrimaryTabComponents();
        new MetadataService.WorkflowEmailRecipient();
        new MetadataService.DescribeMetadataResult();
        new MetadataService.RecordType();
        new MetadataService.Scontrol();
        new MetadataService.DashboardComponent();
        new MetadataService.ContactCriteriaBasedSharingRule();
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
        new MetadataService.CustomObjectOwnerSharingRule();
        new MetadataService.CustomFieldTranslation();
        new MetadataService.AnalyticSnapshot();
        new MetadataService.FlowRule();
        new MetadataService.FlowRecordUpdate();
        new MetadataService.CustomSite();
        new MetadataService.ReportBlockInfo();
        new MetadataService.describeMetadataResponse_element();
        new MetadataService.CaseOwnerSharingRule();
        new MetadataService.ScontrolTranslation();
        new MetadataService.DeployMessage();
        new MetadataService.FlowSubflowInputAssignment();
        new MetadataService.Group_x();
        new MetadataService.ReportColumn();
        new MetadataService.ReportType();
        new MetadataService.CustomPageWebLink();
        new MetadataService.CodeCoverageResult();
        new MetadataService.ApexComponent();
        new MetadataService.BaseSharingRule();
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
        new MetadataService.delete_element();
        new MetadataService.SecuritySettings();
        new MetadataService.WorkflowTimeTrigger();
        new MetadataService.CustomObjectSharingRules();
        new MetadataService.updateResponse_element();
        new MetadataService.retrieve_element();
        new MetadataService.create_element();
        new MetadataService.DescribeMetadataObject();
        new MetadataService.createResponse_element();
        new MetadataService.DashboardFilterOption();
        new MetadataService.checkStatus_element();
        new MetadataService.LayoutColumn();
        new MetadataService.WorkflowOutboundMessage();
        new MetadataService.RunTestSuccess();
        new MetadataService.Queue();
        new MetadataService.LeadSharingRules();
        new MetadataService.NamedFilter();
        new MetadataService.ListViewFilter();
        new MetadataService.CampaignOwnerSharingRule();
        new MetadataService.checkStatusResponse_element();
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
        new MetadataService.ContactSharingRules();
        new MetadataService.AccountTerritorySharingRules();
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
        new MetadataService.AccountCriteriaBasedSharingRule();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.CustomDataTypeComponentTranslation();
        new MetadataService.FlowRecordDelete();
        new MetadataService.FlowDecision();
        new MetadataService.ReportTypeSectionTranslation();
        new MetadataService.IpRange();
        new MetadataService.FlowApexPluginCallOutputParameter();
        new MetadataService.ReportBucketField();
        new MetadataService.CaseCriteriaBasedSharingRule();
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
        new MetadataService.NamedFilterTranslation();
        new MetadataService.WorkspaceMapping();
        new MetadataService.MetadataWithContent();
        new MetadataService.ValidationRuleTranslation();
        new MetadataService.AccountTerritorySharingRule();
        new MetadataService.Metadata();
        new MetadataService.ConsoleComponent();
        new MetadataService.ReportBucketFieldValue();
        new MetadataService.OpportunitySharingRules();
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
        new MetadataService.UpdateMetadata();
        new MetadataService.CustomApplicationComponents();
        new MetadataService.FlowElementReferenceOrValue();
        new MetadataService.EntitlementTemplate();
        new MetadataService.ProfileTabVisibility();
        new MetadataService.ActionOverride();
        new MetadataService.WorkspaceMappings();
        new MetadataService.WorkflowAction();
        new MetadataService.deleteResponse_element();
        new MetadataService.update_element();
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
        new MetadataService.LeadCriteriaBasedSharingRule();
        new MetadataService.SharingRecalculation();
        new MetadataService.ProfileLoginIpRange();
        new MetadataService.WebLinkTranslation();
        new MetadataService.ObjectRelationship();
        new MetadataService.ListPlacement();
        new MetadataService.SiteRedirectMapping();
        new MetadataService.OwnerSharingRule();
        new MetadataService.WorkflowFieldUpdate();
        new MetadataService.LetterheadLine();
        new MetadataService.OpportunityCriteriaBasedSharingRule();
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
        new MetadataService.LeadOwnerSharingRule();
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
        new MetadataService.CampaignSharingRules();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.Package_x();
        new MetadataService.SessionSettings();
        new MetadataService.Document();
        new MetadataService.Folder();
        new MetadataService.DeployResult();
        new MetadataService.CampaignCriteriaBasedSharingRule();
        new MetadataService.LayoutItem();
        new MetadataService.ProfileApexPageAccess();
        new MetadataService.SharingReasonTranslation();
        new MetadataService.checkDeployStatusResponse_element();
        new MetadataService.ReportColorRange();
        new MetadataService.SearchLayouts();
        new MetadataService.LetterheadHeaderFooter();
        new MetadataService.HomePageComponent();
        new MetadataService.AccountSharingRules();
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
        new MetadataService.CriteriaBasedSharingRule();
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
		new MetadataService.DataSourceSettings();
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
    }
}