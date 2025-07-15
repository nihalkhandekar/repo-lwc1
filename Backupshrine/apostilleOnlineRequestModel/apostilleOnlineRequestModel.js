import {  track, api, wire } from "lwc";
import LightningModal from "lightning/modal";
import ADDRESS_STYLES from "@salesforce/resourceUrl/addressStyles"; // Static Resource
import {  loadStyle } from "lightning/platformResourceLoader";
import NewpopupOnlineRequestModel from "@salesforce/resourceUrl/newpopupOnlineRequestModel";
import stateExtradition from "@salesforce/resourceUrl/stateExtradition";
import getDocumentTypesAndFees from "@salesforce/apex/DocumentTypeFeeController.getDocumentTypesAndFees";
import getCountryHagueMappings from "@salesforce/apex/DocumentTypeFeeController.getCountryHagueMappings";
import deleteFile from "@salesforce/apex/FileUploaderClass.deleteFile"; // Ensure you have an Apex method to handle deletion
import uploadFiles from "@salesforce/apex/FileUploaderClass.uploadFiles";
import getIndividualApplicationDetails from "@salesforce/apex/OnlineRequestSubmissionController.getIndividualApplicationDetails";
import ApostillePrintSubmissionDocumentV2 from "c/apostillePrintSubmissionDocumentV2";
import generateJsonFromChecklistItemsByParentId from '@salesforce/apex/DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc';
import PrintPaymentReceiptModal2 from "c/printPaymentReceiptModal2";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import DocumentChecklistItem_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import REJECTION_REASON_FIELD from '@salesforce/schema/DocumentChecklistItem.RejectionReason__c';
import ContactSearchModal from 'c/contactSearchModal';
import getStateSealStaffData from '@salesforce/apex/OnlineRequestSubmissionController.getStateSealStaffData';
import {NavigationMixin} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import updateAllData from '@salesforce/apex/OnlineRequestSubmissionController.updateAllData';
import getRelatedFilesByRecordId from '@salesforce/apex/FileUploaderClass.getRelatedFilesByRecordId';

export default class ApostilleOnlineRequestModel extends NavigationMixin(LightningModal) {
  // ---------------------------------- Header Function ----------------------------- //
  @track isReadOnly = false;
  @track isModelOpen = true;
  @track AutorityOptions = [];
  @track mode = '';
  @track isCardPayment;
  @track recordId;
  @track workOrderNumber;
  @track isLoading = true;

  @wire(CurrentPageReference)
  pageRef({ state }) {
    console.log('state dats is '+JSON.stringify(state));

      if (state && state.c__record) {
          this.recordId = state.c__record;
          this.mode = state.c__mode;
          if(this.mode === "edit")
            this.isReadOnly = false;
          console.log('record id is and mode is  '+ this.recordId +' '+this.mode);
          this.refreshData();
        //  this.mode = JSON.parse(state.mode);
      }
  }



  get headerText() {
    if (!this.idofrecord) {
      return "View Apostille Request";
    }
    return this.isReadOnly
      ? "View Apostille Request"
      : "Process Apostille Request";
  }

  handleEditClick() {
    this.isReadOnly = false;
  }

  isRemoveButtonVisible(index) {
    return index > 0;
  }

  goBackModal() {
    try {
      // Navigate to the RecordDetail component and pass the recordId
      this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
              componentName: 'c__apostilleOnlineRequest'  // The target component name
          }
      });

  } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
  }
  }

  // get workOrderNumber() {
  //   return this.isReadOnly ? '' : 'e.g 2023-10117';
  // }

  get lastNamePlaceholder() {
    return this.isReadOnly ? '' : 'e.g Doe';
  }

  // get firstName() {
  //   return this.isReadOnly ? '' : 'e.g John';
  // }

  // get organizationName() {
  //   return this.isReadOnly ? '' : 'Enter organization name';
  // }

  // get emailAddress() {
  //   return this.isReadOnly ? '' : 'e.g johndoe@gmail.com';
  // }
  // get phoneNumber() {
  //   return this.isReadOnly ? '' : 'e.g (123) 456-7890';
  // }
  get wordOrderStatus() {
    return this.isReadOnly ? '' : 'Select status';
  }

  get selectCountry() {
    return this.isReadOnly ? '' : 'Select Country';
  }

  get documentType() {
    return this.isReadOnly ? '' : 'select Document';
  }

  get destinationCountry() {
    return this.isReadOnly ? '' : 'Destination country';
  }

  get personName() {
    return this.isReadOnly ? '' : 'Enter Name of Person';
  }

  get copyNumberPlaceholder(){
    return this.isReadOnly ? '' : 'Enter Copy Number';
  }

  // get businessName() {
  //   return this.isReadOnly ? '' : 'Acme Corporation';
  // }
  // get firstNameindividual() {
  //   return this.isReadOnly ? '' : 'William';
  // }

  // get lastNameindividual() {
  //   return this.isReadOnly ? '' : 'Smith';
  // }

  // get emailAddressindividual() {
  //   return this.isReadOnly ? '' : 'william.smith@gmail.com';
  // }

  // get cellPhoneNumber() {
  //   return this.isReadOnly ? '' : '(555) 567-7890';
  // }

  // get emailReceivingApostille() {
  //   return this.isReadOnly ? '' : 'william.smith@gmail.com';
  // }

  get paymentTypePlaceHolder() {
    return this.isReadOnly ? '' : 'Credit Card';
  }

  get Visa() {
    return this.isReadOnly ? '' : 'Visa';
  }

  get last4DigitsPlaceHolder() {
    return this.isReadOnly ? '' : '3421';
  }


  get paymentAmounPlaceHoldert() {
    return this.isReadOnly ? '' : '$220.00';
  }

  // get fedEx() {
  //   return this.isReadOnly ? '' : '1234 5678 9012';
  // }

  // get modifiedBy() {
  //   return this.isReadOnly ? '' : 'john Doe';
  // }

  // get ModifiedDate() {
  //   return this.isReadOnly ? '' : 'mm/dd/yyyy';
  // }

  // -------------------------------------------- Initial Method -------------------------------- //


  connectedCallback() {
    console.log('connectedCallback is working with'+ this.recordId);


    Promise.all([
      loadStyle(this, ADDRESS_STYLES),
      loadStyle(this, NewpopupOnlineRequestModel),
      loadStyle(this, stateExtradition)
    ])
      .then(() => {
        console.log("CSS file loaded successfully");

      })
      .catch((error) => {
        console.error("Error loading CSS file:", error);
      });


  //  this.initializeData();
    this.processFiles();
  }

  refreshData(){
    console.log('refresh data function is being called');

    this.initializeData();
  }

  initializeData() {
    this.isLoading = true;
    if (this.mode === "view") {
        this.isReadOnly = true;
    } else if (!this.recordId) {
        this.isReadOnly = false;
        this.showSaveData();
    }

    if (this.recordId) {
        this.idofrecord = this.recordId;
        }

    this.fetchStaffData();
    this.fetchData();
}

 async fetchData() {
    setTimeout(() => {
     // this.fetchRecordDetails();
    //  this.initializeComponent();
    //  this.updateExpediteRadioButton();
        this.isLoading = false;
    }, 1000); // Simulate loading time

   // await refreshApex(this.wiredIndividualData);
      console.log('refreshMethod is being called');

      refreshApex(this.wiredIndividualData);
      refreshApex(this.wiredDocumentData);

  }

  fetchStaffData() {
    getStateSealStaffData()
        .then((result) => {
            const allowedTitles = ['Deputy Secretary of the State', 'Secretary of the State'];
            this.AutorityOptions = result
            .filter(staff => allowedTitles.includes(staff.Staff_Title__c))
            .map(staff => ({
                label: `${staff.FirstName} ${staff.LastName}, ${staff.Staff_Title__c}`,
                value:  staff.Id
            }));
            console.log('SignedBy options:', JSON.stringify(this.AutorityOptions));
        })
        .catch((error) => {
            console.error('Error fetching staff data: ', error);
        });
}
  @track recordDetailsList ;

//  async fetchRecordDetails() {
//     getIndividualApplicationDetails({ recordId: this.recordId })
//       .then((result) => {
//         this.workOrderNumber = result.Sequence_Number__c;
//         this.lastName = result.Last_Name__c;
//         this.firstName = result.First_Name__c;
//         this.organizationName = result.Organization_Name__c;
//         this.emailAddress = result.Email_Address__c;
//         this.phoneNumber = result.Cell_Phone_Number__c;
//         this.workOrderStatus = result.Status;

//         this.addressLine1 = result.Address_Line_1_Shipping__c;
//         this.suite = result.Suite_Apartment_Floor_Shipping__c;
//         this.city = result.City_Shipping__c;
//         this.state = result.State_Shipping__c;
//         this.zipCode = result.Zip_Code_Shipping__c;
//         this.country = result.Country_Shipping__c;

//         this.businessName = result.Agency_Business_Name__c;
//         this.firstNameindividual = result.Agency_First_Name__c;
//         this.lastNameindividual = result.Agency_Last_Name__c;
//         this.emailAddressindividual = result.Agency_Email_Address__c;
//         this.cellPhoneNumber = result.Agency_Cell_Phone__c;
//         this.emailReceivingApostille =result.Email_Address_For_Receiving_Apostille__c;

//         this.selectedCountry = result.documentDestinationCountry__c;
//         this.selectedHagueStatus = result.HagueStatus__c;
//         this.destinationCountrySameString = result.Destination_Country__c;
//         this.destinationCountrySame = result.documentDestinationCountryBoolean__c;
//         this.expedite =  result.Expedited__c;
//         this.expediteRequest = result.Expedite_Request_Boolean__c;
//         this.expediteRequestString = result.Expedite_Request__c;

//         this.shippingMethod = result.Return_Mail_Type__c;
//         this.fedEx = result.FedEX__c;
//         this.pre_paid_shipping_label = result.e_Apostille_document_has_been_uploaded__c;
//         this.documentPickedUp = result.ReturnMailDocument_s_will_be_picked_up__c;
//         this.e_Apostille_customer_upload = result.return_Mail_e_Apostille_Customer__c;
//         this.modifiedBy = result.LastModifiedBy.Name;
//         this.ModifiedDate = result.LastModifiedDate;
//         this.additionalServiceRequest = result.Instructions__c;
//         this.notes = result.Notes_on_Receipt__c;
//         this.memo = result.Receipt_Memo__c;
//         // Continue mapping as needed...
//       //  this.updateExpediteRadioButton();

//       })
//       .catch((error) => {
//         console.error("Error fetching record details:", error);
//       });
//       // console.log(' and work order no is '+ this.workOrderNumber);

