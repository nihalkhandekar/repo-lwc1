import { LightningElement, track, api, wire } from "lwc";
import LightningModal from "lightning/modal";
import ADDRESS_STYLES from "@salesforce/resourceUrl/addressStyles"; // Static Resource
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import NewpopupOnlineRequestModel from "@salesforce/resourceUrl/newpopupOnlineRequestModel";
import getDocumentTypesAndFees from "@salesforce/apex/DocumentTypeFeeController.getDocumentTypesAndFees";
import getCountryHagueMappings from "@salesforce/apex/DocumentTypeFeeController.getCountryHagueMappings";
import DocumentInfoCss from "@salesforce/resourceUrl/ApostileDocumentInformation";
import DocumentTable from "@salesforce/resourceUrl/documentTable";
import deleteFile from "@salesforce/apex/FileUploaderClass.deleteFile"; // Ensure you have an Apex method to handle deletion
import uploadFiles from "@salesforce/apex/FileUploaderClass.uploadFiles";
import getIndividualApplicationDetails from "@salesforce/apex/OnlineRequestSubmissionController.getIndividualApplicationDetails";
import updateIndividualApplicationData from "@salesforce/apex/OnlineRequestSubmissionController.updateIndividualApplicationData";
import ApostilleOnlineRequestPaymentModel from "c/apostilleOnlineRequestPaymentModel";
import ApostilleCertificateModal from "c/apostilleCertificateModal";
import ApostillePrintSubmissionDocumentV2 from "c/apostillePrintSubmissionDocumentV2";
import updateApplicationStatusToDraft from "@salesforce/apex/ApostilleSubmittedRequestController.updateApplicationStatusToCancelled";
import generateJsonFromChecklistItemsByParentId from '@salesforce/apex/DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc';
import fetchFiles from '@salesforce/apex/FileUploaderClass.fetchFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PrintPaymentReceiptModal from "c/printPaymentReceiptModal";
import createDocumentChecklistItemsId from '@salesforce/apex/DocumentChecklistItemCreator2.createDocumentChecklistItemsLwc';   // check this class
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import DocumentChecklistItem_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import STATUS_FIELD from '@salesforce/schema/DocumentChecklistItem.Status';
import sap_ContactSearchModal from 'c/sap_ContactSearchModal';




export default class ApostilleOnlineRequestModel2 extends LightningModal {
  
  



    // ---------------------------------- Header Function ----------------------------- //
  
    @track isReadOnly = false;
    @track isModelOpen = true;
    @api mode = '';
    @api recordId;

  
    get headerText() {
      if (!this.idofrecord) {
        return "View Apostille Request";
      }
      return this.isReadOnly
        ? "View Apostille Request  |  "
        : "Edit Apostille Request2";
    }
  
    handleEditClick() {
      this.isReadOnly = false;
    }
  
    isRemoveButtonVisible(index) {
      return index > 0;
    }
  
    cloeModels() {
      this.close("close");
    }
  
    get workOrderNumber() {
      return this.isReadOnly ? '' : 'e.g 2023-10117';  
    }
  
    get lastName() {
      return this.isReadOnly ? '' : 'e.g Doe';
    }
  
    get firstName() {
      return this.isReadOnly ? '' : 'e.g John';
    }
  
    get organizationName() {
      return this.isReadOnly ? '' : 'Enter organization name';
    }
  
    get emailAddress() {
      return this.isReadOnly ? '' : 'e.g johndoe@gmail.com';
    }
    get phoneNumber() {
      return this.isReadOnly ? '' : 'e.g (123) 456-7890';
    }
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
  
  
    get businessName() {
      return this.isReadOnly ? '' : 'Acme Corporation';
    }
    get firstNameindividual() {
      return this.isReadOnly ? '' : 'William';
    }
  
    get lastNameindividual() {
      return this.isReadOnly ? '' : 'Smith';
    }
  
    get emailAddressindividual() {
      return this.isReadOnly ? '' : 'william.smith@gmail.com';
    }
  
    get cellPhoneNumber() {
      return this.isReadOnly ? '' : '(555) 567-7890';
    }
  
    get emailReceivingApostille() {
      return this.isReadOnly ? '' : 'william.smith@gmail.com';
    }
  
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
  
    get fedEx() {
      return this.isReadOnly ? '' : '1234 5678 9012';
    }
  
