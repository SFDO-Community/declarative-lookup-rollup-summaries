@IsTest
public with sharing class MLRSControllerTest {

    @IsTest
    public static void clone_on_id_parameter(){
        ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
        Pagereference expectedPage;
        Pagereference actualPage = Page.managelookuprollupsummaries;
        actualPage.getParameters().put('id', 'testID');
        Test.setCurrentPage(actualPage);
        
        Test.startTest();
        expectedPage = controller.cloneX();
        Test.stopTest();

        System.assertEquals('testID', expectedPage.getParameters().get('cloneID') , 'Test ID returns properly');
    }

    @IsTest
    public static void clone_on_developerName_parameter(){
        ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
        Pagereference expectedPage;
        Pagereference actualPage = Page.managelookuprollupsummaries;
        actualPage.getParameters().put('developerName', 'testID');
        Test.setCurrentPage(actualPage);

        controller.LookupRollupSummary = new LookupRollupSummary2__mdt();
        controller.LookupRollupSummary.id = 'testID';
        expectedPage = controller.cloneX();


       // System.debug(expectedPage);

        System.assertEquals('testID', expectedPage.getParameters().get('cloneID') , 'Test ID returns properly');
    }

    


}
