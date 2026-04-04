/*
 * NOTE: DO NOT PACKAGE THIS TRIGGER
 *
 * Provide Callable interface for the packaged code to control unpackaged test fixtures
 */

global with sharing class DlrsTestContext implements Callable {
  public static Boolean OpportunityTestTriggerEnabled = true;

  public static Boolean AccountTestTriggerEnabled = true;

  public static Boolean DeleteParentRecord = false;

  global DlrsTestContext() {
  }

  global Object call(String action, Map<String, Object> args) {
    if (String.isBlank(action)) {
      throw new DlrsCallableException('action must not be blank');
    }
    switch on action {
      when 'setParam' {
        String paramName = String.valueOf(args.get('paramName'));
        if (String.isBlank(paramName)) {
          throw new DlrsCallableException(
            'paramName argument is required and must not be blank'
          );
        }
        Object paramVal = args.get('paramValue');
        switch on paramName {
          when 'OpportunityTestTriggerEnabled' {
            OpportunityTestTriggerEnabled = Boolean.valueOf(paramVal);
          }
          when 'AccountTestTriggerEnabled' {
            AccountTestTriggerEnabled = Boolean.valueOf(paramVal);
          }
          when 'DeleteParentRecord' {
            DeleteParentRecord = Boolean.valueOf(paramVal);
          }
          when else {
            throw new DlrsCallableException(
              'Unsupported paramName value:' + paramName
            );
          }
        }
      }
      when else {
        throw new DlrsCallableException('Unexpected action:' + action);
      }
    }
    return null;
  }

  public class DlrsCallableException extends Exception {
  }
}