//       console.log('now corrent status value is '+ this.workOrderStatus);

//   }

  // updateExpediteRadioButton(){
  //   this.isExpediteSelected = this.expediteRequest ? true : false;
  //   this.isNotExpediteSelected = !this.expediteRequest ? true : false;

  //   console.log('updated values for isExpediteSelected ' ,this.isExpediteSelected , 'and isNotExpediteSelected values is ', this.isNotExpediteSelected);

  // }



  // Wire method to fetch record details

  wiredIndividualData
  @wire(getIndividualApplicationDetails, { recordId: '$recordId' })
  wiredRecordDetails(result) {
  this.wiredIndividualData = result;
  const { data, error } = result;
    if (data) {
      console.log('woring fine');

      const checkStatusAsOrderComplete = data.Status ? data.Status.includes('Order Complete') : false;
      const modifiedData = { ...data, checkStatusAsOrderComplete };

        // const modifiedData = { ...data, checkStatusAsOrderComplete: data.Status.includes('Order Complete') };
        console.log('woring fine till');

        console.log('Fetched and modifiedData  Record Details:', JSON.stringify(modifiedData));
        console.log('woring fine till here');

        this.recordDetailsList = [modifiedData];
        this.assignRecordDetails(modifiedData);

       // console.log('Record Details List:', JSON.stringify(this.recordDetailsList));
    } else if (error) {
        console.error('Error fetching record details:', error);
        this.recordDetailsList = [];
    }
}

@track checkStatusAsOrderComplete = false;

