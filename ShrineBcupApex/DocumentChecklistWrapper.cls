public class DocumentChecklistWrapper {
    @AuraEnabled
    public DocumentChecklistItem docItem { get; set; }
    @AuraEnabled
    public IndividualApplication indivApp { get; set; }

    // Constructor to initialize the wrapper
    public DocumentChecklistWrapper(DocumentChecklistItem docItem, IndividualApplication indivApp) {
        this.docItem = docItem;
        this.indivApp = indivApp;
    }

    public DocumentChecklistWrapper(){
        
    }
}