    get modifiedBy() {
      return this.isReadOnly ? '' : 'john Doe';
    }
  
    get ModifiedDate() {
      return this.isReadOnly ? '' : 'mm/dd/yyyy';
    }
  
    // -------------------------------------------- Initial Method -------------------------------- //
  
    
    connectedCallback() {
      if (this.recordId) {
        this.idofrecord = this.recordId;
        this.fetchRecordDetails();
        this.initializeComponent();
      }
      if (this.mode === "view") {
        this.isReadOnly = true;
      } else if (!this.recordId) {
        this.isReadOnly = false;
        this.showSaveData();
      }
  
      Promise.all([
        loadStyle(this, ADDRESS_STYLES),
        loadStyle(this, NewpopupOnlineRequestModel)
        //    loadStyle(this, DocumentTable),
        //    loadStyle(this, DocumentInfoCss)
        //    loadStyle(this,Newpopup)
      ])
        .then(() => {
          console.log("CSS file loaded successfully");
        })
        .catch((error) => {
          console.error("Error loading CSS file:", error);
        });
    }
  
    fetchRecordDetails() {
      getIndividualApplicationDetails({ recordId: this.recordId })
        .then((result) => {
          this.workOrderNumber = result.Sequence_Number__c;
          this.lastName = result.Last_Name__c;
          this.firstName = result.First_Name__c;
          this.organizationName = result.Organization_Name__c;
          this.emailAddress = result.Email_Address__c;
          this.phoneNumber = result.Cell_Phone_Number__c;
          this.workOrderStatus = result.Status;
  
          this.addressLine1 = result.Address_Line_1_Shipping__c;
          this.suite = result.Suite_Apartment_Floor_Shipping__c;
          this.city = result.City_Shipping__c;
          this.state = result.State_Shipping__c;
          this.zipCode = result.Zip_Code_Shipping__c;
          this.country = result.Country_Shipping__c;
  
          this.businessName = result.Agency_Business_Name__c;
          this.firstNameindividual = result.Agency_First_Name__c;
          this.lastNameindividual = result.Agency_Last_Name__c;
          this.emailAddressindividual = result.Agency_Email_Address__c;
          this.cellPhoneNumber = result.Agency_Cell_Phone__c;
          this.emailReceivingApostille =result.Email_Address_For_Receiving_Apostille__c;
          
          this.selectedCountry = result.documentDestinationCountry__c;
          this.selectedHagueStatus = result.HagueStatus__c;
          this.destinationCountrySameString = result.Destination_Country__c;
          this.destinationCountrySame = result.documentDestinationCountryBoolean__c;
          this.expediteRequest = result.Expedite_Request_Boolean__c;
          this.expediteRequestString = result.Expedite_Request__c;
  
          this.shippingMethod = result.Return_Mail_Type__c;
          this.pre_paid_shipping_label = result.e_Apostille_document_has_been_uploaded__c;
          this.documentPickedUp = result.ReturnMailDocument_s_will_be_picked_up__c;
          this.e_Apostille_customer_upload = result.return_Mail_e_Apostille_Customer__c;
          
  
          this.modifiedBy = result.LastModifiedBy.Name;
          this.ModifiedDate = result.LastModifiedDate;
          // Continue mapping as needed...
        })
        .catch((error) => {
          console.error("Error fetching record details:", error);
        });
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
  
    @track workOrderNumber;
    @track lastName;
    @track firstName;
    @track organizationName;
    @track emailAddress;
    @track phoneNumber;
    @track workOrderStatus;
  
    statusOptions = [
      { label: "Approved", value: "Approved" },
      { label: "Denied", value: "Denied" },
      { label: "Submitted", value: "Submitted" },
      { label: "Order Completed - Mail", value: "Order Completed - Mail" },
      { label: "Order Completed – Pick Up", value: "Order Completed – Pick Up" }
    ];
  
  
  
    // ---------------------------- Work Order Transaction --------------------------------- //
  
  
    @track isReadOnly = false;
    @track expediteRequest = false;
    @track destinationCountrySame = false;
    @track sameAddressString = "no";
    @track destinationCountrySameString = "no";
    @track expediteRequestString = "no";
    @track selectedCountry = "";
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
    @track statusOptions = [];
    


    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    contactObjectInfo;

    @wire(getObjectInfo, { objectApiName: DocumentChecklistItem_OBJECT })
    documentChecklistItemObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.signedByPositionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.signedByPositionOptions = [];
        }
    }

     // Fetch Status picklist values
     @wire(getPicklistValues, {
        recordTypeId: '$documentChecklistItemObjectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    statusPicklistValues({ error, data }) {
        if (data) {
            this.statusOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status values', error);
            this.statusOptions = [];
        }
    }
  
    
  
    initializeComponent() {
      generateJsonFromChecklistItemsByParentId({ individualApplicationId: this.recordId })
              .then(result => {
                  this.documents = JSON.parse(result);  // Parse the JSON response
                  console.log('docuement data is ==>> '+ JSON.stringify(this.documents));
                  
              })
              .catch(error => {
                  console.error('Error fetching documents:', error);
              });
      //this.documents = this.documentsJson ? JSON.parse(this.documentsJson) : [];
      this.initializeRadioStates();
      this.updateCountryFieldState();
      if (this.isReadOnly) {
        this.initializeReadOnlyMode();
      }
      this.updateDocumentFees();
    }
  
    initializeRadioStates() {
      if (this.expediteRequestString === "yes") {
        this.expediteRequest = true;
        this.radioCssExp = "radioOptionsChecked";
        this.radioCssCheckedExp = "radioOptions";
      } else {
        this.expediteRequest = false;
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
        this.updateHagueStatus(value);
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
          this.radioCssExp = "radioOptionsChecked";
          this.radioCssCheckedExp = "radioOptions";
          this.updateDocumentFees();
        } else if (value === "no") {
          this.expediteRequestString = "no";
          this.expediteRequest = false;
          this.radioCssExp = "radioOptions";
          this.radioCssCheckedExp = "radioOptionsChecked";
          this.updateDocumentFees();
        }
        console.log("expecteRequest......", this.expediteRequestString);
      }
    }
  
    updateHagueStatus(selectedCountry) {
      console.log('select Country..........',selectedCountry);
      
      const hagueStatus = this.hagueMapping[selectedCountry];
      console.log('haguStatus...........',hagueStatus);
      
      this.selectedHagueStatus = hagueStatus || "";
      this.updateCountryFieldState();
    }
  
    updateCountryFieldState() {
      this.documents = this.documents.map((doc) => {
        return {
          ...doc,
          country:
            this.destinationCountrySameString === "yes"
              ? this.selectedCountry
              : doc.country,
          hague:
            this.destinationCountrySameString === "yes"
              ? this.selectedHagueStatus
              : doc.hague ? "Yes" : "No"
        };
      });
      console.log('this document..........',this.documents);
      
      this.updateDocumentFees();
    }
  
    handleAddDocument() {
      if (this.isReadOnly) return;
  
      const newDocument = {
        id: Date.now().toString(),
        typeOfDocument: "",
        country:
          this.destinationCountrySameString === "yes" ? this.selectedCountry : "",
        hague:
          this.destinationCountrySameString === "yes"
            ? this.selectedHagueStatus
            : "",
        personName: "",
        fee: "0.00",
        baseFee: "0.00",
        feeDisplay: "$0.00",
        signedByName: "", // Initialize to empty if it’s missing
        signedByPosition: "", // Initialize to empty if it’s missing
        selectedContactID:""
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
      console.log('current Id is '+id);
      
      
      this.documents = this.documents.filter(
        (doc) => String(doc.id) !== String(id)
      );
      console.log('after removed document is '+ JSON.stringify(this.documents));
      console.log('size is '+ this.documents.length);
      
      
  
      this.updateDocumentFees();
    }
  
   

    handleDocumentChange(event) {
      if (this.isReadOnly) return;
    
      const { name, value, dataset } = event.target;
      // const id = parseInt(dataset.id, 10);
      // console.log('targeted id is '+ id);
      const id = dataset.id; // Use directly without parsing to integer
      console.log('Targeted id is:', id);
      
      console.log('function is being called ');
      console.log('value is '+value);
      
      
    
      this.documents = this.documents.map((doc) => {
        console.log('see id is  '+doc.id + 'currentId is :==>' +id);
        
        if (doc.id === id) {
          let updatedFee = doc.fee;
          let baseFee = doc.baseFee;
          let updatedHagueStatus = doc.hague;
          let updatedCountry = doc.country;
          let updatedPersonName = doc.personName;
          let updatedSignedByName = doc.signedByName;
          let updatedSignedByPosition = doc.signedByPosition;
          let updatedselectedContactID = doc.selectedContactID;
          let updatedStatus = doc.status;
          console.log('new updated person name is '+ updatedPersonName);
          console.log('update signedByName is =>'+ updatedSignedByName);
          console.log('update selectedContactID is =>'+updatedselectedContactID);
          console.log('update status is =>'+updatedStatus);
          
          
          
    
          // Update the values based on the field that was changed
          switch (name) {
            case "typeOfDocument":
              if (this.documentFees[value]) {
                baseFee = this.documentFees[value];
                updatedFee = baseFee;
              }
              break;
            case "destinationCountry":
              if (this.hagueMapping[value] !== undefined) {
                updatedHagueStatus = this.hagueMapping[value] ? "Yes" : "No";
                if (this.destinationCountrySameString === "yes") {
                  updatedCountry = value;
                }
              }
              break;
            case "personName":
              updatedPersonName = value;
              break;
            case "signedByName":
              updatedSignedByName = value;
              break;
            case "signedByPosition":
              updatedSignedByPosition = value;
              break;
            case "status":
              updatedStatus = value;
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
            signedByName: updatedSignedByName,
            signedByPosition: updatedSignedByPosition,
            selectedContactID:updatedselectedContactID,
            status: updatedStatus
          };
        }
        return doc;
      });
    
      // Reassign the updated documents array to the component's documents property
      this.documents = [...this.documents];
      console.log('on changes updated document is ==>'+JSON.stringify(this.documents));
      
    
      this.updateDocumentFees();
    }


    async handleSearch(event) {
      const inputElement = event.target.closest('.slds-form-element').querySelector('lightning-input');

      if (inputElement) {
          console.log('SignedByName Value:', inputElement.value);
          const searchKey = inputElement.value;
          console.log('search key into Parent ==>'+ searchKey);
          
          
          if (searchKey.length >= 2) { // Only search if 2 or more characters
              const selectedContact = await sap_ContactSearchModal.open({
                  size: 'medium',
                  description: 'Select Contact',
                  searchKey: searchKey  // Pass search key to modal
              });

              if (selectedContact) {
                inputElement.value = selectedContact.Name;
                this.updateDocumentFields(inputElement.dataset.id, selectedContact.name, selectedContact.position,selectedContact.selectedContactID);
            }
          }
      }
    }

    // Helper function to handle the change in signedByName
    updateDocumentFields(docId, name, position,selectedID) {
      console.log('update document values==>>', name ,'position is =>',position,'selected Id is '+ selectedID);
      
      // Find the document by id and update the signedByName value
      const docIndex = this.documents.findIndex(doc => doc.id === docId);
      console.log('docIndex is : =>> '+docIndex);
      
      if (docIndex !== -1) {
          this.documents[docIndex].signedByName = name;
          this.documents[docIndex].signedByPosition = position;
          this.documents[docIndex].selectedContactID = selectedID;
          this.documents = [...this.documents]; // Refresh docs to ensure reactivity
      }else {
        console.error(`Document with ID ${docId} not found in updateDocumentFields.`);
    }
    console.log('updated document list have values are '+ JSON.stringify(this.documents));
    
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
  
    get isDestinationCountrySame() {
      return this.destinationCountrySameString === "yes";
    }
  
    get isHagueStatusYes() {
      return this.selectedHagueStatus === "True";
    }
  
    get isHagueStatusNo() {
      return this.selectedHagueStatus === "False";
    }
  
    get isExpediteSelected() {
      return this.expediteRequestString === "yes";
    }
    get isNotExpediteSelected() {
      return this.expediteRequestString !== "yes";
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
      const isExpediteSelected = this.expediteRequestString === "yes";
  
      this.documents = this.documents.map((doc) => {
        let baseFee = parseFloat(doc.baseFee || 0);
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
  
    @track paymentList = [
      {
        id: 1,
        paymentType: "",
        cardType: "",
        last4Digits: "",
        paymentAmount: "",
        showRemoveButton: false // First entry doesn't show remove button
      }
    ];
    @track paymentType;
    @track cardType;
    @track last4Digits;
    @track paymentAmount;
  
    paymentTypeOptions = [
      { label: "Credit Card", value: "Credit Card" },
      { label: "Debit Card", value: "Debit Card" },
      { label: "Cash", value: "Cash" }
    ];
  
    shippingOptions = [
      { label: "UPS", value: "UPS" },
      { label: "FedEx", value: "FedEx" },
      { label: "DHL", value: "DHL" }
    ];
  
    cardTypeOptions = [
      { label: "Visa", value: "Visa" },
      { label: "MasterCard", value: "MasterCard" },
      { label: "American Express", value: "American Express" }
    ];
  
    
    handleAddPayment() {
      const newPayment = {
        id: this.paymentList.length + 1, // Generate a unique ID
        paymentType: "",
        cardType: "",
        last4Digits: "",
        paymentAmount: "",
        showRemoveButton: true // Show button for new entries
      };
      this.paymentList.push(newPayment);
      console.log("Current Payment List:", JSON.stringify(this.paymentList));
    }
  
    handleRemovePayment(event) {
      const index = event.target.dataset.index; // Get the index from the button
      this.paymentList.splice(index, 1); // Remove the payment from the list
      this.updateRemoveButtonVisibility();
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
  
  // Method for Payment Amount field change
  handlePaymentAmountChange(event) {
    const index = event.target.dataset.index; // Retrieve index of the item being modified
    this.paymentList[index].paymentAmount = event.target.value;
    console.log(`Updated Payment Amount at index ${index}:`, this.paymentList[index].paymentAmount);
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
    @track uploadedFiles = [];
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
    showShippingOptions = true;
    upload2Clicked = false;
    uploadClicked = false;
  
    @wire(fetchFiles, { recordId: '$recordId' })
      wiredFiles({ error, data }) {
          if (data) {
              this.uploadedFiles = data.map(file => ({
                  filename: file.Title,
                  documentId: file.ContentDocumentId
              }));
          } else if (error) {
              console.error('Error fetching files: ', error);
          }
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
  
  
    handleOptionChange(event) {
      const selectedValue = event.target.value;
      this.returnOptions = this.returnOptions.map((option) => ({
        ...option,
        checked: option.value === selectedValue
      }));
    }
  
    handleUploadFinished(event) {
      const uploadedFiles = event.detail.files;
      this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];
    }
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
  
        this.changeTodeleteprePaid();
      } else if (selectedValue === "pickup") {
        this.showThirdOption = false;
        this.showfirstOption = true;
        // this.thirdOptionisReadOnly = false;
        this.pre_paid_shipping_label = false;
        this.e_Apostille_customer_upload = false;
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
  
  
    async handleFileDownload(event) {
      console.log('file.');
      
      const fileId = event.currentTarget.dataset.id;
      const fileName = event.currentTarget.dataset.name;
      
      try {
          const result = await downloadFile({ documentId: fileId });
          
          // Convert base64 to blob
          const base64 = result.base64Data;
          const contentType = result.contentType;
          const sliceSize = 512;
          const byteCharacters = atob(base64);
          const byteArrays = [];
  
          for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
              const slice = byteCharacters.slice(offset, offset + sliceSize);
              const byteNumbers = new Array(slice.length);
              
              for (let i = 0; i < slice.length; i++) {
                  byteNumbers[i] = slice.charCodeAt(i);
              }
              
              const byteArray = new Uint8Array(byteNumbers);
              byteArrays.push(byteArray);
          }
  
          const blob = new Blob(byteArrays, { type: contentType });
          
          const downloadUrl = window.URL.createObjectURL(blob);
          const downloadLink = document.createElement('a');
          downloadLink.href = downloadUrl;
          downloadLink.download = fileName;
          
          document.body.appendChild(downloadLink);
          downloadLink.click();
          document.body.removeChild(downloadLink);
          
          window.URL.revokeObjectURL(downloadUrl);
      } catch (error) {
          console.error('Error downloading file:', error);
      }
  }
  
  
  
  
  
    // ----------------------------------------------   Shipping Address -------------------- //
  
    @track addressLine1;
    @track suite;
    @track city;
    @track state;
    @track zipCode;
    @track country;
    @track sameAsContactAddressString = "No";
  
  
    handleAddressChange(event) {
         
      this.addressLine1 = event.detail.street ? event.detail.street.toUpperCase() : '';
      this.city = event.detail.city ? event.detail.city.toUpperCase() : '';
      this.suite = event.detail.subpremise ? event.detail.subpremise.toUpperCase() : '';
      this.state = event.detail.province ? event.detail.province.toUpperCase() : '';
      this.zipCode = event.detail.postalCode;
      this.country = event.detail.country ? event.detail.country.toUpperCase() : '';
     
  }
  
    // -------------------------------------- Additional Service Requirment ----------------------------- //
  
    @track additionalServiceRequest;
  
  
  
  // -------------------------------------- Memo & Notes ----------------------------- //
  
    @track memo;
    @track notes;
  
  
    
    // -----------------------------------  Modification Details ------------------------------------------//
  
    @track modifiedBy;
    @track ModifiedDate;
  
    
  
    //----------------------------- Footer Function ----------------------------------  
  
  
    handlePrintPaymentReceipt() {
      console.log("Printing payment receipt");
    }
  
    handlePrintApostille() {
      console.log("Printing apostille submission document");
    }
  
    handleCancelWorkOrder() {
      updateApplicationStatusToDraft({ recordId: this.recordId })
        .then(() => {
          this.close("updateRecord");
        })
        .catch((error) => {
          console.error("Error reinstating order:", error);
        });
    }
  
    async handleAdd() {
      const isValid = this.validateInputs(); 
      if (isValid) {
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
              
              Return_Mail_Type__c: this.shippingMethod,
              e_Apostille_document_has_been_uploaded__c: this.pre_paid_shipping_label,
              ReturnMailDocument_s_will_be_picked_up__c: this.documentPickedUp,
              return_Mail_e_Apostille_Customer__c: this.e_Apostille_customer_upload,
              
              Id: this.recordId
          };
  
          console.log('--data--' + JSON.stringify(data));
  
          try {
              // First, update the Individual Application data
              const result = await updateIndividualApplicationData({ newRecord: data });
              
              this.recordId = result;
              this.showToast(
                  'Individual Application', 
                  this.recordId ? 'Request updated successfully!' : 'Request created successfully!', 
                  'success'
              );
  

               // Always call createDocumentChecklistItemsId, even if documents array is empty
              console.log('Documents to save:', JSON.stringify(this.documents));
              await createDocumentChecklistItemsId({
                  documentsJson: JSON.stringify(this.documents || []), // Pass an empty array if no documents
                  recordId: this.recordId,
                  destinationCountry: 'India'
              });

            console.log('Documents saved or deleted successfully');
  
              // Close the modal after a short delay
              setTimeout(() => {
                this.close('success');
                
              }, 500);
  ``
          } catch (error) {
              console.error('Error processing the request:', error);
              this.showToast('State Seal/Arms', 'Error processing the request. Please try again.', 'error');
          }
      } else {
          console.error('Form is not valid');
          // this.showToast('State Seal/Arms', 'Please fill all required fields correctly.', 'error');
      }
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
      let missingFields = [];
  
      // Get all input components
      const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group, lightning-input-address');
  
      inputComponents.forEach(inputCmp => {
          if (showErrors) {
              // Report validity only if showErrors is true
              inputCmp.reportValidity();
          }
  
          // Check each input's validity
          if (!inputCmp.checkValidity()) {
              allValid = false;
              missingFields.push(inputCmp.label); // Collect labels of invalid fields
          }
      });
  
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
  
    handlePrintPaymentReceipt() {
      this.close();
  
      this.handlePrintPaymentReceiptModel();
    }
  
    async handlePrintPaymentReceiptModel() {
      
      const result = await PrintPaymentReceiptModal.open({
          recordId: this.recordId,
          size: 'small',
          records: this.workOrderNumber
      });
      if (result === 'cancel') {
        this.openModel();
        
      }
  }
  
    async openModel() {
      
      // Reopen the ApostilleOnlineRequestModel
      try {
          const result = await ApostilleOnlineRequestModel.open({
              size: "small",
              description: "Accessible description of modal's purpose",
              recordId: this.recordId,
              mode: "view"
          });
      } catch(error) {
          console.error('Error reopening modal:', error);
      }
    }
  
    handleModalCertificateAction(event) {
      this.openLetterModal();
    }
  
    async openLetterModal() {
      const result = await sap_ApostillePrintSubmissionDocumentV2.open({
        size: "medium",
        description: "Print Submission Document",
        label: "Print Submission Document",
        recordId: this.recordId
      });
      if (result === 'cancel') {
        this.openModel();
      
      }
    }
  
  }