assignRecordDetails(recordDetails) {
    this.workOrderNumber = recordDetails.Sequence_Number__c;
    this.lastName = recordDetails.Last_Name__c;
    this.firstName = recordDetails.First_Name__c;
    this.organizationName = recordDetails.Organization_Name__c;
    this.emailAddress = recordDetails.Email_Address__c;
    this.phoneNumber = recordDetails.Cell_Phone_Number__c;
    this.workOrderStatus = recordDetails.Status;

    this.addressLine1 = recordDetails.Address_Line_1_Shipping__c;
    this.suite = recordDetails.Suite_Apartment_Floor_Shipping__c;
    this.city = recordDetails.City_Shipping__c;
    this.state = recordDetails.State_Shipping__c;
    this.zipCode = recordDetails.Zip_Code_Shipping__c;
    this.country = recordDetails.Country_Shipping__c;

    this.businessName = recordDetails.Agency_Business_Name__c;
    this.firstNameindividual = recordDetails.Agency_First_Name__c;
    this.lastNameindividual = recordDetails.Agency_Last_Name__c;
    this.emailAddressindividual = recordDetails.Agency_Email_Address__c;
    this.cellPhoneNumber = recordDetails.Agency_Cell_Phone__c;
    this.emailReceivingApostille = recordDetails.Email_Address_For_Receiving_Apostille__c;

    this.selectedCountry = recordDetails.documentDestinationCountry__c;
    this.selectedHagueStatus = recordDetails.HagueStatus__c;
    this.destinationCountrySameString = recordDetails.Destination_Country__c;
    this.destinationCountrySame = recordDetails.documentDestinationCountryBoolean__c;
    this.expedite = recordDetails.Expedited__c;
    this.expediteRequest = recordDetails.Expedite_Request_Boolean__c;
    this.expediteRequestString = recordDetails.Expedite_Request__c;

    this.shippingMethod = recordDetails.Return_Mail_Type__c;
    this.fedEx = recordDetails.FedEX__c;
    this.pre_paid_shipping_label = recordDetails.e_Apostille_document_has_been_uploaded__c;
    this.documentPickedUp = recordDetails.ReturnMailDocument_s_will_be_picked_up__c;
    this.e_Apostille_customer_upload = recordDetails.return_Mail_e_Apostille_Customer__c;

    this.modifiedBy = recordDetails.LastModifiedBy?.Name;
    this.ModifiedDate = recordDetails.LastModifiedDate;
    this.additionalServiceRequest = recordDetails.Instructions__c;
    this.notes = recordDetails.Notes_on_Receipt__c;
    this.memo = recordDetails.Receipt_Memo__c;
    this.checkStatusAsOrderComplete = recordDetails.checkStatusAsOrderComplete;
}






  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.value === "" || event.target.value === null
        ? null
        : event.target.value;
    this[field] = value;
    console.log("field", field, value);
    console.log('status....',this.status);

  }


  // ----------------------------  Apostille Request Details -------------------------- //

  @track lastName;
  @track firstName;
  @track organizationName;
  @track emailAddress;
  @track phoneNumber;
  @track workOrderStatus;

  apostilleStatusOptions = [
    { label: "Submitted", value: "Submitted" },
    { label: "Documents Received", value: "Documents Received" },
    { label: "Cancelled By Staff", value: "Cancelled By Staff" },
    { label: "Cancelled By Customer", value: "Cancelled By Customer" },
    { label: "Order Completed - Mail", value: "Order Completed - Mail" },
    { label: "Order Completed – Pick Up", value: "Order Completed – Pick Up" }
  ];



  // ---------------------------- Work Order Transaction --------------------------------- //


  // @track isReadOnly = false;
  @track expediteRequest = false;
  @track expedite;
  @track expediteRequestString = "no";
  @track destinationCountrySame = false ;
  @track sameAddressString = "no";
  @track destinationCountrySameString ;
  @track selectedCountry;
  @track selectedHagueStatus = "";
  @track oldDocumentsJson = "";
  @track newDocumentsJson = "";
  @track totalAmount;
  @track documents = [];
  @track documentTypes = [];
  @track documentFees = {};
  @track expediteFee = "99.00";
  @track countryOptions = [];
  @track hagueMapping = {};
  @track radioCssDes = "radioOptions";
  @track radioCssCheckedDes = "radioOptionsChecked";
  @track radioCssExp = "radioOptions";
  @track radioCssCheckedExp = "radioOptionsChecked";
  @track radioCssCon = "radioOptions";
  @track radioCssCheckedCon = "radioOptionsChecked";
  @track uploadedFiles = [];
  @track signedByPositionOptions = [];
  // @track statusOptions = [];
  @track documentsForPrintCertificate = [];

  @track selectedFileId = null;
  @track selectedFileName = null;
  @track selectedDocId = null;
  // @track isExpediteSelected = false;
  // @track isNotExpediteSelected = false;

  recordTypeId;

  @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
  contactObjectInfo({ error, data }) {
    if (data) {
        // Specify the record type by DeveloperName (e.g., 'Specific_Record_Type')
        const recordTypeName = 'Apostille Official'; // Change this to your desired record type
        const recordTypes = data.recordTypeInfos;
       // console.log('recordTypes'+JSON.stringify(recordTypes));


        // Find the RecordTypeId of the desired record type
        for (const key in recordTypes) {
            if (recordTypes[key].name === recordTypeName || recordTypes[key].developerName === recordTypeName) {
                this.recordTypeId = recordTypes[key].recordTypeId;
                console.log('recordTypeName :=>',recordTypeName, ' recordTypeId is :=>',this.recordTypeId);
                break;
            }
        }

        if (!this.recordTypeId) {
            console.error(`Record Type '${recordTypeName}' not found for Contact object.`);
        }
    } else if (error) {
        console.error('Error fetching Contact object info', error);
    }
  }

  @wire(getObjectInfo, { objectApiName: DocumentChecklistItem_OBJECT })
  documentChecklistItemObjectInfo;


  @wire(getPicklistValues, {
      recordTypeId: '$recordTypeId',
      fieldApiName: POSITION_FIELD
  })
  positionPicklistValues({ error, data }) {
      if (data) {
          this.signedByPositionOptions = data.values.map(picklistOption => ({
              label: picklistOption.label,
              value: picklistOption.value
          }));
          // console.log('position value are :=>'+ JSON.stringify(this.signedByPositionOptions));
          // const values = this.signedByPositionOptions.map(option => option.value);

          // console.log('Extracted values:', values);

      } else if (error) {
          console.error('Error fetching signed by values', error);
          this.signedByPositionOptions = [];
      }
  }

    // Fetch Status picklist values
    //  @wire(getPicklistValues, {
    //     recordTypeId: '$documentChecklistItemObjectInfo.data.defaultRecordTypeId',
    //     fieldApiName: STATUS_FIELD
    // })
    // statusPicklistValues({ error, data }) {
    //     if (data) {
    //         this.statusOptions = data.values.map(picklistOption => ({
    //             label: picklistOption.label,
    //             value: picklistOption.value
    //         }));
    //     } else if (error) {
    //         console.error('Error fetching status values', error);
    //         this.statusOptions = [];
    //     }
    // }

  statusOptions = [
    { label: "Submitted", value: "Submitted" },
    { label: "Rejected", value: "Rejected" },
    { label: "Approved", value: "Approved" },
    { label: "Pending Documents", value: "Pending" }
  ];

  //  async initializeComponent() {
  //     generateJsonFromChecklistItemsByParentId({ individualApplicationId: this.recordId })
  //         .then(result => {
  //             try {
  //                 // Parse the JSON
  //                 const parsedDocuments = JSON.parse(result);
  //                 console.log("Parsed Documents as JSON String:", JSON.stringify(parsedDocuments));

  //                 console.log('payment list is ', parsedDocuments.paymentDetails);

  //                 if (parsedDocuments.paymentDetails) {
  //                       this.paymentList = parsedDocuments.paymentDetails;
  //                   }
  //                 console.log("Payment List after filtering:", JSON.stringify(this.paymentList));

  //                 // Process documents and add statusRejected flag
  //                 this.documents = (parsedDocuments.documentChecklistItems || []).map(doc => ({
  //                     ...doc,
  //                     statusRejected: doc.status === 'Rejected'
  //                 }));
  //                 this.updateDocumentFees();
  //                 this.initializeRadioStates();
  //                 this.updateCountryFieldState();
  //             } catch (parseError) {
  //                 console.error('Error parsing documents:', parseError);
  //                 console.error('Original result:', result);
  //             }
  //         })
  //         .catch(error => {
  //             console.error('Error fetching documents:', error);
  //         });

  //     // Rest of your initialization code

  //     if (this.isReadOnly) {
  //         this.initializeReadOnlyMode();
  //     }
  // }
  wiredDocumentData
  @wire(generateJsonFromChecklistItemsByParentId, { individualApplicationId: '$recordId' })
  wiredChecklistItems(value) {
      this.wiredDocumentData = value; // Capture the wired data reference for refreshApex
      const { error, data } = value;

      if (data) {
          try {
              const parsedDocuments = JSON.parse(data);

              // Assign payment list
              this.paymentList = (parsedDocuments.paymentDetails || []).map(payment => {
                return {
                    ...payment,
                    isCardPayment: payment.paymentType === 'Card' // Add `isCardPayment` based on `paymentType`
                };
            });
              console.log("Payment List after filtering:", JSON.stringify(this.paymentList));

              // Assign document for printDocumentCertificate

              this.documentsForPrintCertificate = (parsedDocuments.documentChecklistItems || []).filter(doc => doc.status === 'Approved' || doc.status ==="Accepted")
              .map(doc => ({
                docId: doc.id,
                status: doc.status,
                personName: doc.personName,
                docType: doc.typeOfDocument,
                certificateNo: doc.certificateNumber,
                signedBy: doc.signedByName,
                signedStamp: doc.signedStamp,
                position: doc.signedByPosition,
                destination: doc.destinationCountry,
                hagueStatus: doc.hague,
                signingAuthorityName: doc.autorityName,
                signningAuthorityTitle: doc.authorityTitle,
                parentRecordId: this.recordId,
                copyNumber: doc.copyNumber
            }));

            console.log('print Document certificate data is '+ JSON.stringify(this.documentsForPrintCertificate));


              // Process documents and add statusRejected flag
              this.documents = (parsedDocuments.documentChecklistItems || []).map(doc => ({
                  ...doc,
                  statusRejected: doc.status === 'Rejected'
              }));

              // Call additional methods
              this.updateDocumentFees();
              this.initializeRadioStates();
              this.updateCountryFieldState();
          } catch (parseError) {
              console.error('Error parsing documents:', parseError);
              console.error('Original result:', data);
          }
      } else if (error) {
          console.error('Error fetching documents:', error);
      }
  }


  initializeRadioStates() {
    if (this.expediteRequest === true) {
      this.expediteRequest = true;
      this.expedite = true;
      this.expediteRequestString === "yes"
      this.radioCssExp = "radioOptionsChecked";
      this.radioCssCheckedExp = "radioOptions";
    } else {
      this.expediteRequest = false;
      this.expedite = false;
      this.expediteRequestString === "no"
      this.radioCssExp = "radioOptions";
      this.radioCssCheckedExp = "radioOptionsChecked";
    }

    // Destination Country Same
    if (this.destinationCountrySameString === "yes") {
      this.destinationCountrySame = true;
      this.radioCssDes = "radioOptionsChecked";
      this.radioCssCheckedDes = "radioOptions";
    } else {
      this.destinationCountrySame = false;
      this.radioCssDes = "radioOptions";
      this.radioCssCheckedDes = "radioOptionsChecked";
    }

    // Same Address
    if (this.sameAddressString === "yes") {
      this.sameAddress = true;
      this.radioCssCon = "radioOptionsChecked";
      this.radioCssCheckedCon = "radioOptions";
    } else {
      this.sameAddress = false;
      this.radioCssCon = "radioOptions";
      this.radioCssCheckedCon = "radioOptionsChecked";
    }
  }

  initializeReadOnlyMode() {
    this.documents = JSON.parse(this.documentsJson || "[]");
    console.log(
      "Readonly mode initialized with documents:",
      JSON.stringify(this.documents)
    );
    this.updateDocumentFees();
  }

  @wire(getDocumentTypesAndFees)
  wiredDocumentTypesAndFees({ error, data }) {
    if (data) {
      const filteredData = data.filter((item) => {
        if (item.Label === "Expedite") {
          this.expediteFee = item.Fee__c;
          return false;
        }
        return true;
      });

      this.documentTypes = filteredData.map((item) => ({
        label: item.Label,
        value: item.Label
      }));

      filteredData.forEach((item) => {
        this.documentFees[item.Label] = item.Fee__c;
      });

      this.updateDocumentFees();
    } else if (error) {
      console.error("Error fetching Document Types and Fees", error);
    }
  }

  @wire(getCountryHagueMappings)
  wiredCountryHagueMappings({ error, data }) {
    if (data) {
      this.countryOptions = data.map((item) => ({
        label: item.Country__c,
        value: item.Country__c
      }));

      data.forEach((item) => {
        this.hagueMapping[item.Country__c] = item.Hague_Status__c;
      });
    } else if (error) {
      console.error("Error fetching Country Hague Mappings", error);
    }
  }

  handleInputChangeDocument(event) {
    if (this.isReadOnly) return;

    const { name, value } = event.target;
    // const capitalizedValue = this.capitalizeInput(value);
    // this[name] = capitalizedValue;

    if (name === "selectedCountry") {
      console.log('country value is '+ value);
      this.selectedCountry = value;
      this.updateHagueStatus(value);
      this.updateCountryFieldState();
    }

    if (name === "destinationCountrySameString") {
      if (value === "yes") {
        this.destinationCountrySameString = "yes";
        this.destinationCountrySame = true;
        this.radioCssDes = "radioOptionsChecked";
        this.radioCssCheckedDes = "radioOptions";
        this.updateCountryFieldState();
      } else {
        this.destinationCountrySameString = "no";
        this.selectedCountry = null;
        this.selectedHagueStatus= '';
        this.destinationCountrySame = false;
        this.radioCssDes = "radioOptions";
        this.radioCssCheckedDes = "radioOptionsChecked";
        this.updateCountryFieldState();
      }
    }

    if (name === "expediteRequestString") {
      this.updateDocumentFees();

      if (value === "yes") {
        this.expediteRequestString = "yes";
        this.expediteRequest = true;
        this.expedite= true;
        this.radioCssExp = "radioOptionsChecked";
        this.radioCssCheckedExp = "radioOptions";
        this.updateDocumentFees();
      } else if (value === "no") {
        this.expediteRequestString = "no";
        this.expediteRequest = false;
        this.expedite = false;
        this.radioCssExp = "radioOptions";
        this.radioCssCheckedExp = "radioOptionsChecked";
        this.updateDocumentFees();
      }
      console.log("expecteRequest......", this.expediteRequestString , this.expediteRequest, this.expedite);
    }
  }

  updateHagueStatus(selectedCountry) {
    console.log('select Country..........',selectedCountry);

    const hagueStatus = this.hagueMapping[selectedCountry];
    console.log('haguStatus...........',hagueStatus);

    this.selectedHagueStatus = hagueStatus;
    this.updateCountryFieldState();
  }

  updateCountryFieldState() {
    console.log('Destination Country Same:', this.destinationCountrySameString);
    console.log('Selected Country:', this.selectedCountry);
    console.log('Selected Hague Status:', this.selectedHagueStatus);

    // Only update if destination country is set to be the same
    if (this.destinationCountrySameString === "yes" && this.selectedCountry) {
      console.log('Hauge value is :=> ', (this.selectedHagueStatus === "True" ? "Yes" : "No"));

      this.documents = this.documents.map((doc) => ({
          ...doc,
          country: this.selectedCountry,
          hague: this.selectedHagueStatus === "True" ? "Yes" : "No"
      }));
  }

    // this.documents = this.documents.map((doc) => {
    //   return {
    //     ...doc,
    //     country:
    //       this.destinationCountrySameString === "yes"
    //         ? this.selectedCountry
    //         : doc.country,
    //     hague:
    //       this.destinationCountrySameString === "yes"
    //         ? this.selectedHagueStatus
    //         : doc.hague ? "Yes" : "No"
    //   };
    // });
    console.log('this document when country is same..........',JSON.stringify(this.documents));

    this.updateDocumentFees();
  }

  handleAddDocument() {
    if (this.isReadOnly) return;

    console.log('selected Country is '+ this.selectCountry);
    const defaultAuthority = this.AutorityOptions.find(option =>
      option.label.toLowerCase().includes('secretary of the state')
  );

    const newDocument = {
      id: Date.now().toString(),
      typeOfDocument: "",
      country:
        this.destinationCountrySameString === "yes" ? this.selectedCountry : "",
      hague:
        this.destinationCountrySameString === "yes" ? this.selectedHagueStatus : "",
      personName: "",
      copyNumber: "",
      fee: "0.00",
      baseFee: "0.00",
      feeDisplay: "$0.00",
      signedByName: "", // Initialize to empty if it’s missing
      signedByPosition: "", // Initialize to empty if it’s missing
      selectedContactID:"",
      autority : defaultAuthority.value,
      status : "Submitted",
      termStart: null,
      termEnd: null,
      uploadedFiles:[]
    };

    newDocument.hague = newDocument.hague ? "Yes" : "No";
    console.log('this new Documents.........',newDocument);

    this.documents = [...this.documents, newDocument];
    console.log('total document length is :=>'+this.documents.length);
    console.log('document data is=>'+ JSON.stringify(this.documents));


    this.updateDocumentFees();
  }

  handleRemoveDocument(event) {
    if (this.isReadOnly) return;

    const id = event.currentTarget.dataset.id;

    this.documents = this.documents.filter(
      (doc) => String(doc.id) !== String(id)
    );

    console.log('after deleting row: ',JSON.stringify(this.documents));

    this.updateDocumentFees();
  }

  handleDocumentChange(event) {
    // if (this.isReadOnly) return;

    const { name, value, dataset } = event.target;
    const id = dataset.id;

    console.log('Handling change for ID:', id);
    console.log('Field name:', name, 'Value:', value);

    this.documents = this.documents.map((doc) => {
        console.log('see id is  ' + doc.id + ' currentId is :==>' + id);
        console.log('doc fields are: =>', doc);

        if (doc.id === id) {
            let updatedFee = doc.fee;
            let baseFee = doc.baseFee;
            let updatedHagueStatus = doc.hague;
            let updatedCountry = doc.country;
            let updatedPersonName = doc.personName;
            let updatedCopyNumber = doc.copyNumber;
            let updatedSignedByName = doc.signedByName;
            let updatedSignedByPosition = doc.signedByPosition;
            const updatedselectedContactID = doc.selectedContactID;
            let updatedStatus = doc.status;
            let updatedAutority = doc.autority;
            const updatedTermStart = doc.termStart;
            let updatedTermEnd = doc.termEnd;
            let updatedcheckDocumentType = doc.checkDocumentType;
            let updatedUploadedFiles = doc.uploadedFiles || [];
            const contentDocumentId = updatedUploadedFiles.length > 0 ? updatedUploadedFiles[0].documentId : null;
            let updatedStatusRejected = doc.statusRejected || false;
            let updatedRejectionReason = doc.rejectionReason || null;
            let updatedCustomerRejectionReason = doc.customerRejectionReason || null;

            switch (name) {
                case "typeOfDocument":
                    if (this.documentFees[value]) {
                        baseFee = this.documentFees[value];
                        updatedFee = baseFee;
              updatedcheckDocumentType = (value == 'SOTS Certified Copies') ? true :false;
             if(updatedcheckDocumentType == false){
              this.deleteFileById(contentDocumentId);
              updatedUploadedFiles = [];
             }}
                    break;
                case "destinationCountry":
                    if (this.hagueMapping[value] !== undefined) {
                        console.log('into checking Hague Status');
                        console.log('Hague value is :=>' + this.hagueMapping[value]);

                        updatedHagueStatus = (this.hagueMapping[value] === "True") ? "Yes" : "No";
                        if (this.destinationCountrySameString === "yes") {
                            updatedCountry = value;
                        }
                    }
                    break;
                case "personName":
                    updatedPersonName = value;
                    break;
                case "copyNumber":
                  updatedCopyNumber = value;
                  break;
                case "signedByName":
                    updatedSignedByName = value;
                    break;
                case "signedByPosition":
                    updatedSignedByPosition = value;
                    break;
                case "status":
                    if (doc.status === 'Rejected' && value !== 'Rejected') {
                        updatedStatusRejected = false;
                        updatedRejectionReason = null;
                        updatedCustomerRejectionReason = null;
                    }
                    updatedStatusRejected = (value === 'Rejected');
                    updatedStatus = value;
                    break;
          case "autority":
            updatedAutority = value;
                    break;
                case "uploadedFiles":
                    updatedUploadedFiles = [...updatedUploadedFiles, value];
                    break;
                default:
                    break;
            }

            return {
                ...doc,
                [name]: value,
                fee: updatedFee,
                baseFee,
                hague: updatedHagueStatus,
                country: updatedCountry,
                personName: updatedPersonName,
                copyNumber: updatedCopyNumber,
                signedByName: updatedSignedByName,
                signedByPosition: updatedSignedByPosition,
          selectedContactID:updatedselectedContactID,
                status: updatedStatus,
          autority: updatedAutority,
                termStart: updatedTermStart,
                termEnd: updatedTermEnd,
          checkDocumentType:updatedcheckDocumentType,
                uploadedFiles: updatedUploadedFiles,
                statusRejected: updatedStatusRejected,
                rejectionReason: updatedRejectionReason,
                customerRejectionReason: updatedCustomerRejectionReason
            };
        }
        return doc;
    });

    this.documents = [...this.documents];
    console.log('on changes updated document is ==>' + JSON.stringify(this.documents));

    this.updateDocumentFees();
}



  async handleSearch(event) {

    const docId = event.target.dataset.id;
    const currentDoc = this.documents.find(doc => doc.id === docId);
    console.log('currentDoc is ==>'+JSON.stringify(currentDoc));
    const searchKey = currentDoc.signedByName;
    const position = currentDoc.signedByPosition;



    if (searchKey) {
        console.log('search key into Parent ==>'+ searchKey);
        console.log('position is ==>'+position);

        document.body.style.overflow = 'hidden';
        try{
            if (searchKey.length >= 2) { // Only search if 2 or more characters
              const selectedContact = await ContactSearchModal.open({
                  size: 'medium',
                  description: 'Select Contact',
                  searchKey: searchKey,  // Pass search key to modal
                  position: position
              });

              if (selectedContact) {
                console.log('selected contact is'+ JSON.stringify(selectedContact));

                currentDoc.signedByName = selectedContact.Name;
                this.updateDocumentFields(docId, selectedContact.name, selectedContact.position, selectedContact.selectedContactID, selectedContact.termStart, selectedContact.termEnd);
            }
          }
        } finally {
          document.body.style.overflow = 'auto';
      }
    }
  }

   // Helper function to handle the change in signedByName
   updateDocumentFields(docId, name, position, selectedID, termStart, termEnd) {
    console.log('update document values==>>', 'selected Id is '+ selectedID , 'name is ', name ,'position is =>',position, 'Start term is ',termStart, 'End term is ',termEnd );

    // Find the document by id and update the signedByName value
    const docIndex = this.documents.findIndex(doc => doc.id === docId);
    console.log('docIndex is : =>> '+docIndex);

    if (docIndex !== -1) {
        this.documents[docIndex].signedByName = name;
        this.documents[docIndex].signedByPosition = position;
        this.documents[docIndex].selectedContactID = selectedID;
        this.documents[docIndex].termStart = termStart;
        this.documents[docIndex].termEnd = termEnd;
        this.documents = [...this.documents]; // Refresh docs to ensure reactivity
    }else {
      console.error(`Document with ID ${docId} not found in updateDocumentFields.`);
  }
  console.log('updated document list have values are '+ JSON.stringify(this.documents));

  }

  //Upload file into document

  fileData
  openfileUpload(event) {
    const file = event.target.files[0];
    const docId = event.target.closest('div').dataset.docId;
    console.log('current target row Document id is '+ docId);

    let reader = new FileReader()
    reader.onload = () => {
        const base64 = reader.result.split(',')[1];
        const filename = file.name;

        this.fileData = {
            'filename': file.name,
            'base64': base64,
            'recordId': docId
        }

        const mergeFileNameBased64 = {filename, base64};

         // Pass the file data to handleDocumentChange
         this.handleDocumentChange({
          target: {
              name: 'uploadedFiles',
              value: mergeFileNameBased64,
              dataset: { id: docId }
          }
      });

    }

    reader.onerror = () => {
      console.error("Error reading the file");
  };
    reader.readAsDataURL(file)

    console.log('fileData is '+JSON.stringify(this.fileData));

}


  get formattedTotalFee() {
    const baseTotalFee = this.documents.reduce(
      (acc, doc) => acc + parseFloat(doc.baseFee || 0),
      0
    );
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);

    const total = baseTotalFee + expediteTotalFee;

    // Store the total amount in the totalAmount variable
    this.totalAmount = total.toFixed(2);
    console.log("total amount is", this.totalAmount);

    return `$${total.toFixed(2)}`;
  }

  // get isDestinationCountrySame() {
  //   return this.destinationCountrySameString === "yes";
  // }


  get isDestinationCountrySame(){
    return this.destinationCountrySame == true;
  }

  get isNotDestinationCountrySame(){
    return this.destinationCountrySame == false;
  }

  get isHagueStatusYes() {
    return this.selectedHagueStatus === "True";
  }

  get isHagueStatusNo() {
    return this.selectedHagueStatus === "False";
  }

  get isExpediteSelected() {
   // return this.expedite == true;
   return this.expediteRequest == true;
  }
  get isNotExpediteSelected() {
   // return this.expedite == false;
   return this.expediteRequest == false;

  }

  get formattedBaseFee() {
    const baseTotalFee = this.documents.reduce(
      (acc, doc) => acc + parseFloat(doc.baseFee || 0),
      0
    );
    this.totalAmount = baseTotalFee.toFixed(2);
    console.log("total amount is", this.totalAmount);
    return `$${baseTotalFee.toFixed(2)}`;
  }

  get formattedExpediteFee() {
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);
    return `$${expediteTotalFee.toFixed(2)}`;
  }

  updateDocumentFees() {
    const isExpediteSelected = this.expediteRequest == true;

    this.documents = this.documents.map((doc) => {
      const baseFee = parseFloat(doc.baseFee || 0);
      let expediteFee = 0;
      let totalFee = baseFee;
      let feeDisplay = `$${baseFee.toFixed(2)}`;

      if (isExpediteSelected) {
        expediteFee = parseFloat(this.expediteFee);
        totalFee += expediteFee;
        feeDisplay = `$${baseFee.toFixed(2)} (+$${expediteFee.toFixed(2)})`;
      }

      return {
        ...doc,
        baseFee: baseFee.toFixed(2),
        expediteFee: expediteFee.toFixed(2),
        fee: totalFee.toFixed(2),
        feeDisplay,
        isExpedited: isExpediteSelected
      };
    });

    console.log('after handle document changes values are'+ JSON.stringify(this.documents));

  }



  // -----------------------------------------  Indivisual/Agency Mailing the Document(s) ---------------------------- //



  @track businessName;
  @track firstNameindividual;
  @track lastNameindividual;
  @track emailAddressindividual;
  @track cellPhoneNumber;
  @track emailReceivingApostille;
  @track agencysameAsContactAddressString = "No";

  get issameAsContactAddressStringChecked() {
    return this.agencysameAsContactAddressString === "Yes";
  }

  get isNotsameAsContactAddressStringChecked() {
    return this.agencysameAsContactAddressString === "No";
  }

  handleAgencySameAddress(event) {
    this.agencysameAsContactAddressString = event.target.value;
  }



  // --------------------------- Payment Details -------------------------------------------- //

  @track paymentList = [];
  @track paymentType;
  @track cardType;
  @track last4Digits;
  @track paymentAmount;

  paymentTypeOptions = [
    { label: "Card", value: "Card" },
    { label: "Check", value: "Check" }
  ];

  shippingOptions = [
    { label: "UPS", value: "UPS" },
    { label: "FedEx", value: "FedEx" },
    { label: "DHL", value: "DHL" }
  ];

  cardTypeOptions = [
    { label: "VISA", value: "VISA" },
    { label: "MASTER", value: "MASTER" },
    { label: "American Express", value: "American Express" },
    { label: "Discover", value: "Discover" }
  ];


  handleAddPayment() {
    const newPayment = {
      id: '',
      paymentType: "",
      cardType: "",
      last4Digits: "",
      ckNumber: "",
      isCardPayment: true,
      paymentAmount: "",
      showRemoveButton: true // Show button for new entries
    };
    this.paymentList.push(newPayment);
    console.log("Current Payment List:", JSON.stringify(this.paymentList));
  }

  handleRemovePayment(event) {
    const index = event.target.dataset.index; // Get the index from the button
    this.paymentList.splice(index, 1); // Remove the payment from the list
   // this.updateRemoveButtonVisibility();
    console.log("Updated Payment List:", JSON.stringify(this.paymentList));
  }

  updateRemoveButtonVisibility() {
    this.paymentList.forEach((payment, index) => {
      payment.showRemoveButton = index > 0; // Only show remove button for index > 0
    });
  }

  // Method for Payment Type field change
