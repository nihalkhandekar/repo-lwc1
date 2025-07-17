public class BRS_BTPaymentMethodQueueable implements Queueable {
    public List<bt_stripe__Payment_Method__c> setOfValidPMs;
    
    public BRS_BTPaymentMethodQueueable(List<bt_stripe__Payment_Method__c> paymentMethods) {
        this.setOfValidPMs = paymentMethods;
    }

    public void execute(QueueableContext context) {
        if(!setOfValidPMs.isEmpty()) {
            update setOfValidPMs;
        }        
    }
}