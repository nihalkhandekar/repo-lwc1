public class AccountController {

    public List<Account> accounts { get; set; }
    public String filterField1 { get; set; }
    public String filterField2 { get; set; }
    public String filterField3 { get; set; }
    public String filterEmail { get; set; }

    // Constructor for querying based on filters
    public AccountController() {
        // Default query (no filters)
        String query = 'SELECT Id, Name, Field1__c, Field2__c, Field3__c, ' +
                       '(SELECT Email FROM Contacts ) FROM Account ';
        
        // Adding filter conditions dynamically based on input
        if (String.isNotBlank(filterField1)) {
            query += ' AND Field1__c = :filterField1';
        }
        if (String.isNotBlank(filterField2)) {
            query += ' AND Field2__c = :filterField2';
        }
        if (String.isNotBlank(filterField3)) {
            query += ' AND Field3__c = :filterField3';
        }
        if (String.isNotBlank(filterEmail)) {
            query += ' AND Id IN (SELECT AccountId FROM Contact WHERE Email = :filterEmail)';
        }
        
        // Execute the dynamic query and fetch results
        accounts = Database.query(query);
    }
}