handlePaymentTypeChange(event) {
  const index = event.target.dataset.index; // Retrieve index of the item being modified
  const name = event.target.name;
  const value = event.target.value;
  if(name == 'paymentType'){
    if(value == 'Check'){
      this.paymentList[index].isCardPayment = false;
      this.paymentList[index].last4Digits = null;
    }else{
      this.paymentList[index].isCardPayment = true;
      this.paymentList[index].ckNumber = null;

    }
  }
  this.paymentList[index].paymentType = event.target.value;
  console.log(`Updated Payment Type at index ${index}:`, this.paymentList[index].paymentType);
}

// Method for Card Type field change
handleCardTypeChange(event) {
  const index = event.target.dataset.index; // Retrieve index of the item being modified
  this.paymentList[index].cardType = event.target.value;
  console.log(`Updated Card Type at index ${index}:`, this.paymentList[index].cardType);
}

// Method for Last 4 Digits field change
handleLast4DigitsChange(event) {
  const index = event.target.dataset.index; // Retrieve index of the item being modified
  this.paymentList[index].last4Digits = event.target.value;
  console.log(`Updated Last 4 Digits at index ${index}:`, this.paymentList[index].last4Digits);
}

// Method for Last 4 Digits field change
handleckNumberChange(event) {
  const index = event.target.dataset.index; // Retrieve index of the item being modified
  this.paymentList[index].ckNumber = event.target.value;
  console.log(`Updated Last 4 Digits at index ${index}:`, this.paymentList[index].last4Digits);
}

