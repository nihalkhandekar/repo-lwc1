public with sharing class FinsysWorkOrderController {
  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getActivityData() {
    List<Map<String, Object>> activityDataList = new List<Map<String, Object>>();

    for (FinSys_Activity_SubActivity__mdt record : [
      SELECT Activity__c, Sub_Activity__c, Program_Code__c
      FROM FinSys_Activity_SubActivity__mdt WITH SECURITY_ENFORCED
    ]) {
      Map<String, Object> activityData = new Map<String, Object>();
      activityData.put('activity', record.Activity__c);
      activityData.put('subActivity', record.Sub_Activity__c);
      activityData.put('programCode', record.Program_Code__c);
      activityDataList.add(activityData);
    }

    return activityDataList;
  }

  @AuraEnabled(cacheable=true)
  public static Decimal getActivityFee(String activity, String subActivity) {
    FinSys_Activity_SubActivity_Fees__mdt feeMdt = [
        SELECT Fee__c
        FROM FinSys_Activity_SubActivity_Fees__mdt
        WHERE Activity__c = :activity
        AND Sub_Activity__c = :subActivity WITH SECURITY_ENFORCED
        LIMIT 1
    ];
    if(feeMdt != null)
      return feeMdt?.Fee__c;
    else
      return 0;
  }

  @AuraEnabled
  public static List<Contact> searchContacts(String searchName) {
    if (String.isBlank(searchName)) {
      return null; // Return null if the search string is invalid or less than 3 characters
    }

    // Get the Record Type ID for "FinSys Customers"
    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers' WITH SECURITY_ENFORCED
      LIMIT 1
    ]
    .Id;

    // Query matching contacts by name, filtering by the specific record type
    List<Contact> contacts = [
      SELECT
        Id,
        Salutation,
        FirstName,
        LastName,
        MiddleName,
        Suffix,
        Organization__c,
        MailingStreet,
        MailingAddress2__c,
        MailingCity,
        MailingState,
        MailingPostalCode,
        MailingCountry,
        Deliquent__c,
        Email,
        Phone,
        Customer_Account_Balance__c
      FROM Contact
      WHERE Name LIKE :('%' + searchName + '%') AND RecordTypeId = :recordTypeId WITH SECURITY_ENFORCED
    ];

    // Modify data if any contacts are found
    if (!contacts.isEmpty()) {
      for (Contact c : contacts) {
          // Example modification: Add "Customer" prefix to the first name
          if (c.FirstName != null) {
              c.FirstName = capitalizeFirstLetter(c.FirstName);
          }
      }
    }

    // Return null if no contacts found, otherwise return the list
    return contacts.isEmpty() ? null : contacts;
  }

  @AuraEnabled(cacheable=true)
  public static String getContactFirstName(String contactId) {
      try {
          // Convert String to Id type
          Id conId = Id.valueOf(contactId);

          Contact contact = [
              SELECT FirstName
              FROM Contact
              WHERE Id = :conId
              WITH SECURITY_ENFORCED
              LIMIT 1
          ];
          return contact.FirstName;
      } catch (IllegalArgumentException e) {
          throw new AuraHandledException('Invalid Contact ID format');
      } catch (Exception e) {
          throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
      }
  }

  private static String capitalizeFirstLetter(String inputString) {
    if (String.isBlank(inputString)) {
        return '';
    }
    String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
    return formattedString;
  }

  @AuraEnabled
  public static Map<String, Object> createWorkOrder(String workOrderDataJson) {
    try {
      // Deserialize JSON string to a Map for easy access
      Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(
        workOrderDataJson
      );

      System.debug('work order data is : ' + workOrderData);

      // Extract customer details from the input
      String selectedCustomerId = (String) workOrderData.get(
        'selectedCustomerId'
      );
      Date workOrderDate = Date.valueOf(
        String.valueOf(workOrderData.get('workOrderDate'))
      );
      String batchId;
      Contact customer;
      Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get(
        'customerDetails'
      );
      Map<String, Object> addressDetails = (Map<String, Object>) customerDetails.get(
        'address'
      );

      String recordId = (String) workOrderData.get('recordId');
      // if (!String.isBlank(recordId)) {
      //   // Extract and validate the default activity
      //   batchId = (String) workOrderData.get('defaultActivity');
      //   String defaultActivity = (String) workOrderData.get('defaultActivity');

      //   System.debug('defaultActivity is ' + defaultActivity);
      //   if (String.isBlank(defaultActivity)) {
      //     throw new AuraHandledException(
      //       'Default activity is required to create a work order.'
      //     );
      //   }

      //   // Query the Batch__c record for the default activity
      //   Batch__c batch = [
      //     SELECT Id, Name, Batch_Status__c, Batch_Name__c, Batch_Date__c
      //     FROM Batch__c
      //     WHERE Id = :defaultActivity AND Batch_Date__c = :workOrderDate
      //     LIMIT 1
      //   ];

      //   System.debug('found batch is ' + batch);

      //   // Validate the batch status
      //   if (batch.Batch_Status__c == 'Sealed') {
      //     throw new AuraHandledException(
      //       'Batch "' +
      //         batch.Name +
      //         '" for activity "' +
      //         batch.Batch_Name__c +
      //         '" is sealed. Please reopen the batch to proceed........'
      //     );
      //   }

      //   // Assign the batch ID to work order data
      //   workOrderData.put('defaultBatchId', batch.Id);

      //   // Determine whether to update or create a contact

      //   if (!String.isBlank(selectedCustomerId)) {
      //     // Use the provided JSON details to link an existing contact to the work order without fetching from the database
      //     customer = new Contact(
      //       Id = selectedCustomerId,
      //       FirstName = (String) customerDetails.get('firstName'),
      //       MiddleName = (String) customerDetails.get('middleInitial'),
      //       LastName = (String) customerDetails.get('lastName'),
      //       Organization__c = (String) customerDetails.get('organizationName'),
      //       Email = (String) customerDetails.get('emailAddress'),
      //       Phone = (String) customerDetails.get('phoneNumber'),
      //       MailingStreet = (String) addressDetails.get('street'),
      //       MailingAddress2__c = (String) addressDetails.get('address2'),
      //       MailingCity = (String) addressDetails.get('city'),
      //       MailingState = (String) addressDetails.get('state'),
      //       MailingPostalCode = (String) addressDetails.get('zipCode'),
      //       MailingCountry = (String) addressDetails.get('country')
      //     );
      //   }
      // }

        String defaultActivity = (String) workOrderData.get('defaultActivity');

        // Ensure defaultActivity is not blank
        if (String.isBlank(defaultActivity)) {
          throw new AuraHandledException(
            'Default activity is required to create a work order.'
          );
        }

        // Calculate the start and end of the day for the workOrderDate
        DateTime startOfDay = DateTime.newInstance(
          workOrderDate.year(),
          workOrderDate.month(),
          workOrderDate.day()
        );
        DateTime endOfDay = startOfDay.addDays(1).addSeconds(-1);

        // Query Batch__c to find an existing batch for the default activity created today
        Batch__c existingBatch;
        try {
          existingBatch = [
            SELECT Id, Name, Batch_Status__c, Batch_Name__c, Batch_Date__c
            FROM Batch__c
            WHERE
              Batch_Name__c = :defaultActivity
              AND Batch_Date__c = :workOrderDate WITH SECURITY_ENFORCED
            // AND CreatedDate >= :startOfDay
            // AND CreatedDate <= :endOfDay
            LIMIT 1
          ];
          System.debug('exicting batch data is ' + existingBatch);
        } catch (Exception e) {
          System.debug('Error querying Batch__c: ' + e.getMessage());
        }

        // Check if a batch exists
        if (existingBatch == null) {
          // Create a new batch for the activity if none exists
          Batch__c newBatch = new Batch__c();
          newBatch.Batch_Name__c = defaultActivity;
          newBatch.Name = defaultActivity;
          newBatch.Batch_Status__c = 'Open';
          newBatch.Batch_Date__c = workOrderDate;
          // insert newBatch;
          Database.insert(newBatch, AccessLevel.USER_MODE);


          System.debug(
            'Created new batch for activity: ' +
              defaultActivity +
              ' - ' +
              newBatch
          );

          // Assign new batch ID to work order data
          workOrderData.put('defaultBatchId of new created', newBatch.Id);
          batchId = newBatch.Id;
        } else {
          // Process the existing batch
          if (
            existingBatch.Batch_Status__c == 'Sealed' ||
            existingBatch.Batch_Status__c == 'Closed'
          ) {
            throw new AuraHandledException(
              'Batch "' +
                existingBatch.Name +
                '" for activity "' +
                existingBatch.Batch_Name__c +
                '" is sealed/closed. Please reopen the batch to proceed.'
            );
          }
          // Assign existing batch ID to work order data
          workOrderData.put('defaultBatchId', existingBatch.Id);
          batchId = existingBatch.Id;
        }

        System.debug('Default Batch ID: ' + batchId);

        if (!String.isBlank(selectedCustomerId)) {
          // Use the provided JSON details to link an existing contact to the work order without fetching from the database
          customer = new Contact(
            Id = selectedCustomerId,
            FirstName = (String) customerDetails.get('firstName'),
            MiddleName = (String) customerDetails.get('middleInitial'),
            LastName = (String) customerDetails.get('lastName'),
            Organization__c = (String) customerDetails.get('organizationName'),
            Email = (String) customerDetails.get('emailAddress'),
            Phone = (String) customerDetails.get('phoneNumber'),
            MailingStreet = (String) addressDetails.get('street'),
            MailingAddress2__c = (String) addressDetails.get('address2'),
            MailingCity = (String) addressDetails.get('city'),
            MailingState = (String) addressDetails.get('state'),
            MailingPostalCode = (String) addressDetails.get('zipCode'),
            MailingCountry = (String) addressDetails.get('country')
          );
        } else {
          // Create a new contact if no selectedCustomerId is provided
          customer = createNewContact(customerDetails, addressDetails);
        }


      // Get work order result map
      Map<String, Object> workOrderResult = createWorkOrderForCustomer(
        customer,
        workOrderData
      );

      // Extract ID and Sequence Number
      Id workOrderId = (Id) workOrderResult.get('id');
      // Date workOrderDate = Date.valueOf(String.valueOf(workOrderData.get('workOrderDate')));

      List<Object> rawTransactions = (List<Object>) workOrderData.get(
        'transactions'
      );
      List<Object> rawPayments = (List<Object>) workOrderData.get('payments');
      Boolean isSinglePayment = (Boolean) workOrderData.get('isSinglePayment');

      upsertTransactionFeeAndItem(
        rawTransactions,
        workOrderId,
        workOrderDate,
        batchId
      );

      // creatingActivityPayments(
      //   rawTransactions,
      //   rawPayments,
      //   workOrderId,
      //   batchId,
      //   isSinglePayment
      // );

      String transactionType = (String) workOrderData.get('transactionType');

      //processTransactionsAndPayments(rawTransactions, rawPayments, workOrderId, batchId, transactionType);

      uploadAndLinkDocuments(workOrderData, workOrderId);

      IndividualApplication insertedRecord = [
        SELECT Id, Sequence_Number__c
        FROM IndividualApplication
        WHERE Id = :workOrderId WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      workOrderResult.put('sequenceNumber', insertedRecord.Sequence_Number__c);

      return workOrderResult;
    } catch (AuraHandledException ahe) {
      throw ahe; // Rethrow handled exceptions with meaningful messages
    } catch (Exception e) {
      System.debug('Error in createWorkOrder: ' + e.getMessage());
      throw new AuraHandledException(
        'An unexpected error occurred: ' + e.getMessage()
      );
    }
  }

  // Helper method to create a new contact
  private static Contact createNewContact(
    Map<String, Object> customerDetails,
    Map<String, Object> addressDetails
  ) {
    Contact newCustomer = new Contact();
    newCustomer.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Contact' AND DeveloperName = 'FinSys_Customers' WITH SECURITY_ENFORCED
      LIMIT 1
    ]
    .Id;
    newCustomer.FirstName = (String) customerDetails.get('firstName');
    newCustomer.MiddleName = (String) customerDetails.get('middleInitial');
    newCustomer.LastName = (String) customerDetails.get('lastName');
    newCustomer.Organization__c = (String) customerDetails.get(
      'organizationName'
    );
    newCustomer.Email = (String) customerDetails.get('emailAddress');
    newCustomer.Phone = (String) customerDetails.get('phoneNumber');
    newCustomer.MailingStreet = (String) addressDetails.get('street');
    newCustomer.MailingAddress2__c = (String) addressDetails.get('address2');
    newCustomer.MailingCity = (String) addressDetails.get('city');
    newCustomer.MailingState = (String) addressDetails.get('state');
    newCustomer.MailingPostalCode = (String) addressDetails.get('zipCode');
    newCustomer.MailingCountry = (String) addressDetails.get('country');

    Database.insert(newCustomer, AccessLevel.USER_MODE);
    System.debug('Created new customer: ' + newCustomer);

    return newCustomer;
  }

  // Helper method to create a work order for a customer
  private static Map<String, Object> createWorkOrderForCustomer(
    Contact customer,
    Map<String, Object> workOrderData
  ) {
    // Check if a recordId exists in workOrderData to determine whether to update or insert
    String recordId = (String) workOrderData.get('recordId');

    Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');
    Map<String, Object> address = (Map<String, Object>) customerDetails.get('address');
    System.debug('customerDetails is : '+ customerDetails);
    System.debug('address is : '+ address);

    IndividualApplication individualAppWorkOrder;

    if (String.isNotBlank(recordId)) {
      // Fetch existing work order for update
      individualAppWorkOrder = [
        SELECT
          Id,
          Destination__c,
          LicenseTypeId,
          Category,
          Contact__c,
          AppliedDate,
          Last_Name__c,
          Middle_Name__c,
          First_Name__c,
          Address_Line_1__c,
          Suite_Apartment_Floor__c,
          City__c,
          State__c,
          Country__c,
          Zip_Code__c,
          Organization_Name__c,
          Email_Address__c,
          Sequence_Number__c,
          Cell_Phone_Number__c,
          Work_Order_Status__c,
          Work_Order_Comments__c
        FROM IndividualApplication
        WHERE Id = :recordId WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      System.debug('Updating existing work order: ' + individualAppWorkOrder);
    } else {
      // Create new work order
      individualAppWorkOrder = new IndividualApplication();
      individualAppWorkOrder.RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'IndividualApplication' AND DeveloperName = 'FinSys' WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .Id;
      // Map work order-specific fields
      individualAppWorkOrder.Destination__c = 'Destination';
      individualAppWorkOrder.LicenseTypeId = '0eh3S0000003Ix2QAE';
      individualAppWorkOrder.Category = 'License';
      System.debug('Creating new work order');
    }

    // Map fields from the passed customer object
    individualAppWorkOrder.Contact__c = customer.Id; // Link the Contact ID without updating it
    individualAppWorkOrder.Last_Name__c = (String) customerDetails.get('lastName');
    individualAppWorkOrder.Middle_Name__c = (String) customerDetails.get('middleInitial');
    individualAppWorkOrder.First_Name__c = (String) customerDetails.get('firstName');
    individualAppWorkOrder.Organization_Name__c = (String) customerDetails.get('organizationName');
    individualAppWorkOrder.Email_Address__c = (String) customerDetails.get('emailAddress');
    individualAppWorkOrder.Cell_Phone_Number__c = (String) customerDetails.get('phoneNumber');
    individualAppWorkOrder.Address_Line_1__c = (String) address.get('street');
    individualAppWorkOrder.Suite_Apartment_Floor__c = (String) address.get('address2');
    individualAppWorkOrder.City__c = (String) address.get('city');
    individualAppWorkOrder.State__c = (String) address.get('state');
    individualAppWorkOrder.Country__c = (String) address.get('country');
    individualAppWorkOrder.Zip_Code__c = (String) address.get('zipCode');

    individualAppWorkOrder.AppliedDate = workOrderData.get('workOrderDate') !=
      null
      ? DateTime.newInstance(
          Date.valueOf((String) workOrderData.get('workOrderDate')),
          Time.newInstance(0, 0, 0, 0)
        )
      : null;

    individualAppWorkOrder.Work_Order_Status__c = (String) workOrderData.get(
      'workOrderStatus'
    );
    individualAppWorkOrder.Work_Order_Comments__c = (String) workOrderData.get(
      'comment'
    );

    // Perform Insert or Update
    if (String.isNotBlank(recordId)) {
      Database.update(individualAppWorkOrder, AccessLevel.USER_MODE); // Update existing work order
      System.debug('Updated work order: ' + individualAppWorkOrder);
    } else {
      Database.insert(individualAppWorkOrder, AccessLevel.USER_MODE); // Insert new work order
      System.debug('Inserted new work order: ' + individualAppWorkOrder);
    }

    return new Map<String, Object>{
      'id' => individualAppWorkOrder.Id,
      'sequenceNumber' => individualAppWorkOrder.Sequence_Number__c
    };
  }


  private static void upsertTransactionFeeAndItem(
    List<Object> tnxTransactions,
    Id workOrderId,
    Date workOrderDate,
    Id batchId
) {
    System.debug('workOrder date is ' + workOrderDate);
    // Fetch Record Type IDs
    Id newTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByName()
        .get('New Transaction')
        .getRecordTypeId();
    Id createTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByName()
        .get('Create Transaction')
        .getRecordTypeId();

    // Lists to hold records for bulk upsert
    List<RegulatoryTrxnFee> regulatoryFees = new List<RegulatoryTrxnFee>();
    List<RegulatoryTrxnFeeItem> feeItems = new List<RegulatoryTrxnFeeItem>();

    // Get existing fees for this work order to check for updates
    Map<String, RegulatoryTrxnFee> existingFees = new Map<String, RegulatoryTrxnFee>();
    for(RegulatoryTrxnFee fee : [SELECT Id, ParentRecordId, Payment_Collection__c, Payment_Type__c,
                                       Card_Type__c, Card_Number__c, CK_Number__c, Money_Order_Number__c,
                                       Amount__c, Transaction_Date__c, Batch_Look_Up__c
                                FROM RegulatoryTrxnFee
                                WHERE ParentRecordId = :workOrderId WITH SECURITY_ENFORCED]) {

                                  if(fee != null) {
                                    existingFees.put(fee.Id, fee);
                                }
    }

    System.debug('existingFees have ids: '+existingFees);

    // Map to store fee Id to existing fee items
    Map<Id, RegulatoryTrxnFeeItem> existingFeeItems = new Map<Id, RegulatoryTrxnFeeItem>();
    for(RegulatoryTrxnFeeItem item : [SELECT Id, RegulatoryTrxnFeeId, Select_Activity__c,
                                            Select_Sub_Activity__c, Select_Program_Code__c,
                                            FeeAmount, Tax_Exempt__c, Transaction_Date__c
                                     FROM RegulatoryTrxnFeeItem
                                     WHERE RegulatoryTrxnFeeId IN :existingFees.values() WITH SECURITY_ENFORCED]) {
        existingFeeItems.put(item.RegulatoryTrxnFeeId, item);
    }
    System.debug('existingFeesItems have ids: '+existingFeeItems);


    // Loop through each tnxTransaction
    for (Object tnxTransaction : tnxTransactions) {
        Map<String, Object> payment = (Map<String, Object>) tnxTransaction;
        String transactionId = (String) payment.get('tnxId');

        // Check if fee already exists
        RegulatoryTrxnFee regFee;
        if(transactionId != null) {
          if(existingFees.containsKey(transactionId)) {
            regFee = existingFees.get(transactionId);
          }
          System.debug('found with key');
        } else {
            regFee = new RegulatoryTrxnFee();
            regFee.RecordTypeId = newTransactionRecordTypeId;
            regFee.ParentRecordId = workOrderId;
            regFee.Status = 'Draft';
        }

        // Update/Set fee fields
        String paymentAmount = (String) payment.get('paymentAmount');
        String paymentType = (String) payment.get('paymentType');
        regFee.Batch_Look_Up__c = batchId;
        regFee.Payment_Collection__c = (String) payment.get('paymentCollection');
        regFee.Payment_Type__c = paymentType;
        regFee.Card_Type__c = (String) payment.get('cardType');
        regFee.Transaction_Date__c = workOrderDate;
        regFee.Tax_Exempt__c = (Boolean)payment.get('taxExempt');
        regFee.Reporting_Only__c = (Boolean)payment.get('reportingOnly');

        // Map optional fields with casting
        if (payment.containsKey('cardDigit') && payment.get('cardDigit') != null) {
            regFee.Card_Number__c = Decimal.valueOf(String.valueOf(payment.get('cardDigit')));
        }
        if (payment.containsKey('ckNumber') && payment.get('ckNumber') != null) {
            regFee.CK_Number__c = Decimal.valueOf(String.valueOf(payment.get('ckNumber')));
        }
        if (payment.containsKey('serialNumber') && payment.get('serialNumber') != null) {
            regFee.Money_Order_Number__c = Decimal.valueOf(String.valueOf(payment.get('serialNumber')));
        }
        regFee.Amount__c = Decimal.valueOf(paymentAmount);

        System.debug('regFee data is :'+ regFee);


        regulatoryFees.add(regFee);
  }

    // Upsert the RegulatoryTrxnFee records
    if (!regulatoryFees.isEmpty()) {
        Database.upsert(regulatoryFees, AccessLevel.USER_MODE);

        // Create or update corresponding RegulatoryTrxnFeeItem records
        for (Integer i = 0; i < regulatoryFees.size(); i++) {
            RegulatoryTrxnFee insertedFee = regulatoryFees[i];
            Map<String, Object> tnxPayment = (Map<String, Object>) tnxTransactions[i];

            // Check if fee item exists
            RegulatoryTrxnFeeItem feeItem;
            if(existingFeeItems.containsKey(insertedFee.Id)) {
                feeItem = existingFeeItems.get(insertedFee.Id);
            } else {
                feeItem = new RegulatoryTrxnFeeItem();
                feeItem.RecordTypeId = createTransactionRecordTypeId;
                feeItem.RegulatoryTrxnFeeId = insertedFee.Id;
            }

            // Update/Set fee item fields
            feeItem.Name = 'Fee Item for ' + tnxPayment.get('activity');
            feeItem.Payment_Type__c = insertedFee.Payment_Type__c;
            feeItem.Select_Activity__c = (String) tnxPayment.get('activity');
            feeItem.Transaction_Date__c = workOrderDate;
            feeItem.Select_Sub_Activity__c = (String) tnxPayment.get('activityCode');
            feeItem.Select_Program_Code__c = (String) tnxPayment.get('programCode');
            feeItem.FeeAmount = tnxPayment.containsKey('paymentAmount')
                ? Decimal.valueOf(String.valueOf(tnxPayment.get('paymentAmount')))
                : null;
            feeItem.Tax_Exempt__c = tnxPayment.containsKey('taxExempt')
                ? (Boolean) tnxPayment.get('taxExempt')
                : false;

            feeItems.add(feeItem);
        }

        // Upsert the RegulatoryTrxnFeeItem records
        if (!feeItems.isEmpty()) {
            Database.upsert(feeItems,AccessLevel.USER_MODE);
        }
    }
}

  private static void creatingActivityPayments(
    List<Object> transactions,
    List<Object> payments,
    Id workOrderId,
    Id batchId,
    Boolean isSinglePayment
  ) {
    Id newTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByName()
      .get('New Transaction')
      .getRecordTypeId();
    Id createTransactionRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByName()
      .get('Create Transaction')
      .getRecordTypeId();

    List<RegulatoryTrxnFee> regulatoryFees = new List<RegulatoryTrxnFee>();
    List<RegulatoryTrxnFeeItem> feeItems = new List<RegulatoryTrxnFeeItem>();

    if (isSinglePayment) {
      // Handle single payment scenario
      Map<String, Object> singlePayment = (Map<String, Object>) payments[0];

      // Create a Regulatory Transaction Fee record
      RegulatoryTrxnFee regFee = new RegulatoryTrxnFee();
      regFee.RecordTypeId = newTransactionRecordTypeId; // Set Record Type as "New Transaction"
      regFee.Status = 'Draft';
      regFee.ParentRecordId = workOrderId;
      regFee.Batch_Look_Up__c = batchId;
      regFee.Payment_Collection__c = (String) singlePayment.get(
        'paymentCollection'
      );
      regFee.Payment_Type__c = (String) singlePayment.get('paymentType');
      regFee.Card_Type__c = (String) singlePayment.get('cardType');

      // Map optional fields with casting
      if (
        singlePayment.containsKey('cardDigit') &&
        singlePayment.get('cardDigit') != null
      ) {
        regFee.Card_Number__c = Decimal.valueOf(
          String.valueOf(singlePayment.get('cardDigit'))
        );
      }
      if (
        singlePayment.containsKey('ckNumber') &&
        singlePayment.get('ckNumber') != null
      ) {
        regFee.CK_Number__c = Decimal.valueOf(
          String.valueOf(singlePayment.get('ckNumber'))
        );
      }
      if (
        singlePayment.containsKey('serialNumber') &&
        singlePayment.get('serialNumber') != null
      ) {
        regFee.Money_Order_Number__c = Decimal.valueOf(
          String.valueOf(singlePayment.get('serialNumber'))
        );
      }
      regFee.amount__c = Decimal.valueOf(
        (String) singlePayment.get('paymentAmount')
      );

      // Add the fee to the list
      regulatoryFees.add(regFee);

      // Insert the Regulatory Transaction Fee record
      Database.insert(regulatoryFees, AccessLevel.USER_MODE);
      System.debug(
        '[DEBUG] Inserted Regulatory Transaction Fee: ' + regulatoryFees
      );

      // Link activities to the payment
      String activityIdsString = (String) singlePayment.get('activities');
      List<String> activityIds = activityIdsString != null
        ? activityIdsString.split(',')
        : new List<String>();
      for (Object transactionObj : transactions) {
        Map<String, Object> Indtransaction = (Map<String, Object>) transactionObj;
        RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
        feeItem.RecordTypeId = createTransactionRecordTypeId; // Set Record Type as "Create Transaction"
        feeItem.RegulatoryTrxnFeeId = regFee.Id; // Link to the fee
        feeItem.Name = regFee.Id;
        feeItem.Payment_Type__c = regFee.Payment_Type__c;
        feeItem.Select_Activity__c = (String) Indtransaction.get('activity');
        feeItem.Select_Sub_Activity__c = (String) Indtransaction.get(
          'activityCode'
        );
        feeItem.Select_Program_Code__c = (String) Indtransaction.get(
          'programCode'
        );
        feeItem.FeeAmount = Indtransaction.containsKey('feeAmount')
          ? Decimal.valueOf(String.valueOf(Indtransaction.get('feeAmount')))
          : null;
        feeItem.Tax_Exempt__c = Indtransaction.containsKey('taxExempt')
          ? (Boolean) Indtransaction.get('taxExempt')
          : false;

        feeItems.add(feeItem);
      }

      // Insert the Fee Items
      Database.insert(feeItems,AccessLevel.USER_MODE);
      System.debug('[DEBUG] Inserted Fee Items: ' + feeItems);
    } else {
      // Handle multiple payments scenario
      for (Object paymentObj : payments) {
        Map<String, Object> payment = (Map<String, Object>) paymentObj;

        // Create a Regulatory Transaction Fee record for each payment
        RegulatoryTrxnFee regFee = new RegulatoryTrxnFee();
        regFee.RecordTypeId = newTransactionRecordTypeId; // Set Record Type as "New Transaction"
        regFee.ParentRecordId = workOrderId;
        regFee.Status = 'Draft';
        regFee.Batch_Look_Up__c = batchId;
        regFee.Payment_Collection__c = (String) payment.get(
          'paymentCollection'
        );
        regFee.Payment_Type__c = (String) payment.get('paymentType');
        regFee.Card_Type__c = (String) payment.get('cardType');

        // Map optional fields with casting
        if (
          payment.containsKey('cardDigit') && payment.get('cardDigit') != null
        ) {
          regFee.Card_Number__c = Decimal.valueOf(
            String.valueOf(payment.get('cardDigit'))
          );
        }
        if (
          payment.containsKey('ckNumber') && payment.get('ckNumber') != null
        ) {
          regFee.CK_Number__c = Decimal.valueOf(
            String.valueOf(payment.get('ckNumber'))
          );
        }
        if (
          payment.containsKey('serialNumber') &&
          payment.get('serialNumber') != null
        ) {
          regFee.Money_Order_Number__c = Decimal.valueOf(
            String.valueOf(payment.get('serialNumber'))
          );
        }
        regFee.amount__c = Decimal.valueOf(
          (String) payment.get('paymentAmount')
        );

        regulatoryFees.add(regFee); // Add to the list of fees
      }

      // Insert all Regulatory Transaction Fees in bulk
      Database.insert(regulatoryFees, AccessLevel.USER_MODE);
      System.debug(
        '[DEBUG] Inserted Regulatory Transaction Fees: ' + regulatoryFees
      );

      // Link the fee items to the inserted fees
      for (Integer i = 0; i < payments.size(); i++) {
        Map<String, Object> payment = (Map<String, Object>) payments[i];
        RegulatoryTrxnFee insertedFee = regulatoryFees[i]; // Match inserted fee by index

        String activityId = (String) payment.get('activities'); // Get the single activity ID
        for (Object transactionObj : transactions) {
          Map<String, Object> Indtransaction = (Map<String, Object>) transactionObj;

          // Check if the transaction's ID matches the activity ID
          if (activityId == (String) Indtransaction.get('Id')) {
            RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
            feeItem.RecordTypeId = createTransactionRecordTypeId; // Set Record Type as "Create Transaction"
            feeItem.RegulatoryTrxnFeeId = insertedFee.Id; // Link to the fee
            feeItem.Name = 'Fee Item for ' + Indtransaction.get('activity'); // Generate a meaningful name
            feeItem.Payment_Type__c = insertedFee.Payment_Type__c;
            feeItem.Select_Activity__c = (String) Indtransaction.get(
              'activity'
            ); // Map the activity
            feeItem.Select_Sub_Activity__c = (String) Indtransaction.get(
              'activityCode'
            ); // Map the sub-activity
            feeItem.Select_Program_Code__c = (String) Indtransaction.get(
              'programCode'
            ); // Map the program code
            feeItem.FeeAmount = Indtransaction.containsKey('feeAmount')
              ? Decimal.valueOf(String.valueOf(Indtransaction.get('feeAmount')))
              : null; // Map the fee amount
            feeItem.Tax_Exempt__c = Indtransaction.containsKey('taxExempt')
              ? (Boolean) Indtransaction.get('taxExempt')
              : false; // Map the tax exemption

            feeItems.add(feeItem); // Add the fee item to the list
            break; // Exit the loop once the match is found (one-to-one mapping)
          }
        }
      }

      // Insert all Fee Items in bulk
      Database.insert(feeItems,AccessLevel.USER_MODE);
      System.debug('[DEBUG] Inserted Fee Items: ' + feeItems);
    }
  }

  private static void processTransactionsAndPayments(
    List<Object> transactions,
    List<Object> payments,
    Id workOrderId,
    Id batchId,
    String transactionType
  ) {
    if (transactions == null || transactions.isEmpty()) {
      System.debug('No transactions provided.');
      return;
    }
    if (payments == null || payments.isEmpty()) {
      System.debug('No payments provided.');
      return;
    }

    List<RegulatoryTrxnFee> feesToInsert = new List<RegulatoryTrxnFee>();
    List<RegulatoryTrxnFeeItem> feeItemsToInsert = new List<RegulatoryTrxnFeeItem>();
    List<Activity__c> activitiesToInsert = new List<Activity__c>();
    List<ActivityTransactionItemMapping__c> mappingsToInsert = new List<ActivityTransactionItemMapping__c>();

    Map<String, Id> tempActivityIdToSfIdMap = new Map<String, Id>();
    Map<String, Id> tempFeeIdToSfIdMap = new Map<String, Id>();

    // Step 1: Insert Transaction Fees
    for (Object paymentObj : payments) {
      if (!(paymentObj instanceof Map<String, Object>)) {
        System.debug('Skipping invalid payment format.');
        continue;
      }

      Map<String, Object> paymentData = (Map<String, Object>) paymentObj;

      RegulatoryTrxnFee fee = new RegulatoryTrxnFee();
      fee.Batch_Look_Up__c = batchId;
      fee.Payment_Collection__c = (String) paymentData.get('paymentCollection');
      fee.Payment_Type__c = (String) paymentData.get('paymentType');
      fee.Card_Type__c = (String) paymentData.get('cardType');
      if (
        paymentData.containsKey('cardDigit') &&
        paymentData.get('cardDigit') != null
      ) {
        fee.Card_Number__c = Decimal.valueOf(
          String.valueOf(paymentData.get('cardDigit'))
        );
      }
      if (
        paymentData.containsKey('ckNumber') &&
        paymentData.get('ckNumber') != null
      ) {
        fee.CK_Number__c = Decimal.valueOf(
          String.valueOf(paymentData.get('ckNumber'))
        );
      }
      if (
        paymentData.containsKey('serialNumber') &&
        paymentData.get('serialNumber') != null
      ) {
        fee.Money_Order_Number__c = Decimal.valueOf(
          String.valueOf(paymentData.get('serialNumber'))
        );
      }
      fee.Transaction_Date__c = paymentData.containsKey('transactionDate')
        ? Date.valueOf(String.valueOf(paymentData.get('transactionDate')))
        : null;

      fee.ParentRecordId = workOrderId;
      fee.Status = 'Draft';
      feesToInsert.add(fee);

      String tempFeeId = (String) paymentData.get('Id');
      tempFeeIdToSfIdMap.put(tempFeeId, null);
    }

    Database.insert(feesToInsert,AccessLevel.USER_MODE);

    for (Integer i = 0; i < feesToInsert.size(); i++) {
      Map<String, Object> paymentData = (Map<String, Object>) payments[i];
      String tempFeeId = (String) paymentData.get('Id');
      tempFeeIdToSfIdMap.put(tempFeeId, feesToInsert[i].Id);
    }

    // Step 2: Insert Transaction Fee Items
    for (Object paymentObj : payments) {
      if (!(paymentObj instanceof Map<String, Object>)) {
        System.debug('Skipping invalid payment format.');
        continue;
      }

      Map<String, Object> paymentData = (Map<String, Object>) paymentObj;

      RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
      feeItem.RegulatoryTrxnFeeId = tempFeeIdToSfIdMap.get(
        (String) paymentData.get('Id')
      );
      feeItem.Name = tempFeeIdToSfIdMap.get((String) paymentData.get('Id'));
      feeItem.FeeAmount = paymentData.containsKey('paymentAmount')
        ? Decimal.valueOf(String.valueOf(paymentData.get('paymentAmount')))
        : null;

      feeItemsToInsert.add(feeItem);
    }

    Database.insert(feeItemsToInsert,AccessLevel.USER_MODE);

    // Step 3: Insert Activities
    for (Object trxObj : transactions) {
      if (!(trxObj instanceof Map<String, Object>)) {
        System.debug('Skipping invalid transaction format.');
        continue;
      }

      Map<String, Object> trxData = (Map<String, Object>) trxObj;

      Activity__c activity = new Activity__c();
      activity.Activity_Name__c = (String) trxData.get('activity');
      activity.Sub_Activity_Name__c = (String) trxData.get('activityCode');
      activity.Program_Name__c = (String) trxData.get('programCode');
      activity.FeeAmount__c = trxData.containsKey('feeAmount')
        ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount')))
        : null;
      activity.TransactionDate__c = trxData.containsKey('transactionDate')
        ? Date.valueOf(String.valueOf(trxData.get('transactionDate')))
        : null;
      activity.TaxExempt__c = trxData.containsKey('taxExempt')
        ? (Boolean) trxData.get('taxExempt')
        : false;
      activity.Individual_Application__c = workOrderId;

      activitiesToInsert.add(activity);

      String tempActivityId = (String) trxData.get('Id');
      tempActivityIdToSfIdMap.put(tempActivityId, null);
    }

    Database.insert(activitiesToInsert, AccessLevel.USER_MODE);

    for (Integer i = 0; i < activitiesToInsert.size(); i++) {
      Map<String, Object> trxData = (Map<String, Object>) transactions[i];
      String tempActivityId = (String) trxData.get('Id');
      tempActivityIdToSfIdMap.put(tempActivityId, activitiesToInsert[i].Id);
    }

    // Step 4: Insert Mappings
    for (Object paymentObj : payments) {
      if (!(paymentObj instanceof Map<String, Object>)) {
        System.debug('Skipping invalid payment format.');
        continue;
      }

      Map<String, Object> paymentData = (Map<String, Object>) paymentObj;
      String tempActivityId = (String) paymentData.get('activities'); // Single activity ID

      String tempFeeId = (String) paymentData.get('Id');

      if (tempActivityId != null) {
        ActivityTransactionItemMapping__c mapping = new ActivityTransactionItemMapping__c();
        mapping.Activity__c = tempActivityIdToSfIdMap.get(tempActivityId);
        mapping.Regulatory_Transaction_Fee__c = tempFeeIdToSfIdMap.get(
          tempFeeId
        );
        mapping.Transaction_Type__c = transactionType;

        mappingsToInsert.add(mapping);
      }
    }

    Database.insert(mappingsToInsert,AccessLevel.USER_MODE);

    System.debug('Inserted Fees: ' + feesToInsert);
    System.debug('Inserted Fee Items: ' + feeItemsToInsert);
    System.debug('Inserted Activities: ' + activitiesToInsert);
    System.debug('Inserted Mappings: ' + mappingsToInsert);
  }

  private static void uploadAndLinkDocuments(
    Map<String, Object> workOrderData,
    Id individualApplicationId
  ) {
    try {
      // Step 1: Delete documents specified in deletedFiles
      if (workOrderData.containsKey('deletedFiles')) {
        List<Object> rawDeletedFileIds = (List<Object>) workOrderData.get(
          'deletedFiles'
        );
        List<String> deletedFileIds = new List<String>();

        for (Object fileId : rawDeletedFileIds) {
          deletedFileIds.add((String) fileId);
        }

        if (!deletedFileIds.isEmpty()) {
          List<ContentDocumentLink> linksToDelete = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE
              ContentDocumentId IN :deletedFileIds
              AND LinkedEntityId = :individualApplicationId WITH SECURITY_ENFORCED
          ];
          database.delete(linksToDelete, AccessLevel.USER_MODE);
          System.debug('Deleted ContentDocumentLinks: ' + linksToDelete);
        }
      }

      // Step 2: Handle new and updated documents
      List<ContentVersion> contentVersionsToInsertOrUpdate = new List<ContentVersion>();
      Map<String, String> documentToTypeMap = new Map<String, String>(); // ContentDocumentId -> docType mapping

      // Query existing documents linked to the application
      Map<String, ContentDocumentLink> existingLinksMap = new Map<String, ContentDocumentLink>();
      List<ContentDocumentLink> existingLinks = [
        SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :individualApplicationId WITH SECURITY_ENFORCED
      ];
      for (ContentDocumentLink link : existingLinks) {
        existingLinksMap.put(link.ContentDocumentId, link);
      }

      // Process documents
      if (workOrderData.containsKey('documents')) {
        List<Object> documents = (List<Object>) workOrderData.get('documents');
        for (Object docObj : documents) {
          Map<String, Object> document = (Map<String, Object>) docObj;

          if (document != null) {
            String docType = (String) document.get('docType');
            String existingDocId = document.containsKey('documentId')
              ? (String) document.get('documentId')
              : null;

            // Retrieve nested `docFile` object
            Map<String, Object> docFile = document.containsKey('docFile')
              ? (Map<String, Object>) document.get('docFile')
              : null;

            if (docFile != null) {
              String fileName = (String) docFile.get('fileName');
              String base64Data = (String) docFile.get('base64Data');
              String contentType = (String) docFile.get('contentType');

              // Validate base64Data and fileName
              if (
                String.isNotBlank(base64Data) && String.isNotBlank(fileName)
              ) {
                // Create or update ContentVersion
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = fileName;
                contentVersion.PathOnClient = fileName;
                contentVersion.VersionData = EncodingUtil.base64Decode(
                  base64Data
                );

                if (
                  existingDocId != null &&
                  existingLinksMap.containsKey(existingDocId)
                ) {
                  // Update existing document by linking new version
                  contentVersion.ContentDocumentId = existingDocId;
                }
                contentVersionsToInsertOrUpdate.add(contentVersion);
                documentToTypeMap.put(
                  existingDocId != null ? existingDocId : contentVersion.Id,
                  docType
                );
              } else {
                System.debug(
                  'Skipping document due to missing base64Data or fileName: ' +
                  document
                );
              }
            } else {
              System.debug(
                'Skipping document due to missing docFile object: ' + document
              );
            }
          } else {
            System.debug('Skipping invalid document: ' + document);
          }
        }
      }

      // Upsert ContentVersion records
      if (!contentVersionsToInsertOrUpdate.isEmpty()) {
        Database.insert(contentVersionsToInsertOrUpdate, AccessLevel.USER_MODE);
        System.debug(
          'Inserted ContentVersions: ' + contentVersionsToInsertOrUpdate
        );

        // Fetch newly created ContentDocuments for linking
        List<ContentDocument> contentDocuments = [
          SELECT Id
          FROM ContentDocument
          WHERE
            Id IN (
              SELECT ContentDocumentId
              FROM ContentVersion
              WHERE Id IN :contentVersionsToInsertOrUpdate
            )
            WITH SECURITY_ENFORCED
        ];

        // Step 3: Link documents and associate docType
        List<ContentDocumentLink> documentLinksToInsert = new List<ContentDocumentLink>();
        for (ContentDocument contentDocument : contentDocuments) {
          if (!existingLinksMap.containsKey(contentDocument.Id)) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocument.Id;
            link.LinkedEntityId = individualApplicationId;
            link.ShareType = 'I';
            link.Visibility = 'AllUsers';
            documentLinksToInsert.add(link);
          }
          // Debug docType association
          System.debug(
            'Linked ContentDocument: ' +
              contentDocument.Id +
              ' with docType: ' +
              documentToTypeMap.get(contentDocument.Id)
          );
        }

        if (!documentLinksToInsert.isEmpty()) {
          Database.insert(documentLinksToInsert, AccessLevel.USER_MODE);
          System.debug(
            'Inserted ContentDocumentLinks: ' + documentLinksToInsert
          );
        }
      }
    } catch (Exception e) {
      System.debug('Error in uploadAndLinkDocuments: ' + e.getMessage());
      throw new AuraHandledException(
        'An error occurred while uploading and linking documents: ' +
        e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static Map<String, Object> getWorkOrderDetailsUpdated(String requestData) {
    try {
      // Deserialize input
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        requestData
      );
      String workOrderId = (String) params.get('workOrderId');
      String transactionType = (String) params.get('transactionType');
      System.debug('transaction type is ' + transactionType);

      if (String.isBlank(workOrderId)) {
        throw new AuraHandledException('Work Order ID is required.');
      }

      // Fetch the work order
      IndividualApplication workOrder = [
        SELECT
          Id,
          Destination__c,
          LicenseTypeId,
          Category,
          Contact__c,
          Contact__r.Customer_Account_Balance__c,
          AppliedDate,
          Last_Name__c,
          Middle_Name__c,
          First_Name__c,
          Address_Line_1__c,
          Suite_Apartment_Floor__c,
          City__c,
          State__c,
          Country__c,
          Zip_Code__c,
          Organization_Name__c,
          Email_Address__c,
          Cell_Phone_Number__c,
          Work_Order_Status__c,
          Work_Order_Comments__c
        FROM IndividualApplication
        WHERE Id = :workOrderId WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      // Fetch transactions (fees) and their items
      List<RegulatoryTrxnFee> txnFees = [
        SELECT
          Id,
          RecordType.Name,
          ParentRecordId,
          Batch_Look_Up__c,
          Status,
          Payment_Collection__c,
          Payment_Type__c,
          Card_Type__c,
          Card_Number__c,
          CK_Number__c,
          Money_Order_Number__c,
          Amount__c,
          TotalFeeAmount,
          Transaction_Date__c,
          Tax_Exempt__c,
          Reporting_Only__c,
          Batch_Look_Up__r.CreatedDate,
          Batch_Look_Up__r.Batch_Name__c
        FROM RegulatoryTrxnFee
        WHERE ParentRecordId = :workOrderId WITH SECURITY_ENFORCED
      ];

      List<RegulatoryTrxnFeeItem> txnFeeItems = [
        SELECT
          Id,
          RegulatoryTrxnFeeId,
          Select_Activity__c,
          Select_Sub_Activity__c,
          Select_Program_Code__c,
          FeeAmount,
          Transaction_Date__c,
          Tax_Exempt__c
        FROM RegulatoryTrxnFeeItem
        WHERE RegulatoryTrxnFeeId IN :txnFees WITH SECURITY_ENFORCED
      ];

      // Map Fee ID to Fee Items
      Map<Id, RegulatoryTrxnFeeItem> feeItemMap = new Map<Id, RegulatoryTrxnFeeItem>();
      for (RegulatoryTrxnFeeItem item : txnFeeItems) {
        feeItemMap.put(item.RegulatoryTrxnFeeId, item);
      }

      // Fetch documents linked to the work order
      List<ContentDocumentLink> documentLinks = [
        SELECT
          Id,
          ContentDocumentId,
          ContentDocument.Title,
          ContentDocument.LatestPublishedVersionId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :workOrderId WITH SECURITY_ENFORCED
      ];

      // Map document links to FileInfo objects
      List<Map<String, Object>> documentList = new List<Map<String, Object>>();
      for (ContentDocumentLink link : documentLinks) {
        documentList.add(
          new Map<String, Object>{
            'title' => link.ContentDocument.Title,
            'documentId' => link.ContentDocumentId,
            'versionId' => link.ContentDocument.LatestPublishedVersionId,
            'id' => link.Id
          }
        );
      }

      // Combine transactions with fee items
      List<Map<String, Object>> transactions = new List<Map<String, Object>>();
      for (RegulatoryTrxnFee fee : txnFees) {
        RegulatoryTrxnFeeItem feeItem = feeItemMap.get(fee.Id);
        if (fee.RecordType.Name == 'New Transaction') {
          transactions.add(
            new Map<String, Object>{
              'id' => fee.Id,
              'tnxId' => fee.Id,
              'activity' => feeItem != null ? feeItem.Select_Activity__c : null,
              'activityCode' => feeItem != null
                ? feeItem.Select_Sub_Activity__c
                : null,
              'programCode' => feeItem != null
                ? feeItem.Select_Program_Code__c
                : null,
              'feeAmount' => feeItem != null &&
                feeItem.FeeAmount != null
                ? String.valueOf(feeItem.FeeAmount)
                : null,
              'taxExempt' => fee.Tax_Exempt__c,
              'reportingOnly' => fee.Reporting_Only__c,
              'transactionDate' => fee.Transaction_Date__c != null
                ? String.valueOf(fee.Transaction_Date__c)
                : null,
              'paymentCollection' => fee.Payment_Collection__c,
              'paymentType' => fee.Payment_Type__c,
              'cardType' => fee.Card_Type__c,
              'cardDigit' => fee.Card_Number__c,
              'serialNumber' => fee.Money_Order_Number__c,
              'ckNumber' => fee.CK_Number__c,
              'paymentAmount' => fee.TotalFeeAmount != null ? String.valueOf(fee.TotalFeeAmount) : null,
              'batchId' => fee.Batch_Look_Up__r.Id,
              'recordType' => fee.RecordType.Name
            }
          );
        }
      }

      // Extract batch ID and date
      Id batchId = txnFees.isEmpty() ? null : txnFees[0].Batch_Look_Up__c;
      Date batchDate = txnFees.isEmpty() ||
        txnFees[0].Batch_Look_Up__r.CreatedDate == null
        ? null
        : txnFees[0].Batch_Look_Up__r.CreatedDate.date();

      String defaultActivity = txnFees.isEmpty()
        ? null
        : txnFees[0].Batch_Look_Up__r.Batch_Name__c;

      // Prepare response
      Map<String, Object> response = new Map<String, Object>();
      response.put(
        'workOrder',
        new Map<String, Object>{
          'id' => workOrder.Id,
          'destination' => workOrder.Destination__c,
          'licenseTypeId' => workOrder.LicenseTypeId,
          'category' => workOrder.Category,
          'contactId' => workOrder.Contact__c,
          'lastName' => workOrder.Last_Name__c,
          'middleName' => workOrder.Middle_Name__c,
          'firstName' => workOrder.First_Name__c,
          'addressLine1' => workOrder.Address_Line_1__c,
          'suiteApartmentFloor' => workOrder.Suite_Apartment_Floor__c,
          'city' => workOrder.City__c,
          'state' => workOrder.State__c,
          'country' => workOrder.Country__c,
          'zipCode' => workOrder.Zip_Code__c,
          'organizationName' => workOrder.Organization_Name__c,
          'emailAddress' => workOrder.Email_Address__c,
          'phoneNumber' => workOrder.Cell_Phone_Number__c,
          'status' => workOrder.Work_Order_Status__c,
          'woDate' => workOrder.AppliedDate.date(),
          'comments' => workOrder.Work_Order_Comments__c,
          'customerAccountBal' => workOrder.Contact__r.Customer_Account_Balance__c
        }
      );

      if (transactionType == 'Refund Transaction') {
        // Fetch all refund transactions linked to the work order
        List<RegulatoryTrxnFee> refundPayments = [
          SELECT
            Id,
            Name,
            RecordType.Name,
            Refund_ID__c,
            Related_to_Transaction__c,
            Payment_Type__c,
            TotalFeeAmount,
            Refund_Voucher_ID__c,
            Refund_Reason__c,
            Transaction_Date__c,
            Transaction_Status__c
          FROM RegulatoryTrxnFee
          WHERE
            ParentRecordId = :workOrderId
            AND RecordType.Name = 'Refund Transaction' WITH SECURITY_ENFORCED
        ];

        // Fetch associated refund items for each refund transaction
        List<RegulatoryTrxnFeeItem> refundFeeItems = [
          SELECT Id, RegulatoryTrxnFeeId, FeeAmount, CreatedDate,Transaction_Date__c
          FROM RegulatoryTrxnFeeItem
          WHERE RegulatoryTrxnFeeId IN :refundPayments WITH SECURITY_ENFORCED
        ];

        // Map refund transaction IDs to their fee items
        Map<Id, List<RegulatoryTrxnFeeItem>> refundToFeeItemsMap = new Map<Id, List<RegulatoryTrxnFeeItem>>();
        for (RegulatoryTrxnFeeItem feeItem : refundFeeItems) {
          if (!refundToFeeItemsMap.containsKey(feeItem.RegulatoryTrxnFeeId)) {
            refundToFeeItemsMap.put(
              feeItem.RegulatoryTrxnFeeId,
              new List<RegulatoryTrxnFeeItem>()
            );
          }
          refundToFeeItemsMap.get(feeItem.RegulatoryTrxnFeeId).add(feeItem);
        }

        // Prepare refund transaction data for response
        List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
        for (RegulatoryTrxnFee refund : refundPayments) {
          DateTime refundDate = refund.Transaction_Date__c !=null ? (DateTime) refund.Transaction_Date__c : null;
          String formattedrefundDate = refundDate !=null ?  refundDate.format('MM/dd/yyyy', 'GMT') : null;

           // Query to fetch Card_Number__c based on Related_to_Transaction__c
           RegulatoryTrxnFee relatedTransaction ;
          if(refund.Related_to_Transaction__c != null && refund.Payment_Type__c == 'Card') {
             relatedTransaction = [ SELECT Card_Number__c,Transaction_ID_Count__c FROM RegulatoryTrxnFee WHERE Id = :refund.Related_to_Transaction__c WITH SECURITY_ENFORCED LIMIT 1];
          }

          refundTransactions.add(
            new Map<String, Object>{
              'id' => refund.Id,
              'refundId'=>refund.Refund_ID__c,
              'originalTransactionId' => refund.Related_to_Transaction__c !=null ? relatedTransaction.Transaction_ID_Count__c : null,
              'refundPaymentMethod' => refund.Payment_Type__c,
              'cardNumber' => relatedTransaction != null ? relatedTransaction.Card_Number__c : null, // Add Card_Number__c
              'refundAmount' => refund.TotalFeeAmount != null ? String.valueOf(refund.TotalFeeAmount)  : null,
              'refundDate' => refund.Transaction_Date__c != null ? refund.Transaction_Date__c  : null,
              'refundDateFormatted' => formattedrefundDate!=null ? formattedrefundDate : null,
              'voucherId' => refund.Refund_Voucher_ID__c,
              'refundReason' => refund.Refund_Reason__c!=null ? refund.Refund_Reason__c : null,
              'status' => refund.Transaction_Status__c,
              'recordType' => refund.RecordType.Name
            }
          );
          System.debug('refundTransactions is :'+ refundTransactions);
        }

        response.put('refundTransactions', refundTransactions);
      } else {
        response.put('documents', documentList);
      }
      response.put('transactions', transactions);
      response.put('batchId', batchId);
      response.put('defaultActivity', defaultActivity);
      response.put('batchDate', batchDate);

      return response;
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Object> getWorkOrderDetailsFinsys(
    String requestData
  ) {
    try {
      // Deserialize the input JSON string
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        requestData
      );
      String workOrderId = (String) params.get('workOrderId');
      String transactionType = (String) params.get('transactionType');

      if (String.isBlank(workOrderId)) {
        throw new AuraHandledException('Work Order ID is required.');
      }

      // Fetch the work order
      IndividualApplication workOrder = [
        SELECT
          Id,
          Destination__c,
          LicenseTypeId,
          Category,
          Contact__c,
          Last_Name__c,
          Middle_Name__c,
          First_Name__c,
          Address_Line_1__c,
          Suite_Apartment_Floor__c,
          City__c,
          State__c,
          Country__c,
          Zip_Code__c,
          Organization_Name__c,
          Email_Address__c,
          Cell_Phone_Number__c,
          Work_Order_Status__c,
          Work_Order_Comments__c
        FROM IndividualApplication
        WHERE Id = :workOrderId WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      // Fetch the child records
      List<RegulatoryTrxnFee> childRecords = [
        SELECT
          Id,
          ParentRecordId,
          Payment_Collection__c,
          Payment_Type__c,
          Card_Type__c,
          Card_Number__c,
          Money_Order_Number__c,
          CK_Number__c,
          TotalFeeAmount,
          Transaction_Date__c,
          Status
        FROM RegulatoryTrxnFee
        WHERE ParentRecordId = :workOrderId WITH SECURITY_ENFORCED
      ];

      List<RegulatoryTrxnFeeItem> subChildRecords = [
        SELECT
          Id,
          RegulatoryTrxnFeeId,
          Select_Activity__c,
          Select_Sub_Activity__c,
          Select_Program_Code__c,
          FeeAmount,
          CreatedDate
        FROM RegulatoryTrxnFeeItem
        WHERE RegulatoryTrxnFeeId IN :childRecords WITH SECURITY_ENFORCED
      ];

      // Refund Transaction Flow
      List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
      if (transactionType == 'Refund Transaction') {
        List<RegulatoryTrxnFee> refundPayments = [
          SELECT
            Id,
            Payment_Collection__c,
            amount__c,
            Payment_Method__c,
            Refund_Voucher_ID__c,
            Transaction_Date__c,
            Related_to_Transaction__c
          FROM RegulatoryTrxnFee
          WHERE ParentRecordId = :workOrderId WITH SECURITY_ENFORCED
        ];

        for (RegulatoryTrxnFee refundPayment : refundPayments) {
          refundTransactions.add(
            new Map<String, Object>{
              'id' => refundPayment.Id,
              'originalTransactionId' => refundPayment.Related_to_Transaction__c,
              'refundPaymentMethod' => refundPayment.Payment_Method__c,
              'refundAmount' => refundPayment.amount__c,
              'refundDate' => refundPayment.Transaction_Date__c
            }
          );
        }
      }

      List<ContentDocumentLink> documentLinks = [
        SELECT
          Id,
          ContentDocumentId,
          LinkedEntityId,
          ContentDocument.Title,
          ContentDocument.LatestPublishedVersionId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :workOrderId WITH SECURITY_ENFORCED
      ];

      // Map document links to FileInfo objects
      List<FileInfo> documentList = new List<FileInfo>();
      for (ContentDocumentLink link : documentLinks) {
        FileInfo fileInfo = new FileInfo(
          link.ContentDocument.Title,
          link.ContentDocumentId,
          link.ContentDocument.LatestPublishedVersionId,
          link.Id
        );
        documentList.add(fileInfo);
      }

      // Prepare the response
      Map<String, Object> response = new Map<String, Object>();

      // Add Work Order details
      response.put(
        'workOrder',
        new Map<String, Object>{
          'id' => workOrder.Id,
          'destination' => workOrder.Destination__c,
          'licenseTypeId' => workOrder.LicenseTypeId,
          'category' => workOrder.Category,
          'contactId' => workOrder.Contact__c,
          'lastName' => workOrder.Last_Name__c,
          'middleName' => workOrder.Middle_Name__c,
          'firstName' => workOrder.First_Name__c,
          'addressLine1' => workOrder.Address_Line_1__c,
          'suiteApartmentFloor' => workOrder.Suite_Apartment_Floor__c,
          'city' => workOrder.City__c,
          'state' => workOrder.State__c,
          'country' => workOrder.Country__c,
          'zipCode' => workOrder.Zip_Code__c,
          'organizationName' => workOrder.Organization_Name__c,
          'emailAddress' => workOrder.Email_Address__c,
          'phoneNumber' => workOrder.Cell_Phone_Number__c,
          'status' => workOrder.Work_Order_Status__c,
          'comments' => workOrder.Work_Order_Comments__c
        }
      );

      List<Map<String, Object>> transactionList = new List<Map<String, Object>>();

      for (RegulatoryTrxnFeeItem item : subChildRecords) {
        transactionList.add(
          new Map<String, Object>{
            'id' => item.Id,
            'activity' => item.Select_Activity__c,
            'activityCode' => item.Select_Sub_Activity__c,
            'programCode' => item.Select_Program_Code__c,
            'feeAmount' => item.FeeAmount,
            'createdDate' => item.CreatedDate
          }
        );
      }

      response.put('transactions', transactionList);

      List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
      for (RegulatoryTrxnFee payment : childRecords) {
        paymentList.add(
          new Map<String, Object>{
            'id' => payment.Id,
            'paymentCollection' => payment.Payment_Collection__c,
            'paymentType' => payment.Payment_Type__c,
            'cardType' => payment.Card_Type__c,
            'cardDigit' => payment.Card_Number__c,
            'serialNumber' => payment.Money_Order_Number__c,
            'ckNumber' => payment.CK_Number__c,
            'paymentAmount' => payment.TotalFeeAmount,
            'transactionDate' => payment.Transaction_Date__c,
            'status' => payment.Status
          }
        );
      }

      response.put('payments', paymentList);

      if (transactionType == 'Refund Transaction') {
        // Add refund transaction details
        response.put('refundTransactions', refundTransactions);
      } else {
        response.put('documents', documentList);
      }

      return response;
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Object> getWorkOrderDetails(String requestData) {
    try {
      // Deserialize the input JSON string
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        requestData
      );
      String workOrderId = (String) params.get('workOrderId');
      String activityId = (String) params.get('activityId');
      String transactionType = (String) params.get('transactionType');

      if (String.isBlank(workOrderId)) {
        throw new AuraHandledException('Work Order ID is required.');
      }
      if (String.isBlank(activityId)) {
        throw new AuraHandledException('Activity ID is required.');
      }

      // Fetch the work order
      IndividualApplication workOrder = [
        SELECT
          Id,
          Destination__c,
          LicenseTypeId,
          Category,
          Contact__c,
          Last_Name__c,
          Middle_Name__c,
          First_Name__c,
          Address_Line_1__c,
          Suite_Apartment_Floor__c,
          City__c,
          State__c,
          Country__c,
          Zip_Code__c,
          Organization_Name__c,
          Email_Address__c,
          Cell_Phone_Number__c,
          Work_Order_Status__c,
          Work_Order_Comments__c
        FROM IndividualApplication
        WHERE Id = :workOrderId WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      // Fetch all related activities (transactions)
      List<Activity__c> activities = [
        SELECT
          Id,
          Activity_Name__c,
          Sub_Activity_Name__c,
          Program_Name__c,
          FeeAmount__c,
          TaxExempt__c,
          TransactionDate__c
        FROM Activity__c
        WHERE Id = :activityId WITH SECURITY_ENFORCED
      ];

      // Fetch Payment IDs and corresponding Activity IDs from ActivityTransactionItemMapping__c
      Map<Id, Id> paymentToActivityMap = new Map<Id, Id>();
      List<ActivityTransactionItemMapping__c> mappings = [
        SELECT Regulatory_Transaction_Fee__c, Activity__c, Transaction_Type__c
        FROM ActivityTransactionItemMapping__c
        WHERE Activity__c = :activityId WITH SECURITY_ENFORCED
      ];

      // Separate mappings for "New Transaction" and "Refund Transaction"
      Map<Id, Id> refundTransactionMap = new Map<Id, Id>(); // Refund Transaction Fee -> Activity
      for (ActivityTransactionItemMapping__c mapping : mappings) {
        if (
          mapping.Transaction_Type__c == 'New Transaction' &&
          mapping.Regulatory_Transaction_Fee__c != null
        ) {
          paymentToActivityMap.put(
            mapping.Regulatory_Transaction_Fee__c,
            mapping.Activity__c
          );
        } else if (
          mapping.Transaction_Type__c == 'Refund Transaction' &&
          mapping.Regulatory_Transaction_Fee__c != null
        ) {
          refundTransactionMap.put(
            mapping.Regulatory_Transaction_Fee__c,
            mapping.Activity__c
          );
        }
      }

      // Fetch Payments (New Transactions) from RegulatoryTrxnFee using the Payment IDs
      List<RegulatoryTrxnFee> payments = new List<RegulatoryTrxnFee>();
      Set<String> batchIds = new Set<String>();
      if (!paymentToActivityMap.isEmpty()) {
        payments = [
          SELECT
            Id,
            Payment_Collection__c,
            Payment_Type__c,
            Card_Type__c,
            Card_Number__c,
            Batch_Look_Up__c,
            Money_Order_Number__c,
            CK_Number__c,
            TotalFeeAmount,
            Status,
            Transaction_Date__c
          FROM RegulatoryTrxnFee
          WHERE Id IN :paymentToActivityMap.keySet() WITH SECURITY_ENFORCED
        ];

        for (RegulatoryTrxnFee payment : payments) {
          if (payment.Batch_Look_Up__c != null) {
            batchIds.add(payment.Batch_Look_Up__c);
          }
        }
      }

      // Refund Transaction Flow
      List<Map<String, Object>> refundTransactions = new List<Map<String, Object>>();
      if (
        transactionType == 'Refund Transaction' &&
        !refundTransactionMap.isEmpty()
      ) {
        List<RegulatoryTrxnFee> refundPayments = [
          SELECT
            Id,
            Payment_Collection__c,
            amount__c,
            Payment_Method__c,
            Refund_Voucher_ID__c,
            Transaction_Date__c,
            Related_to_Transaction__c
          FROM RegulatoryTrxnFee
          WHERE Id IN :refundTransactionMap.keySet() WITH SECURITY_ENFORCED
        ];

        for (RegulatoryTrxnFee refundPayment : refundPayments) {
          refundTransactions.add(
            new Map<String, Object>{
              'id' => refundPayment.Id,
              'originalTransactionId' => refundPayment.Related_to_Transaction__c,
              'refundPaymentMethod' => refundPayment.Payment_Method__c,
              'refundAmount' => refundPayment.amount__c,
              'refundDate' => refundPayment.Transaction_Date__c
            }
          );
        }
      }

      // Fetch documents linked to the work order
      List<ContentDocumentLink> documentLinks = [
        SELECT
          Id,
          ContentDocumentId,
          LinkedEntityId,
          ContentDocument.Title,
          ContentDocument.LatestPublishedVersionId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :workOrderId WITH SECURITY_ENFORCED
      ];

      // Map document links to FileInfo objects
      List<FileInfo> documentList = new List<FileInfo>();
      for (ContentDocumentLink link : documentLinks) {
        FileInfo fileInfo = new FileInfo(
          link.ContentDocument.Title,
          link.ContentDocumentId,
          link.ContentDocument.LatestPublishedVersionId,
          link.Id
        );
        documentList.add(fileInfo);
      }

      // Prepare the response
      Map<String, Object> response = new Map<String, Object>();

      // Add Work Order details
      response.put(
        'workOrder',
        new Map<String, Object>{
          'id' => workOrder.Id,
          'destination' => workOrder.Destination__c,
          'licenseTypeId' => workOrder.LicenseTypeId,
          'category' => workOrder.Category,
          'contactId' => workOrder.Contact__c,
          'lastName' => workOrder.Last_Name__c,
          'middleName' => workOrder.Middle_Name__c,
          'firstName' => workOrder.First_Name__c,
          'addressLine1' => workOrder.Address_Line_1__c,
          'suiteApartmentFloor' => workOrder.Suite_Apartment_Floor__c,
          'city' => workOrder.City__c,
          'state' => workOrder.State__c,
          'country' => workOrder.Country__c,
          'zipCode' => workOrder.Zip_Code__c,
          'organizationName' => workOrder.Organization_Name__c,
          'emailAddress' => workOrder.Email_Address__c,
          'phoneNumber' => workOrder.Cell_Phone_Number__c,
          'status' => workOrder.Work_Order_Status__c,
          'comments' => workOrder.Work_Order_Comments__c
        }
      );

      // Add activities as transactions
      List<Map<String, Object>> transactionList = new List<Map<String, Object>>();
      for (Activity__c activity : activities) {
        transactionList.add(
          new Map<String, Object>{
            'id' => activity.Id,
            'activity' => activity.Activity_Name__c,
            'activityCode' => activity.Sub_Activity_Name__c,
            'programCode' => activity.Program_Name__c,
            'feeAmount' => activity.FeeAmount__c,
            'taxExempt' => activity.TaxExempt__c,
            'transactionDate' => activity.TransactionDate__c
          }
        );
      }
      response.put('transactions', transactionList);

      // Add payments to the response, including activityId
      List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
      for (RegulatoryTrxnFee payment : payments) {
        paymentList.add(
          new Map<String, Object>{
            'id' => payment.Id,
            'paymentCollection' => payment.Payment_Collection__c,
            'paymentType' => payment.Payment_Type__c,
            'cardType' => payment.Card_Type__c,
            'cardDigit' => payment.Card_Number__c,
            'serialNumber' => payment.Money_Order_Number__c,
            'ckNumber' => payment.CK_Number__c,
            'paymentAmount' => payment.TotalFeeAmount,
            'transactionDate' => payment.Transaction_Date__c,
            'status' => payment.Status,
            'activityId' => paymentToActivityMap.get(payment.Id) // Include the mapped activityId
          }
        );
      }
      response.put('payments', paymentList);

      // Add batchID (single value, or empty if no batch IDs exist)
      response.put(
        'batchID',
        batchIds.isEmpty() ? null : batchIds.iterator().next()
      );

      // Add documents
      if (transactionType == 'Refund Transaction') {
        // Add refund transaction details
        response.put('refundTransactions', refundTransactions);
      } else {
        response.put('documents', documentList);
      }

      return response;
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Object> updateWorkOrder(String workOrderDataJson) {
    try {
      // Deserialize the JSON input
      Map<String, Object> workOrderData = (Map<String, Object>) JSON.deserializeUntyped(
        workOrderDataJson
      );
      String batchId = (String) workOrderData.get('batchId');
      String workOrderId = (String) workOrderData.get('recordId');
      String defaultActivity = (String) workOrderData.get('defaultActivity');
      String updatedActivity = (String) workOrderData.get('updatedActivity');
      Date workOrderDate = Date.valueOf(String.valueOf(workOrderData.get('workOrderDate')));

      System.debug('batchId: ' + batchId + ' workOrderId: ' + workOrderId +
      ' defaultActivity: ' + defaultActivity + ' updatedActivity: ' +
      updatedActivity + ' workOrderDate: ' + workOrderDate);

      Map<String, Object> customerDetails = (Map<String, Object>) workOrderData.get('customerDetails');
      System.debug('customerDetails datais '+ customerDetails);

      // Query the work order )
      //Id activityId = (String) workOrderData.get('activityId');

      // Step 1: Initialize variables for error messages
      String errorMessage = '';
      Batch__c batchToUse =null;

      // Step 2: Check Batch Status for batchId

      if (String.isNotBlank(batchId)) {
        List<Batch__c> batches = [
            SELECT Id, Batch_Status__c, Batch_Name__c, Batch_Date__c
            FROM Batch__c
            WHERE Id = :batchId AND Batch_Date__c = :workOrderDate AND Batch_Name__c = :defaultActivity WITH SECURITY_ENFORCED
            LIMIT 1
        ];


        if (!batches.isEmpty()) {
            // Check status even when found by batchId
            if (batches[0].Batch_Status__c == 'Sealed' ||
                batches[0].Batch_Status__c == 'Closed') {

                  DateTime batchDateTime = (DateTime) batches[0].Batch_Date__c;
                  String formattedDate = batchDateTime.format('MM/dd/yyyy', 'GMT');

                errorMessage = 'Batch "' + batches[0].Batch_Name__c +
                             '" for date "' + formattedDate +
                             '" is currently "' + batches[0].Batch_Status__c + '"';
                throw new AuraHandledException(errorMessage);
            }
            batchToUse = batches[0];
        }
     }

    // Step 3: If batch not found by ID, search by defaultActivity and date
    if (batchToUse == null && String.isNotBlank(defaultActivity) && workOrderDate != null) {
      List<Batch__c> batches = [
          SELECT Id, Batch_Status__c, Batch_Name__c, Batch_Date__c
          FROM Batch__c
          WHERE Batch_Name__c = :defaultActivity
          AND Batch_Date__c = :workOrderDate WITH SECURITY_ENFORCED
          LIMIT 1
      ];

      if (!batches.isEmpty()) {
          // Check status for batch found by defaultActivity
          if (batches[0].Batch_Status__c == 'Sealed' ||
              batches[0].Batch_Status__c == 'Closed') {

                DateTime batchDateTime = (DateTime) batches[0].Batch_Date__c;
                String formattedDate = batchDateTime.format('MM/dd/yyyy', 'GMT');

              errorMessage = 'Batch "' + batches[0].Batch_Name__c +
                           '" for date "' + Date.valueOf(formattedDate) +
                           '" is currently "' + batches[0].Batch_Status__c + '"';
              throw new AuraHandledException(errorMessage);
          }
          batchToUse = batches[0];
      }
    }

   // Step 4: Handle case when no batch is found
    if (batchToUse == null) {
      // DateTime batchDateTime = (DateTime) workOrderDate;
      // String formattedDate = batchDateTime.format('MM/dd/yyyy', 'GMT');
      // System.debug('formatted date is '+ formattedDate);
      // errorMessage = 'No batch found for Activity :  "' + defaultActivity +
      //               '" with Date "' + formattedDate + '"';
      // throw new AuraHandledException(errorMessage);

      Batch__c newBatch = new Batch__c();
          newBatch.Batch_Name__c = defaultActivity;
          newBatch.Name = defaultActivity;
          newBatch.Batch_Status__c = 'Open';
          newBatch.Batch_Date__c = workOrderDate;
          Database.insert(newBatch, AccessLevel.USER_MODE);

          System.debug(
            'Created new batch for activity: ' +
              defaultActivity +
              ' - ' +
              newBatch
          );
          batchId = newBatch.Id;
    }



      // Step 2: Update Work Order
      String selectedCustomerId = (String) workOrderData.get('selectedCustomerId');


      Contact customer = [
        SELECT
          Id,
          LastName,
          FirstName,
          MiddleName,
          Organization__c,
          Email,
          Phone,
          MailingStreet,
          MailingAddress2__c,
          MailingCity,
          MailingState,
          MailingCountry,
          MailingPostalCode
        FROM Contact
        WHERE Id = :selectedCustomerId WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      Map<String, Object> workOrderResult = createWorkOrderForCustomer(
        customer,
        workOrderData
      );

      // Step 3: Update Activities
      List<Object> rawTransactions = (List<Object>) workOrderData.get('transactions');
      if (rawTransactions != null && !rawTransactions.isEmpty()) {
        // updateActivitiesAndFees(rawTransactions);

        upsertTransactionFeeAndItem(rawTransactions, workOrderId, workOrderDate, batchId);
      }

      uploadAndLinkDocuments(workOrderData, workOrderId);

      return workOrderResult;
    } catch (AuraHandledException ahe) {
      throw ahe; // Rethrow specific errors for frontend handling
    } catch (Exception e) {
      System.debug('Error updating Work Order: ' + e.getMessage());
      throw new AuraHandledException(
        'Error updating Work Order: ' + e.getMessage()
      );
    }
  }

  private static void updateActivitiesAndFees(List<Object> transactionDataList) {
    try {
      // Lists to hold records for update
      List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();
      List<RegulatoryTrxnFee> feesToUpdate = new List<RegulatoryTrxnFee>();

      for (Object trxObj : transactionDataList) {
        if (!(trxObj instanceof Map<String, Object>)) {
          System.debug('Skipping invalid transaction format.');
          continue;
        }

        Map<String, Object> trxData = (Map<String, Object>) trxObj;
        String transactionId = (String) trxData.get('Id');
        String feeId = (String) trxData.get('tnxId'); // Assume JS sends fee ID as part of the transaction

        // Update Fee Item
        if (String.isNotBlank(transactionId)) {
          RegulatoryTrxnFeeItem feeItem = [
            SELECT
              Id,
              Name,
              Select_Activity__c,
              Select_Sub_Activity__c,
              Select_Program_Code__c,
              FeeAmount,
              Tax_Exempt__c,
              Transaction_Date__c,
              RegulatoryTrxnFeeId
            FROM RegulatoryTrxnFeeItem
            WHERE RegulatoryTrxnFeeId = :transactionId WITH SECURITY_ENFORCED
            LIMIT 1
          ];

          feeItem.Select_Activity__c = (String) trxData.get('activity');
          feeItem.Select_Sub_Activity__c = (String) trxData.get('activityCode');
          feeItem.Select_Program_Code__c = (String) trxData.get('programCode');
          feeItem.FeeAmount = trxData.containsKey('feeAmount')
            ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount')))
            : null;
          feeItem.Transaction_Date__c = trxData.containsKey('transactionDate')
            ? Date.valueOf(String.valueOf(trxData.get('transactionDate')))
            : null;
          feeItem.Tax_Exempt__c = trxData.containsKey('taxExempt')
            ? (Boolean) trxData.get('taxExempt')
            : false;

          feeItemsToUpdate.add(feeItem);
        }

        // Update Regulatory Fee
        if (String.isNotBlank(transactionId)) {
          RegulatoryTrxnFee regulatoryFee = [
            SELECT
              Id,
              Payment_Collection__c,
              Payment_Type__c,
              Card_Type__c,
              Card_Number__c,
              CK_Number__c,
              Money_Order_Number__c,
              Amount__c
            FROM RegulatoryTrxnFee
            WHERE Id = :transactionId WITH SECURITY_ENFORCED
            LIMIT 1
          ];

          regulatoryFee.Payment_Collection__c = (String) trxData.get(
            'paymentCollection'
          );
          regulatoryFee.Payment_Type__c = (String) trxData.get('paymentType');
          regulatoryFee.Card_Type__c = (String) trxData.get('cardType');
          regulatoryFee.Card_Number__c = trxData.containsKey('cardDigit') &&
            trxData.get('cardDigit') != null
            ? Decimal.valueOf(String.valueOf(trxData.get('cardDigit')))
            : null;
          regulatoryFee.CK_Number__c = trxData.containsKey('ckNumber') &&
            trxData.get('ckNumber') != null
            ? Decimal.valueOf(String.valueOf(trxData.get('ckNumber')))
            : null;
          regulatoryFee.Money_Order_Number__c = trxData.containsKey(
              'serialNumber'
            ) && trxData.get('serialNumber') != null
            ? Decimal.valueOf(String.valueOf(trxData.get('serialNumber')))
            : null;
          regulatoryFee.Amount__c = trxData.containsKey('paymentAmount') &&
            trxData.get('paymentAmount') != null
            ? Decimal.valueOf(String.valueOf(trxData.get('paymentAmount')))
            : null;

          feesToUpdate.add(regulatoryFee);
        }
      }

      // Perform batch updates
      if (!feeItemsToUpdate.isEmpty()) {
        Database.update(feeItemsToUpdate, AccessLevel.USER_MODE);
        System.debug(
          'Updated Regulatory Transaction Fee Items: ' + feeItemsToUpdate
        );
      }

      if (!feesToUpdate.isEmpty()) {
        Database.update(feesToUpdate, AccessLevel.USER_MODE);

        System.debug('Updated Regulatory Transaction Fees: ' + feesToUpdate);
      }
    } catch (Exception e) {
      System.debug('Error updating activities and fees: ' + e.getMessage());
      throw new AuraHandledException(
        'Error updating activities and fees: ' + e.getMessage()
      );
    }
  }

  private static void updateActivities(List<Object> transactionDataList) {
    try {
      List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();

      for (Object trxObj : transactionDataList) {
        if (!(trxObj instanceof Map<String, Object>)) {
          System.debug('Skipping invalid transaction format.');
          continue;
        }

        Map<String, Object> trxData = (Map<String, Object>) trxObj;
        String transactionId = (String) trxData.get('Id');

        if (String.isNotBlank(transactionId)) {
          // Fetch the existing transaction fee item for update
          RegulatoryTrxnFeeItem feeItem = [
            SELECT
              Id,
              Name,
              Select_Activity__c,
              Select_Sub_Activity__c,
              Select_Program_Code__c,
              FeeAmount,
              Tax_Exempt__c,
              Transaction_Date__c,
              RegulatoryTrxnFeeId
            FROM RegulatoryTrxnFeeItem
            WHERE Id = :transactionId WITH SECURITY_ENFORCED
            LIMIT 1
          ];

          // Map fields from the transaction data
          feeItem.Select_Activity__c = (String) trxData.get('activity');
          feeItem.Select_Sub_Activity__c = (String) trxData.get('activityCode');
          feeItem.Select_Program_Code__c = (String) trxData.get('programCode');
          feeItem.FeeAmount = trxData.containsKey('feeAmount')
            ? Decimal.valueOf(String.valueOf(trxData.get('feeAmount')))
            : null;
          feeItem.Transaction_Date__c = trxData.containsKey('transactionDate')
            ? Date.valueOf(String.valueOf(trxData.get('transactionDate')))
            : null;
          feeItem.Tax_Exempt__c = trxData.containsKey('taxExempt')
            ? (Boolean) trxData.get('taxExempt')
            : false;

          feeItemsToUpdate.add(feeItem);
        } else {
          System.debug('Skipping transaction without valid Id: ' + trxData);
        }
      }

      // Perform batch update
      if (!feeItemsToUpdate.isEmpty()) {
        Database.update(feeItemsToUpdate,AccessLevel.USER_MODE);
        System.debug(
          'Updated Regulatory Transaction Fee Items: ' + feeItemsToUpdate
        );
      }
    } catch (Exception e) {
      System.debug(
        'Error updating Regulatory Transaction Fee Items: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Error updating Regulatory Transaction Fee Items: ' + e.getMessage()
      );
    }
  }

  // Helper class for File Info
  public class FileInfo {
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String documentId { get; set; }
    @AuraEnabled
    public String versionId { get; set; }
    @AuraEnabled
    public String Id { get; set; }

    public FileInfo(
      String title,
      String documentId,
      String versionId,
      String Id
    ) {
      this.title = title;
      this.documentId = documentId;
      this.versionId = versionId;
      this.Id = Id;
    }
  }

  @AuraEnabled
  public static string createRefundTransaction(String refundTransactionJSON) {
    System.debug('refundTransactionJSON: ' + refundTransactionJSON);

    try {

      List<Object> refundTransactions = (List<Object>)JSON.deserializeUntyped(refundTransactionJSON);

      // System.debug('refund transaction is '+ refundTransactions);

      Map<String, Object> refundTransactionData = (Map<String, Object>)refundTransactions[0];

      System.debug('refund transaction data is '+ refundTransactionData);

      String recordId = (String) refundTransactionData.get('wordOrderId');
      String selectedRefundCard = (String) refundTransactionData.get('selectedRefundCard');
      String batchId = (String) refundTransactionData.get('batchId');
      String refundMethod = (String) refundTransactionData.get('refundMethod');
      Date refundDate = refundTransactionData.containsKey('refundDate')
        ? Date.valueOf((String) refundTransactionData.get('refundDate'))
        : null;
      String voucherId = (String) refundTransactionData.get('voucherId');

      String transactionType = (String) refundTransactionData.get(
        'transactionType'
      );
      String refundReason = (String) refundTransactionData.get('refundReason');

        Map<String, List<RegulatoryTrxnFee>> feesByRecordType = new Map<String, List<RegulatoryTrxnFee>>();
        Map<String, Decimal> totalAmountByRecordType = new Map<String, Decimal>();

        List<RegulatoryTrxnFee> existingFees = [
            SELECT Id, RecordType.DeveloperName, TotalFeeAmount
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :recordId WITH SECURITY_ENFORCED
        ];

        // Categorize fees by record type and calculate totals
        for(RegulatoryTrxnFee fee : existingFees) {
            String recordTypeName = fee.RecordType.DeveloperName;

            // Initialize lists and totals if not exists
            if(!feesByRecordType.containsKey(recordTypeName)) {
                feesByRecordType.put(recordTypeName, new List<RegulatoryTrxnFee>());
                totalAmountByRecordType.put(recordTypeName, 0);
            }

            // Add fee to appropriate list
            feesByRecordType.get(recordTypeName).add(fee);

            // Update total amount
            Decimal currentTotal = totalAmountByRecordType.get(recordTypeName);
            totalAmountByRecordType.put(recordTypeName, currentTotal + (fee.TotalFeeAmount != null ? fee.TotalFeeAmount : 0));
        }

        // Calculate maximum possible refund
        Decimal totalNewTransactions = totalAmountByRecordType.get('New_Transaction') != null ?
            totalAmountByRecordType.get('New_Transaction') : 0;
        Decimal totalRefunds = totalAmountByRecordType.get('Refund_Transaction') != null ?
            totalAmountByRecordType.get('Refund_Transaction') : 0;
        Decimal maxPossibleRefund = totalNewTransactions - totalRefunds;

        System.debug('Total New Transactions: ' + totalNewTransactions);
        System.debug('Total Refunds: ' + totalRefunds);
        System.debug('Maximum Possible Refund: ' + maxPossibleRefund);

        Decimal refundAmount = refundTransactionData.containsKey('refundAmount')? Decimal.valueOf((String) refundTransactionData.get('refundAmount')): 0;


         // Validate refund amount
         if(refundAmount > maxPossibleRefund) {
          String errorMsg = 'Refund amount $' + refundAmount +
        ' exceeds the maximum allowed refund of $' + maxPossibleRefund +
        '. Total transactions: $' + totalNewTransactions +
        ', Already refunded: $' + totalRefunds;
          AuraHandledException e = new AuraHandledException(errorMsg);
          e.setMessage(errorMsg);
          throw e;
      }
          // Additional validation for card refunds
        if (selectedRefundCard != null && refundMethod == 'Card') {
            // Get the original transaction
            RegulatoryTrxnFee originalTransaction = [
                SELECT Id, TotalFeeAmount
                FROM RegulatoryTrxnFee
                WHERE Id = :selectedRefundCard WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            // Get all existing refunds for this card transaction
            List<RegulatoryTrxnFee> existingCardRefunds = [
                SELECT Id, TotalFeeAmount, Related_to_Transaction__c
                FROM RegulatoryTrxnFee
                WHERE RecordType.DeveloperName = 'Refund_Transaction'
                AND Related_to_Transaction__c = :selectedRefundCard WITH SECURITY_ENFORCED
            ];

            // Calculate total already refunded for this card
            Decimal totalCardRefunds = 0;
            for(RegulatoryTrxnFee refund : existingCardRefunds) {
                totalCardRefunds += (refund.TotalFeeAmount != null ? refund.TotalFeeAmount : 0);
            }

            // Calculate maximum possible refund for this card
            Decimal originalAmount = originalTransaction.TotalFeeAmount != null ? originalTransaction.TotalFeeAmount : 0;
            Decimal maxCardRefund = originalAmount - totalCardRefunds;

            System.debug('Original amount: ' + originalAmount);
            System.debug('Total card refunds: ' + totalCardRefunds);
            System.debug('Maximum card refund: ' + maxCardRefund);

            // Validate card refund amount
            if(refundAmount > maxCardRefund) {
              String errorMsg = 'Card refund amount $' + refundAmount +
              ' exceeds the maximum allowed refund of $' + maxCardRefund +
              ' for this card transaction. Original amount: $' + originalAmount +
              ', Already refunded: $' + totalCardRefunds;
                AuraHandledException e = new AuraHandledException(errorMsg);
                e.setMessage(errorMsg);
                throw e;
            }
        }

      Id feeRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

      RegulatoryTrxnFee regulatoryFee = new RegulatoryTrxnFee();
      if (feeRecordTypeId != null) {
        regulatoryFee.RecordTypeId = feeRecordTypeId;
        regulatoryFee.ParentRecordId = recordId;
        regulatoryFee.Transaction_Status__c = 'Completed';
        regulatoryFee.Status = 'Draft';
        if(refundMethod == 'Card'){
          regulatoryFee.Related_to_Transaction__c = selectedRefundCard;
        }

        // Add all additional fields to Fee
        regulatoryFee.Payment_Type__c = refundMethod;
        regulatoryFee.Transaction_Date__c = refundDate;
        regulatoryFee.Refund_Voucher_ID__c = voucherId;
        regulatoryFee.Refund_Reason__c = refundReason;
        regulatoryFee.amount__c = refundAmount;
        regulatoryFee.Batch_Look_Up__c = batchId;

        Database.insert (regulatoryFee, AccessLevel.USER_MODE);
      }

      // Step 2: Create a Regulatory Transaction Fee Item Record
      Id feeItemRecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          SObjectType = 'RegulatoryTrxnFeeItem'
          AND DeveloperName = 'Refund_Transaction' WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .Id;

      RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem();
      feeItem.RecordTypeId = feeItemRecordTypeId;
      feeItem.RegulatoryTrxnFeeId = regulatoryFee.Id;
      feeItem.FeeAmount = refundAmount;
      feeItem.Name = regulatoryFee.Id;

      // Add all additional fields to Fee Item
      feeItem.Payment_Type__c = refundMethod;
      feeItem.Transaction_Date__c = refundDate;
      feeItem.Refund_Voucher_ID__c = voucherId;
      feeItem.Refund_Reason__c = refundReason;


      Database.insert(feeItem, AccessLevel.USER_MODE);

      return recordId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String updateRefundTransaction(String refundTransactionJSON) {
  System.debug('refundTransactionJSON: ' + refundTransactionJSON);

  try {
      // Deserialize the JSON to a list of maps
      List<Object> refundTransactions = (List<Object>)JSON.deserializeUntyped(refundTransactionJSON);
      System.debug('refundTransactions: ' + refundTransactions);


      // Collect IDs to validate records in the database
      Set<Id> feeIds = new Set<Id>();

        // Collect all fee IDs and map them to their refund reasons
        Map<Id, String> feeToReasonMap = new Map<Id, String>();
        for (Object trans : refundTransactions) {
            Map<String, Object> trxn = (Map<String, Object>)trans;
            if (trxn.containsKey('id')) {
                Id feeId = (Id)trxn.get('id');
                String refundReason = (String)trxn.get('refundReason');
                feeIds.add(feeId);
                feeToReasonMap.put(feeId, refundReason);
            }
        }

        // Query for both Fee and Fee Items in one go
        List<RegulatoryTrxnFee> feesToUpdate = [
            SELECT Id, Refund_Reason__c,
                (SELECT Id, Refund_Reason__c FROM RegulatoryTrxnFeeItems
                 WHERE RecordType.DeveloperName = 'Refund_Transaction')
            FROM RegulatoryTrxnFee
            WHERE Id IN :feeIds WITH SECURITY_ENFORCED
        ];

        System.debug('fees to update '+ feesToUpdate);

        List<RegulatoryTrxnFeeItem> feeItemsToUpdate = new List<RegulatoryTrxnFeeItem>();

        // Update both Fee and Fee Items
        for (RegulatoryTrxnFee fee : feesToUpdate) {
            String newReason = feeToReasonMap.get(fee.Id);
            fee.Refund_Reason__c = newReason;

            // Update related fee items
            for (RegulatoryTrxnFeeItem feeItem : fee.RegulatoryTrxnFeeItems) {
                feeItem.Refund_Reason__c = newReason;
                feeItemsToUpdate.add(feeItem);
            }
        }
        System.debug('feeItemsToUpdate: ' + feeItemsToUpdate);

      // Perform updates
        if (!feesToUpdate.isEmpty()) {
          Database.update(feesToUpdate,AccessLevel.USER_MODE);
       }
        if (!feeItemsToUpdate.isEmpty()) {
          Database.update(feeItemsToUpdate, AccessLevel.USER_MODE);
      }

      return 'Success';
  } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
  }
}



// method written for fetch data of WOrk Order Object related to BRS.
@AuraEnabled(cacheable= true)
public static Map<String ,Object> getBRSdata(String recordId){
    Map<String, Object> brsData = new Map<String, Object>();
    Work_Order__c  workOrder  = [SELECT Id,Status__c,CreatedDate,Type__c,Customer__r.FirstName, Customer__r.LastName,Customer__r.MiddleName, Customer__r.Organization__c,
                                   Customer__r.Email,Customer__r.Phone, Customer__r.Customer_Account_Balance__c,
                                   Customer__r.MailingStreet, Customer__r.MailingCity, Customer__r.MailingState, Customer__r.MailingPostalCode, Customer__r.MailingCountry FROM Work_Order__c
                                   WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
    List<bt_stripe__Transaction__c> transactionData = [ SELECT Id, Work_Order__c, bt_stripe__Payment_Method__c, bt_stripe__Payment_Method__r.bt_stripe__Funding__c, bt_stripe__Payment_Method__r.bt_stripe__Brand__c,
                                  bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c,bt_stripe__Payment_Method__r.RecordType.DeveloperName,bt_stripe__Amount__c
                                FROM bt_stripe__Transaction__c
                                WHERE Work_Order__c = :recordId WITH SECURITY_ENFORCED];


      Map<String, String> typeMap = new Map<String, String>{
        'UCC' => 'UCC Filing',
        'Business' => 'Business Filing'
      };



    List<Map<String, Object>> transactionList = new List<Map<String, Object>>();
    for (bt_stripe__Transaction__c trxn : transactionData) {
        Map<String, Object> transactionMap = new Map<String, Object>();
        transactionMap.put('id', trxn.Id);
        transactionMap.put('category',workOrder.Type__c !=null ? typeMap.get(workOrder.Type__c) : '' );
        transactionMap.put('paymentMethodId', trxn.bt_stripe__Payment_Method__c);
        transactionMap.put('funding', trxn.bt_stripe__Payment_Method__r.bt_stripe__Funding__c);
        transactionMap.put('brand', trxn.bt_stripe__Payment_Method__r.bt_stripe__Brand__c);
        transactionMap.put('cardLast4Digits', trxn.bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c);
        transactionMap.put('recordType', trxn.bt_stripe__Payment_Method__r.RecordType.DeveloperName);
        transactionMap.put('amount', trxn.bt_stripe__Amount__c);
        transactionList.add(transactionMap);
    }
      brsData.put('transactions', transactionList);

      brsData.put('status',workOrder.Status__c);
      brsData.put('createdDate',workOrder.CreatedDate);
      brsData.put('customerFirstName',workOrder.Customer__r.FirstName);
      brsData.put('customerLastName',workOrder.Customer__r.LastName);
      brsData.put('customerMiddleName',workOrder.Customer__r.MiddleName);
      brsData.put('customerOrganization',workOrder.Customer__r.Organization__c);
      brsData.put('customerEmail',workOrder.Customer__r.Email);
      brsData.put('customerPhone',workOrder.Customer__r.Phone);
      brsData.put('customerAccountBalance',workOrder.Customer__r.Customer_Account_Balance__c);
      brsData.put('mailingStreet',workOrder.Customer__r.MailingStreet);
      brsData.put('mailingCity',workOrder.Customer__r.MailingCity);
      brsData.put('mailingState',workOrder.Customer__r.MailingState);
      brsData.put('mailingPostalCode',workOrder.Customer__r.MailingPostalCode);
      brsData.put('mailingCountry',workOrder.Customer__r.MailingCountry);

      return brsData;
  }
}