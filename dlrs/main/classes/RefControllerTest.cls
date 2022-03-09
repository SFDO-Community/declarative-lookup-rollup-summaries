@IsTest
private class RefControllerTest {
    
    @IsTest
    private static void testCoverage() {
        RefController rf = new RefController();
        rf.getView();
        rf.redirect();
    }

}