// Method for Payment Amount field change
handlePaymentAmountChange(event) {
  const index = event.target.dataset.index; // Retrieve index of the item being modified
  this.paymentList[index].paymentAmount = event.target.value;
  console.log(`Updated Payment Amount at index ${index}:`, this.paymentList[index].paymentAmount);
  console.log('final payment list is : '+ JSON.stringify(this.paymentList));

}




  // --------------------------------------------  Return Mail Information/ Delivery Instruction -------------------------------------//


  @track e_apostille_upload = false;
  @track showUploadLink = false;
  @track showEapostilleUploadLink = false;
  @track pre_paid_shipping_label = false;
  @track e_Apostille_customer_upload = false;
  @track showfirstOption = false;
  @track showThirdOption = false;
  @track isModalOpen = false;
  @track isModalOpen2 = false;
  // @track uploadedFiles = [];
  @track uploadedFileApostille = [];
  @track uploadedFilesID = [];
  @track uploadedFileApostilleID = [];
  @track readOnlytitleuploadedFiles = false;
  @track readOnlytitleuploadedFileApostille = false;
  @track titleuploadedFiles = [];
  @track titleuploadedFileApostille = [];
  @track newUploadedFiles = [];
  @track newUploadedFilesEApostille = [];
  @track contentVersionIds = [];
  @track shippingMethod = "";
  @track fedEx ;
  @track pre_paid_shipping_labelisReadOnly = false;
  @track fourthOptionisReadOnly = false;
  @track secondOptionisReadOnly = false;
  @track e_Apostille_customer_uploadisReadOnly = false;
  @track thirdOptionisReadOnly = false;
  @track showSelectedSubOptions = false;
  @track documentPickedUp = false;
  @track notReadOnly = true;
  @track firstOptionisReadOnly = false;
  @track isOption1Checked = false;
  @track isOption1Disabled = false;
  @track isOption2Checked = false;
  @track isOption2Disabled = false;
  @track isOption3Checked = false;
  @track isOption3Disabled = false;
  @track isOption4Checked = false;
  @track isOption4Disabled = false;
  @track dynamicLabel = "Shipping Number";
  showShippingOptions = true;
  upload2Clicked = false;
  uploadClicked = false;

  // @wire(fetchFiles, { recordId: '$recordId' })
  //   wiredFiles({ error, data }) {
  //       if (data) {
  //           this.uploadedFiles = data.map(file => ({
  //               filename: file.Title,
  //               documentId: file.ContentDocumentId
  //           }));
  //       } else if (error) {
  //           console.error('Error fetching files: ', error);
  //       }
  // }

  handleShippingMethodChange(event) {
    this.shippingMethod = event.target.value; // Update the shippingMethod property
    this.dynamicLabel = `${this.shippingMethod} #`; // Update label dynamically
    console.log(`Shipping Method updated to: ${this.shippingMethod}`);
  }

    handleFedExChange(event) {
        this.fedEx = event.target.value; // Update the fedEx property
        console.log(`${this.dynamicLabel} updated to: ${this.fedEx}`);
    }

    @wire(getRelatedFilesByRecordId, { recordId: '$recordId' })
    wiredFiles({ error, data }) {
        if (data) {
            console.log('Files data:', data);
            this.uploadedFiles = Object.keys(data).map(id => ({
                filename: data[id],
                value: id,
                versionId: id,
                url: `/sfc/servlet.shepherd/document/download/${id}`
            }));
        } else if (error) {
            console.error('Error fetching files: ', error);
        }
    }

    handlePreview(event) {
        const fileId = event.target.dataset.id;
        console.log('File ID for preview:', fileId);

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: fileId
            }
        });
    }

  get secondOption2() {
    return this.isOption2Checked
      ? "slds-form-element__label bold-text"
      : "slds-form-element__label";
  }

  get thirdOption3() {
    return this.isOption3Checked
      ? "slds-form-element__label bold-text"
      : "slds-form-element__label";
  }

  get fourthOption4() {
    return this.isOption4Checked
      ? "slds-form-element__label bold-text"
      : "slds-form-element__label";
  }

  get acceptedFormats() {
    return [".pdf", ".png"];
  }

  get showFileUpload() {
    return this.returnOptions.find((option) => option.value === "upload")
      .checked;
  }


  // handleOptionChange(event) {
  //   const selectedValue = event.target.value;
  //   this.returnOptions = this.returnOptions.map((option) => ({
  //     ...option,
  //     checked: option.value === selectedValue
  //   }));
  // }

  // handleUploadFinished(event) {
  //   const uploadedFiles = event.detail.files;
  //   this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];
  // }
  // Options for dropdown menus



  closeModal() {
    this.close("close");
  }



  openUploadModal() {
    this.isModalOpen = true;
    this.isModalOpen2 = false;
  }

  closeUploadModal() {
    this.isModalOpen = false;
    this.newUploadedFiles.forEach((file) => {
      this.uploadedFiles = this.uploadedFiles.filter(
        (f) => f.documentId !== file.documentId
      );
      deleteFile({ fileId: file.documentId }).catch((error) =>
        console.error("Error deleting file:", error)
      );
    });
    this.uploadedFiles = this.uploadedFiles.filter(
      (file) => !this.newUploadedFiles.includes(file)
    );
    if (this.uploadClicked) this.pre_paid_shipping_label = true;
  }

  openUploadModal2() {
    this.isModalOpen2 = true;
    this.isModalOpen = false;
  }

  closeUploadModal2() {
    this.isModalOpen2 = false;
    this.newUploadedFilesEApostille.forEach((file) => {
      this.uploadedFileApostille = this.uploadedFileApostille.filter(
        (f) => f.documentId !== file.documentId
      );
      deleteFile({ fileId: file.documentId }).catch((error) =>
        console.error("Error deleting file:", error)
      );
    });
    this.uploadedFileApostille = this.uploadedFileApostille.filter(
      (file) => !this.newUploadedFilesEApostille.includes(file)
    );

    if (this.upload2Clicked) this.e_Apostille_customer_upload = true;
  }

  handleUploadLinkClick(event) {
    event.preventDefault();
    this.pre_paid_shipping_label = false;
    this.openUploadModal();
  }

  handleUploadLinkClick2(event) {
    event.preventDefault();
    this.e_Apostille_customer_upload = false;
    this.openUploadModal2();
  }

  handleOptionChange(event) {
    const selectedValue = event.target.value;
    if (selectedValue === "includeReturnEnvelope") {
      this.showfirstOption = false;
      this.showThirdOption = true;
      this.isOption1Checked = true;
      this.isOption2Checked = false;
      this.isOption3Checked = false;
      this.isOption4Checked = false;
      this.showShippingOptions = true;
      this.pre_paid_shipping_label = false;
      this.e_Apostille_customer_upload = false;
      this.documentPickedUp = false;
      this.changeTodeleteeApostille();
      this.changeTodeleteprePaid();
    } else if (selectedValue === "uploadShippingLabel") {
      this.showUploadLink = true;
      // this.thirdOptionisReadOnly = true;
      this.isOption1Checked = false;
      this.isOption2Checked = true;
      this.isOption3Checked = false;
      this.isOption4Checked = false;
      this.showShippingOptions = false;

      this.pre_paid_shipping_label = true;
      this.e_Apostille_customer_upload = false;
      this.e_apostille_upload = false;
      this.showUploadLink = true;
      this.showEapostilleUploadLink = false;
      this.showfirstOption = true;
      this.showThirdOption = true;
      this.documentPickedUp = false;
      this.changeTodeleteeApostille();
    } else if (selectedValue === "eApostilleUpload") {
      this.showEapostilleUploadLink = true;
      // this.thirdOptionisReadOnly = true;
      this.isOption1Checked = false;
      this.isOption2Checked = false;
      this.isOption3Checked = false;
      this.isOption4Checked = true;
      this.showShippingOptions = false;

      this.pre_paid_shipping_label = false;
      this.e_Apostille_customer_upload = true;
      this.e_apostille_upload = true;
      this.showEapostilleUploadLink = true;
      this.showUploadLink = false;
      this.showfirstOption = true;
      this.showThirdOption = true;
      this.documentPickedUp = false;
      this.changeTodeleteprePaid();
    } else if (selectedValue === "pickup") {
      this.showThirdOption = false;
      this.showfirstOption = true;
      // this.thirdOptionisReadOnly = false;
      this.pre_paid_shipping_label = false;
      this.e_Apostille_customer_upload = false;
      this.documentPickedUp = true;
      // this.e_apostille_upload = false;
      this.isOption1Checked = false;
      this.isOption2Checked = false;
      this.isOption3Checked = true;
      this.isOption4Checked = false;
      this.showUploadLink = false;
      this.showEapostilleUploadLink = false;
      this.showShippingOptions = false;

      this.changeTodeleteeApostille();
      this.changeTodeleteprePaid();
    } else {
      this.e_apostille_upload = false;
      this.showUploadLink = false;
      this.showEapostilleUploadLink = false;
    }
  }

  get hasDocumentSelected(){
    console.log(
      "this.documentPickedUp : ",this.documentPickedUp);

    return this.documentPickedUp;
  }

  handleUploadFinished(event) {
    const files = Array.from(event.target.files);
    const filePromises = Array.from(files).map((file) => {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();

        reader.onload = () => {
          const base64 = reader.result.split(",")[1];
          const fileData = {
            filename: file.name,
            base64: base64
          };

          if (fileData && fileData.base64 && fileData.filename) {
            resolve(fileData);
          } else {
            reject("File data is not ready");
          }
        };

        reader.onerror = () => {
          reject("Error reading file");
        };

        reader.readAsDataURL(file);
      });
    });

    Promise.all(filePromises)
      .then((fileInfos) => uploadFiles({ fileInfos }))
      .then((result) => {
        const uploadedFiles1 = result.map((docId, index) => ({
          filename: files[index].name,
          documentId: docId
        }));

        console.log("i am result--->", result);
        this.newUploadedFiles = [...this.newUploadedFiles, ...uploadedFiles1];
        this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles1];
        this.contentVersionIds = [...this.contentVersionIds, ...result];
      })
      .catch((error) => console.error("Error during file upload:", error));
  }

  handleUploadFinished2(event) {
    const files = event.target.files;

    const filePromises = Array.from(files).map((file) => {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();

        reader.onload = () => {
          const base64 = reader.result.split(",")[1];
          const fileData = {
            filename: file.name,
            base64: base64,
            RecordId: this.recordId
          };

          if (fileData && fileData.base64 && fileData.filename) {
            resolve(fileData);
          } else {
            reject("File data is not ready");
          }
        };

        reader.onerror = () => {
          reject("Error reading file");
        };

        reader.readAsDataURL(file);
      });
    });

    Promise.all(filePromises)
      .then((fileInfos) => {
        console.log(`Uploading ${fileInfos.length} files`);
        return uploadFiles({ fileInfos });
      })
      .then((result) => {
        console.log("Files uploaded successfully", result);

        const uploadedFiles = result.map((docId, index) => ({
          filename: files[index].name,
          documentId: docId
        }));

        this.newUploadedFilesEApostille = [
          ...this.newUploadedFilesEApostille,
          ...uploadedFiles
        ];
        this.uploadedFileApostille = [
          ...this.uploadedFileApostille,
          ...uploadedFiles
        ];
        this.contentVersionIds = [...this.contentVersionIds, ...result];

        console.log("Updated contentVersionIds:", this.contentVersionIds);
        console.log(
          "Uploaded files with document IDs:",
          this.uploadedFileApostille
        );
      })
      .catch((error) => {
        console.error("Error during file upload:", error);
      });
  }

  handleDeleteFile(event) {
    const index = event.target.dataset.index;
    const fileToDelete = this.uploadedFiles[index];

    deleteFile({ fileId: fileToDelete.documentId })
      .then(() => {
        this.uploadedFiles.splice(index, 1);
        this.uploadedFiles = [...this.uploadedFiles];

        this.titleuploadedFiles = [];
        this.titleuploadedFiles = this.uploadedFiles.map(
          (file) => file.filename
        );
        this.uploadedFilesID = [];
        this.uploadedFilesID = this.uploadedFiles.map(
          (file) => file.documentId
        );

        // console.log('File deleted successfully');
      })
      .catch((error) => {
        console.error("Error deleting file:", error);
      });
  }

  handleDeleteFile2(event) {
    const index = event.target.dataset.index;
    const fileToDelete = this.uploadedFileApostille[index];

    deleteFile({ fileId: fileToDelete.documentId })
      .then(() => {
        this.uploadedFileApostille.splice(index, 1);
        this.uploadedFileApostille = [...this.uploadedFileApostille];

        this.titleuploadedFileApostille = [];
        this.titleuploadedFileApostille = this.uploadedFileApostille.map(
          (file) => file.filename
        );

        this.uploadedFileApostilleID = [];
        this.uploadedFileApostilleID = this.uploadedFileApostille.map(
          (file) => file.documentId
        );

        // console.log('File deleted successfully');
      })
      .catch((error) => {
        console.error("Error deleting file:", error);
      });
  }

  handleUpload() {
    this.titleuploadedFiles = [];
    this.newUploadedFiles = [];
    this.uploadClicked = true;
    this.pre_paid_shipping_label = true;
    this.isModalOpen = false;

    this.uploadedFilesID = [];
    this.uploadedFilesID = this.uploadedFiles.map((file) => file.documentId);

    this.titleuploadedFiles = this.uploadedFiles.map((file) => file.filename);
  }

  handleUpload2() {
    this.titleuploadedFileApostille = [];
    this.newUploadedFilesEApostille = [];
    this.e_Apostille_customer_upload = true;
    this.upload2Clicked = true;
    this.isModalOpen2 = false;
    this.uploadedFileApostilleID = [];
    this.uploadedFileApostilleID = this.uploadedFileApostille.map(
      (file) => file.documentId
    );
    this.titleuploadedFileApostille = this.uploadedFileApostille.map(
      (file) => file.filename
    );
  }

  showSaveData() {
    if (this.isOption1Checked) {
      console.log('nothing');

    } else if (this.isOption2Checked) {
      this.isOption1Checked = false;
      this.showUploadLink = true;
      this.pre_paid_shipping_labelisReadOnly = false;
      this.pre_paid_shipping_label = true;

      this.uploadedFiles = this.uploadedFilesID.map((id, index) => {
        return {
          documentId: id,
          filename: this.titleuploadedFiles[index]
        };
      });
    } else if (this.isOption3Checked) {
      this.isOption1Checked = false;
    } else if (this.isOption4Checked) {
      this.isOption1Checked = false;
      this.showEapostilleUploadLink = true;
      this.e_Apostille_customer_uploadisReadOnly = false;
      this.e_Apostille_customer_upload = true;

      this.uploadedFileApostille = this.uploadedFileApostilleID.map(
        (id, index) => {
          return {
            documentId: id,
            filename: this.titleuploadedFileApostille[index]
          };
        }
      );
    } else {
      this.isOption1Checked = true;
      this.showShippingOptions = true;
    }
  }

  changeTodeleteprePaid() {
    this.uploadedFiles.forEach((file) => {
      deleteFile({ fileId: file.documentId })
        .then(() => {
          console.log("File deleted successfully");
        })
        .catch((error) => console.error("Error deleting file:", error));
    });
    this.uploadedFiles = [];
  }

  changeTodeleteeApostille() {
    this.uploadedFileApostille.forEach((file) => {
      deleteFile({ fileId: file.documentId })
        .then(() => {
          console.log("File deleted successfully");
        })
        .catch((error) => console.error("Error deleting file:", error));
    });
    this.uploadedFileApostille = [];
  }
