/**
 * A service class around the platform Messaging class
 * Allowing us to capture send attempts and record them for test validation
 */
public with sharing class MessageService {
  @TestVisible
  static List<SentEmails> sentEmailList = new List<SentEmails>();

  public static Messaging.SendEmailResult[] sendEmail(
    Messaging.Email[] emails
  ) {
    return sendEmail(emails, true);
  }

  public static Messaging.SendEmailResult[] sendEmail(
    Messaging.Email[] emails,
    Boolean allOrNothing
  ) {
    if (Test.isRunningTest()) {
      sentEmailList.add(new SentEmails(emails, allOrNothing));
    }
    return Messaging.sendEmail(emails, allOrNothing);
  }

  @TestVisible
  private class SentEmails {
    public Messaging.Email[] emails;
    public Boolean allOrNothing;

    public SentEmails(Messaging.Email[] emails, Boolean allOrNothing) {
      this.emails = emails;
      this.allOrNothing = allOrNothing;
    }
  }
}
