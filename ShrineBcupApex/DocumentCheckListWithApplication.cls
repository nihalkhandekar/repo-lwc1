public class DocumentCheckListWithApplication {
    @AuraEnabled
    public DocumentChecklistItem docItem { get; set; }
    @AuraEnabled
    public IndividualApplication indivApp { get; set; }

    // Constructor to initialize the wrapper
    public DocumentCheckListWithApplication(DocumentChecklistItem docItem, IndividualApplication indivApp) {
        this.docItem = docItem;
        this.indivApp = indivApp;
    }

}