//   async handleFileDownload(event) {
//     try {
//         // Extract dataset attributes safely
//         const fileId = event.currentTarget.dataset.id;
//         const fileName = event.currentTarget.dataset.filename || 'downloaded_file.pdf'; // Default file name if not provided

//         if (!fileId) {
//             console.error('Missing fileId in the dataset attributes');
//             return;
//         }

//         // Call Apex method to get the file data
//         const result = await downloadFile({ documentId: fileId });

//         // Convert base64 data to a Blob
//         const base64 = result.base64Data;
//         const contentType = result.contentType;

//         if (!base64 || !contentType) {
//             console.error('Invalid file data received from server');
//             return;
//         }

//         const byteCharacters = atob(base64);
//         const byteArrays = [];

//         for (let offset = 0; offset < byteCharacters.length; offset += 512) {
//             const slice = byteCharacters.slice(offset, offset + 512);
//             const byteNumbers = new Array(slice.length);

//             for (let i = 0; i < slice.length; i++) {
//                 byteNumbers[i] = slice.charCodeAt(i);
//             }

//             const byteArray = new Uint8Array(byteNumbers);
//             byteArrays.push(byteArray);
//         }

//         const blob = new Blob(byteArrays, { type: contentType });

//         // Generate a URL for the Blob
//         const pdfUrl = URL.createObjectURL(blob);

//         // Dynamically create a n anchor element
//         const anchor = document.createElement('a'); // Define the anchor element
//         anchor.href = pdfUrl;
//         anchor.target = '_blank';
//         anchor.click();

//         // Revoke the object URL after use
//        setTimeout(() => URL.revokeObjectURL(pdfUrl), 10000);
//     } catch (error) {
//         console.error('Error previewing the file:', error);
//     }
// }



  // ----------------------------------------------   Shipping Address -------------------- //

  @track addressLine1;
  @track suite;
  @track city;
  @track state;
  @track zipCode;
  @track country;
  @track validationError = '';
  @track sameAsContactAddressString = "No";


  handleAddressChange(event) {

    this.addressLine1 = event.detail.street ? event.detail.street.toUpperCase() : '';
    this.city = event.detail.city ? event.detail.city.toUpperCase() : '';
    this.suite = event.detail.subpremise ? event.detail.subpremise.toUpperCase() : '';
    this.state = event.detail.province ? event.detail.province.toUpperCase() : '';
    //this.zipCode = event.detail.postalCode;
    this.country = event.detail.country ? event.detail.country.toUpperCase() : '';

    const zipCode = event.detail.postalCode;
    const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

    if (!zipCodePattern.test(zipCode)) {
        this.validationError = 'Zip Code can only contain digits and hyphen.';
        this.zipCode = '';
    } else {
        this.validationError = '';
        this.zipCode = zipCode;
    }

}

  // -------------------------------------- Additional Service Requirment ----------------------------- //

  @track additionalServiceRequest;

  handleAdditionalServiceChange(event) {
    const value = event.target.value;

    this.additionalServiceRequest = value;

    console.log('Additional Services Requested updated:', this.additionalServiceRequest);
}




// -------------------------------------- Memo & Notes ----------------------------- //

  @track memo;
  @track notes;

  handleMemoChange(event) {
    const value = event.target.value;
    this.memo = value;
    console.log('Memo updated:', this.memo);
}

handleNotesChange(event) {
    const value = event.target.value;
    this.notes = value;
    console.log('Notes updated:', this.notes);
}




  // -----------------------------------  Modification Details ------------------------------------------//

  @track modifiedBy;
  @track ModifiedDate;



  //----------------------------- Footer Function ----------------------------------


  // handleCancelWorkOrder() {
  //   updateApplicationStatusToDraft({ recordId: this.recordId })
  //     .then(() => {
  //       this.close("updateRecord");
  //     })
  //     .catch((error) => {
  //       console.error("Error reinstating order:", error);
  //     });
  // }

  @track footerOprions = false;
  @track generateCertificate = false;

  async handleAdd() {

    const isValid = this.validateInputs();
    const rejectionValid = this.validateDocAndRejectionReason();


    if (isValid && rejectionValid && (!this.validationError || this.validationError.trim() === '')) {
        const data = {
            Sequence_Number__c: this.workOrderNumber,
            Last_Name__c: this.lastName,
            First_Name__c: this.firstName,
            Organization_Name__c: this.organizationName,
            Email_Address__c: this.emailAddress,
            Cell_Phone_Number__c: this.phoneNumber,
            Status: this.workOrderStatus,

            Agency_Business_Name__c: this.businessName,
            Agency_First_Name__c: this.firstNameindividual,
            Agency_Last_Name__c: this.lastNameindividual,
            Agency_Email_Address__c: this.emailAddressindividual,
            Agency_Cell_Phone__c: this.cellPhoneNumber,
            Email_Address_For_Receiving_Apostille__c: this.emailReceivingApostille,

            Address_Line_1_Shipping__c: this.addressLine1,
            Suite_Apartment_Floor_Shipping__c: this.suite,
            City_Shipping__c: this.city,
            State_Shipping__c: this.state,
            Country_Shipping__c: this.country,
            Zip_Code_Shipping__c: this.zipCode,

            documentDestinationCountry__c: this.selectedCountry,
            HagueStatus__c: this.selectedHagueStatus,
            Destination_Country__c: this.destinationCountrySameString,
            documentDestinationCountryBoolean__c: this.destinationCountrySame,
            Expedite_Request_Boolean__c: this.expediteRequest,
            Expedite_Request__c: this.expediteRequestString,
            Expedited__c: this.expedite,
            Return_Mail_Type__c: this.shippingMethod,
            FedEX__c: this.fedEx,
            e_Apostille_document_has_been_uploaded__c: this.pre_paid_shipping_label,
            ReturnMailDocument_s_will_be_picked_up__c: this.documentPickedUp,
            return_Mail_e_Apostille_Customer__c: this.e_Apostille_customer_upload,
            Instructions__c: this.additionalServiceRequest,
            Notes_on_Receipt__c: this.notes,
            Receipt_Memo__c: this.memo,

            Id: this.recordId
        };

        this.footerOprions = true;
        const allData = {
          individualApplication: JSON.stringify(data),
          payment: this.paymentList ? JSON.stringify(this.paymentList):[],
          documents: this.documents ? JSON.stringify(this.documents): [],
          recordId: this.recordId,
          destinationCountry: this.destinationCountrySameString
        };

        console.log('All Data:', JSON.stringify(allData));


        if(this.workOrderStatus == 'Submitted' )
        {
          const numberOfDocuments=JSON.parse(allData.documents).length;

          let SubmitStatusCount=0;


          // it should be either
          if(numberOfDocuments>=1){
            for(let i=0;i<numberOfDocuments;i++){

                if( (JSON.parse(allData.documents)[i].status=='Submitted')){
                  SubmitStatusCount+=1;
                }

            }

            if(SubmitStatusCount>=1){
              console.log('numberOfDocuments',numberOfDocuments);
              console.log('all are either approved or cancelled it is right logic');

              console.log('all data doc: ',JSON.stringify(allData.documents));

              if (allData.documents === "[]") {
                this.showToast('Error', 'Add at least one document before proceeding.', 'error');
                this.footerOprions = false;
                return; // Exit the function without calling updateAllData
            }

              updateAllData({ allDataJson: JSON.stringify(allData) })
                  .then(result => {

                    if(result === 'Success'){
                      console.log('All records updated successfully!');
                      this.showToast( 'Individual Application', 'Request updated successfully!', 'success');
                      this.mode = 'view';

                      if (this.mode === "view") {
                        this.isReadOnly = true;
                    }
                      this.footerOprions = false;
                      // this.refreshData();
                      refreshApex(this.wiredIndividualData);
                      refreshApex(this.wiredDocumentData);
                    }
                  })
                  .catch(error => {
                      console.error('Error updating records:', error);
                      this.showToast('In House ', 'Error processing the request. Please try again.', 'error');
                      // Handle error (e.g., show an error toast)
                      this.footerOprions = false;
                  });

            }

            else{
              this.showToast('Error', '', 'error');
              this.footerOprions = false;
            }
          }
        }

        else {
          console.log('all data doc: ',JSON.stringify(allData.documents));

              if (allData.documents === "[]") {
                this.showToast('Error', 'Add at least one document before proceeding.', 'error');
                this.footerOprions = false;
                return; // Exit the function without calling updateAllData
            }

              updateAllData({ allDataJson: JSON.stringify(allData) })
                  .then(result => {

                    if(result === 'Success'){
                      console.log('All records updated successfully!');
                      this.showToast( 'Individual Application', 'Request updated successfully!', 'success');
                      this.mode = 'view';

                      if (this.mode === "view") {
                        this.isReadOnly = true;
                    }
                      this.footerOprions = false;
                      // this.refreshData();
                      refreshApex(this.wiredIndividualData);
                      refreshApex(this.wiredDocumentData);
                    }
                  })
                  .catch(error => {
                      console.error('Error updating records:', error);
                      this.showToast('In House ', 'Error processing the request. Please try again.', 'error');
                      // Handle error (e.g., show an error toast)
                      this.footerOprions = false;
                  });
        }







      //   try {
      //       // First, update the Individual Application data
      //       const result = await updateIndividualApplicationData({ newRecord: data });

      //       this.recordId = result;
      //       this.showToast(
      //           'Individual Application',
      //           this.recordId ? 'Request updated successfully!' : 'Request created successfully!',
      //           'success'
      //       );

      //       // Update , the payment record
      //       if(this.paymentList && this.paymentList.length > 0) {
      //        console.log('Payment list to update:', JSON.stringify(this.paymentList));
      //        const result =  await updatePaymentData({
      //             paymentJson: JSON.stringify(this.paymentList),
      //             recordId: this.recordId
      //            });

      //            this.showToast(
      //             'Payment Details',
      //             result === 'Success' ? 'Payment updated successfully!' : 'Payment updated successfully!',
      //             'success'
      //         );
      //       }

      //       // Check if there are documents to save
      //       if (this.documents && this.documents.length > 0) {
      //         //  console.log('Documents to save:', JSON.stringify(this.documents));
      //         //  console.log('destinationCountrySameString: '+this.destinationCountrySameString);


      //           // Save documents after updating or creating the record
      //          const result = await createDocumentChecklistItemsId({
      //               documentsJson: JSON.stringify(this.documents),
      //               recordId: this.recordId,
      //               destinationCountry: this.destinationCountrySameString
      //           });

      //           this.showToast(
      //             'Document Details',
      //             result === 'Success' ? 'Document updated successfully!' : 'Document updated successfully!',
      //             'success'
      //         );

      //        //   console.log('Documents saved successfully');
      //       }
      //       this.mode = 'view';

      //   } catch (error) {
      //       console.error('Error processing the request:', error);
      //       this.showToast('In House ', 'Error processing the request. Please try again.', 'error');
      //   } finally {
      //     // Hide loading spinner
      //     this.refreshData();
      // }
    } else {
        console.error('Form is not valid');
        this.showToast('Apostille in-house', 'Please review the form and fill all details properly.', 'error');
    }
}

cancelEditPage(){
  this.footerOprions = true;
  this.mode = 'view';
  if (this.mode === "view") {
    this.isReadOnly = true;
}
  // this.refreshData();
  refreshApex(this.wiredIndividualData);
  refreshApex(this.wiredDocumentData);
  // this.refreshData();
  this.footerOprions = false;

}

showToast(title, message, variant) {
    const toast = this.template.querySelector('c-toast-message-state-modal');
    if (toast) {
        toast.showToast({
            title: title,
            message: message,
            variant: variant,
        });
    }
}

  validateInputs(showErrors = true) {
    let allValid = true;
    const missingFields = [];
    const inputComponents = this.template.querySelectorAll(
        'lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group'
    );

    inputComponents.forEach(inputCmp => {
        if (showErrors) {
            inputCmp.reportValidity();
        }

        if (!inputCmp.checkValidity()) {
            allValid = false;
            missingFields.push(inputCmp.label);
        }
    });

    const addressCmp = this.template.querySelector('lightning-input-address');
    if (addressCmp) {
        const addressFields = [
            { field: 'street', label: 'Address Line 1' },
            { field: 'city', label: 'City' },
            { field: 'province', label: 'State' },
            { field: 'postalCode', label: 'Zip Code' },
            { field: 'country', label: 'Country' }
        ];

        addressFields.forEach(({ field, label }) => {
            const value = addressCmp[field];
            if (showErrors && !value) {
                allValid = false;
                missingFields.push(label);
            }
        });
    }

    if (showErrors && !allValid) {
        const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
        this.showToast('Error', message, 'error');
    }

    return allValid;
}



  @api
  get fullName() {
    return `${this.firstName} ${this.lastName}`;
  }

  async handlePrintPaymentReceipt() {
   // this.close();

   try  {
    document.body.style.overflow = 'hidden';

    const result = await PrintPaymentReceiptModal2.open({
        size: "medium",
        description: "Print Payment Recipt",
        recordId: this.recordId
  });
    if (result === 'cancel') {
      console.log('close print payment modal');

    }
  } finally {
    document.body.style.overflow = 'auto';
  }

}

 async handleModalCertificateAction() {

    try{
      document.body.style.overflow = 'hidden';
      const result = await ApostillePrintSubmissionDocumentV2.open({
        size: "medium",
        description: "Print Submission Document",
        label: "Print Submission Document",
        recordId: this.recordId
      });
      if (result === 'cancel') {
        console.log('close print submission document modal');

      }

    } finally{
      document.body.style.overflow = 'auto';
    }
  }

  @track printAllCertificate = false;

  handlePrintAllCertificate(){
    console.log('Print All certificate is called');
    this.printAllCertificate = true;
  }

  toTitleCase(str) {
    return str.replace(/\w\S*/g, (txt) => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase());
}

checklistData ={};

  async openCertificateModal(event){
    const recordId = event.target.dataset.id;
    const documentType = event.target.dataset.doc;
    const status = event.target.dataset.status;
    const certificateNo = event.target.dataset.certificate;
    const signedBy = event.target.dataset.signedby;
    const signedStamp = event.target.dataset.signedstamp;
    const position = event.target.dataset.position;
    const destination = event.target.dataset.destination;
    const hagueStatus = event.target.dataset.haguestatus;
    const signingAuthorityName = event.target.dataset.signingauthorityname;
    const signningAuthorityTitle = event.target.dataset.signingauthoritytitle;
    const docId = event.target.dataset.docid;


   // console.log('pram data is '+ recordId ,' =>', documentType ,' =>',status,' =>',certificateNo,' =>',docId );

    this.checklistData = {
      certificateNumber : certificateNo ? certificateNo.toUpperCase(): '',
      signedBy: signedBy ? signedBy.toUpperCase() :'',
      signedStamp: signedStamp? signedStamp.toUpperCase() : '',
      position: position ? position.toUpperCase() : '',
      destination: this.toTitleCase(destination || ''),
      hagueStatus: hagueStatus ? hagueStatus.toUpperCase() :'',
      documentType: this.toTitleCase(documentType || ''),
      Signing_Authority_Name: signingAuthorityName ? this.toTitleCase(signingAuthorityName) : '',
      Signing_Authority_Title: signningAuthorityTitle  ? this.toTitleCase(signningAuthorityTitle) : '',
      recordId : recordId,
      docId : docId
    };

    console.log('Checklist Data:', this.checklistData);



      if (status === 'Approved' || status === 'Accepted') {

        this.generateCertificate = true;

        // try {
        //     await ApostilleHouseCertificateModal.open({
        //         size: "medium",
        //         description: "View Apostille Certificate",
        //         label: "Apostille Certificate",
        //         recordId: recordId,  // Pass the recordId to the modal
        //         documentType: documentType,
        //         certificateNo: certificateNo,
        //         docId: docId
        //     });
        // } catch (error) {
        //     console.error("Error opening certificate modal:", error);
        // }

        if (!this.checklistData.certificateNumber) {
          this.showToast('Error', 'Certificate number is not present.', 'error');
          return;
        }

        const pdfgenerator = this.template.querySelector('c-apostille-pdf-generator');
        if (pdfgenerator) {
          const result = await pdfgenerator.generateApostilleCertificate(this.checklistData, 'print'); // Pass the checklist data to the child component
          if(result === "success")
            this.generateCertificate = false;
        } else {
          console.error('PDF generator component not found');
      }

    } else {
        const message = `Cannot generate the certificate for ${status} status`;
        this.showToast('Info', message, 'info');
    }
  }


  closePrintAllCerti(){
    this.printAllCertificate = false;

  }

    // Show Toast Message Utility Method
  //   showToast(title, message, variant) {
  //     const toast = this.template.querySelector('c-toast-message-state-modal');
  //     if (toast) {
  //         toast.showToast({
  //             title: title,
  //             message: message,
  //             variant: variant,
  //         });
  //     }
  // }


   // -----------------------------------  Docuemnt Section ------------------------------------------//

  //  @track isModalOpen = false;
   @track sotsUpload = false;
   @track sotRowId;
   @track showDocError = false;
   @track isReupload = false;
   @track isFileLoading = false;

processFiles() {
  this.filesList = [];
  this.documents.forEach(doc => {
      if (doc.uploadedFiles && doc.uploadedFiles.length > 0) {
          const processedFiles = doc.uploadedFiles.map(file => ({
              label: file.filename,
              value: file.documentId,
              url: `/sfc/servlet.shepherd/document/download/${file.documentId}`,
              docId: doc.id
          }));
          this.filesList = [...this.filesList, ...processedFiles];
      }
  });
  console.log('Processed Files List:', this.filesList);
}

previewHandler(event) {
  const documentId = event.target.dataset.documentId;
  console.log('Document ID:', documentId);

  if (documentId) {
      this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview'
          },
          state: {
              selectedRecordId: documentId
          }
      });
  } else {
      console.error('Document ID is missing.');
  }
}

get filteredDocuments() {
  const filteredDocs = this.documents.filter(doc => doc.uploadedFiles && doc.uploadedFiles.length > 0);
  return filteredDocs;
}

handleUploadForDocument(event){
  this.sotRowId = event.target.dataset.id;
  this.isModalOpen = true;
  this.sotsUpload = true;
  this.isReupload =  event.currentTarget.dataset.value === 'reUpload';
}

closeUploadSotsModal(){
  this.isModalOpen = false;
  if(!this.isReupload){
  this.documents = this.documents.map((doc) => {
    if (doc.id == this.sotRowId) {
      if (doc.uploadedFiles.length > 0) {
        this.deleteFileById(doc.uploadedFiles[0].documentId);
      }
      return { ...doc, uploadedFiles: [] };
    }
    return doc;
});
  }
}

handleUploadFinishedSot(event) {
  this.isFileLoading = true;
  const file = event.target.files[0];
  if (file) {
      console.log('File selected:', file);
      const reader = new FileReader();

      reader.onload = () => {
          const base64 = reader.result.split(',')[1];
          const fileData = {
              filename: file.name,
              base64: base64,
          };

          uploadFiles({ fileInfos: [fileData] })
              .then((result) => {
                  console.log('File uploaded successfully:', result);
                  const uploadedFile = {
                      filename: file.name,
                      documentId: result[0],
                  };

                  this.documents = this.documents.map((doc) => {
                      if (doc.id === this.sotRowId) {
                          if (doc.uploadedFiles.length > 0) {
                              this.deleteFileById(doc.uploadedFiles[0].documentId);
                          }
                          return {
                              ...doc,
                              uploadedFiles: [uploadedFile],
                              contentDocumentId: uploadedFile.documentId
                          };
                      }
                      return doc;
                  });

                  console.log(
                      'Updated documents after file upload:',
                      JSON.stringify(this.documents)
                  );
              })
              .catch((error) => {
                  console.error('Error during file upload:', error);
              })
              .finally(() => {
                this.isFileLoading = false;
            });

      };
      reader.readAsDataURL(file);
  }
  console.log('document json with updated file: ', JSON.stringify(this.documents));

}

deleteFileSot(event) {
  const id = event.target.dataset.id;
  let deletionPromise = Promise.resolve();

  for (const doc of this.documents) {
    if ((doc.id === id || doc.id === this.sotRowId) && doc.uploadedFiles.length > 0) {
      const fileId = doc.uploadedFiles[0].documentId;

      deletionPromise = deleteFile({ fileId: fileId })
        .then(() => {
          console.log('File deleted successfully');
          doc.uploadedFiles = [];
          return doc;
        })
        .catch((error) => {
          console.error('Error deleting file:', error);
          return doc;
        });

      break;
    }
  }

  deletionPromise
    .then(() => {
      console.log('Updated documents after file deletion:', JSON.stringify(this.documents));
    })
    .catch((error) => {
      console.error('Error in file deletion:', error);
    });
}



deleteFileById(fileId) {
  deleteFile({ fileId: fileId })
      .then(() => {
          console.log(`File with ID ${fileId} deleted successfully`);
      })
      .catch((error) => {
          console.error(`Error deleting file with ID ${fileId}:`, error);
      });
}

get hasUploadedFiles() {
  return this.documents.filter(doc =>
    doc.id === this.sotRowId &&
    doc.uploadedFiles &&
    doc.uploadedFiles.length > 0
);
}


// -----------------------------------  Rejection Reason Modal Section ------------------------------------------//

@track rejectionModal = false;
@track rejectionReasonOptions = [];
@track selectedRejectionReasons = [];
@track selectedReason = '';
@track customRejectionReason = '';
@track currentEditingDocumentId;
@track showError = false;

openRejectionModal(event) {
 this.currentEditingDocumentId = event.target.dataset.id;
const currentDoc = this.documents.find(doc => doc.id === this.currentEditingDocumentId);

if (currentDoc) {
    this.selectedRejectionReasons = currentDoc.rejectionReason
        ? (typeof currentDoc.rejectionReason === 'string'
           ? currentDoc.rejectionReason.split(';').map(reason => reason.trim())
           : currentDoc.rejectionReason)
        : [];

    this.customRejectionReason = currentDoc.customRejectionReason || '';
}

setTimeout(() => {
    this.template.querySelectorAll('lightning-input').forEach(checkbox => {
      const value = checkbox.dataset.value?.trim();
        const isChecked = this.selectedRejectionReasons.includes(value);
        checkbox.checked = isChecked;
        const checkboxContainer = checkbox.closest('.slds-p-top_small');
        if (checkbox.checked && checkboxContainer) {
            checkboxContainer.classList.add('checked-background');
        } else if (checkboxContainer) {
            checkboxContainer.classList.remove('checked-background');
        }
    });
}, 0);
this.rejectionModal = true;
}

closeRejectionModal() {
    this.rejectionModal = false;
}

@wire(getPicklistValues, {
    recordTypeId: '$documentChecklistItemObjectInfo.data.defaultRecordTypeId',
    fieldApiName: REJECTION_REASON_FIELD
}) handleRejectionReasonPicklist({ error, data }) {
    if (data) {
        this.rejectionReasonOptions = data.values.map(picklistOption => {
            if (picklistOption.label === 'We have received your documents and payment, but no order was created in the Apostille system, and the country for which the apostille is needed was not provided.') {
                return {
                    ...picklistOption,
                    label: picklistOption.label + ' Please complete your order at (link to system), specify the country, and email the work order number to bsd@ct.gov so we can proceed with processing your apostille.'
                };
            }
            return picklistOption;
        });
        console.log(this.rejectionReasonOptions);
    } else if (error) {
        console.error('Error fetching rejection reason values', error);
    }
}

handleReasonChange(event) {
  const value = event.target.dataset.value;
  const checkboxContainer = event.target.closest('.slds-p-top_small');

  if (event.target.checked) {
      this.selectedRejectionReasons = [...this.selectedRejectionReasons, value];
      checkboxContainer.classList.add('checked-background');
  } else {
      this.selectedRejectionReasons = this.selectedRejectionReasons.filter(
          selectedValue => selectedValue !== value
      );
      checkboxContainer.classList.remove('checked-background');
  }
}

handleReset() {
  this.selectedRejectionReasons = [];
  this.customRejectionReason = '';

  const checkboxes = this.template.querySelectorAll('lightning-input');

  checkboxes.forEach(checkbox => {
      checkbox.checked = false;

      const checkboxContainer = checkbox.closest('.slds-p-top_small');
      if (checkboxContainer) {
          checkboxContainer.classList.remove('checked-background');
      }
  });
}

handleCustomReasonChange(event) {
  this.customRejectionReason = event.detail.value;
}

handleRejection() {
  const predefinedReasons = this.selectedRejectionReasons.length > 0
      ? this.selectedRejectionReasons.join('; ')
      : '';

  this.documents = this.documents.map(doc =>
      doc.id === this.currentEditingDocumentId
          ? {
                ...doc,
                rejectionReason: predefinedReasons,
                customRejectionReason: this.customRejectionReason || null,
            }
          : doc
  );

  this.selectedRejectionReasons = [];
  this.customRejectionReason = '';
  this.rejectionModal = false;

  console.log('Updated documents:', JSON.stringify(this.documents));
}


validateDocAndRejectionReason() {
  let isValid = true;
  this.showDocError = false;
  this.showError = false;

  this.documents.forEach(doc => {
      // Validate document type and uploaded files
      if (doc.checkDocumentType && (!doc.uploadedFiles || doc.uploadedFiles.length === 0)) {
          this.showDocError = true;
          console.log('doc error is true');

          isValid = false;
      }

      // Validate rejection reason
      if (doc.statusRejected && !doc.rejectionReason && !doc.customRejectionReason) {
          this.showError = true;
          isValid = false;
      }
  });

  return isValid;
}


}