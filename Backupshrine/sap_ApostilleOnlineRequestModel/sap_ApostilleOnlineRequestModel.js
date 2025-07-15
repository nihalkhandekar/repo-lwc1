/**
 * @description LWC component for handling Apostille Online Requests.
 *              This component manages document submission, payment processing,
 *              and user interactions.
 */
import { track, api, wire } from "lwc";
import LightningModal from "lightning/modal";
import ADDRESS_STYLES from "@salesforce/resourceUrl/sap_addressStyles";
import { loadStyle } from "lightning/platformResourceLoader";
import NewpopupOnlineRequestModel from "@salesforce/resourceUrl/sap_newpopupOnlineRequestModel";
import stateExtradition from "@salesforce/resourceUrl/sap_stateExtradition";
import getDocumentTypesAndFees from "@salesforce/apex/SAP_DocumentTypeFeeController.getDocumentTypesAndFees";
import getCountryHagueMappings from "@salesforce/apex/SAP_DocumentTypeFeeController.getCountryHagueMappings";
import getPaymentDetails from "@salesforce/apex/SAP_ApostilleLetterController.getPaymentDetails";
import getDocumentChecklistItemDetails from "@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItemDetails";
import deleteFile from "@salesforce/apex/SAP_FileUploaderClass.deleteFile";
import uploadFiles from "@salesforce/apex/SAP_FileUploaderClass.uploadFiles";
import getIndividualApplicationDetails from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getIndividualApplicationDetails";
import ApostillePrintSubmissionDocumentV2 from "c/sap_ApostillePrintSubmissionDocumentV2";
import generateJsonFromChecklistItemsByParentId from "@salesforce/apex/SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc";
import PrintPaymentReceiptModal2 from "c/sap_PrintPaymentReceiptModal2";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Contact_OBJECT from "@salesforce/schema/Contact";
import DocumentChecklistItem_OBJECT from "@salesforce/schema/DocumentChecklistItem";
import POSITION_FIELD from "@salesforce/schema/Contact.SAP_Position__c";
import ContactSearchModal from "c/sap_ContactSearchModal";
import getStateSealStaffData from "@salesforce/apex/SAP_StateSealApplicationController.getStateSealStaffData";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import updateAllData from "@salesforce/apex/SAP_OnlineRequestSubmissionController.updateAllData";
import getRejectionReasonPicklistValues from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getRejectionReasonPicklistValues";
import loadPreviousPayment from "@salesforce/apex/SAP_LoadPaymentDataController.loadPreviousPayment";
import createMultipleTransaction from "@salesforce/apex/SAP_InsertPaymentDataController.createMultipleTransaction";
import updateTransaction from "@salesforce/apex/SAP_InsertPaymentDataController.updateTransaction";
import deleteTransaction from "@salesforce/apex/SAP_InsertPaymentDataController.deleteTransaction";
import getRelatedFilesByRecordId from "@salesforce/apex/SAP_FileUploaderClass.getRelatedFilesByRecordId";
import storeCurrentUserIfNull from "@salesforce/apex/SAP_OnlineRequestSubmissionController.storeCurrentUserIfNull";
import getCurrentUserDetails from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getCurrentUserDetails";
import clearCurrentUser from "@salesforce/apex/SAP_OnlineRequestSubmissionController.clearCurrentUser";
import userId from "@salesforce/user/Id";
import getApplicationDetails from "@salesforce/apex/SAP_ApostilleIADetails.getApplicationDetails";
import isCurrentUserAdmin from "@salesforce/apex/SAP_DocumentChecklistJsonGenerator.isCurrentUserAdmin";
import inHouseRefundFee from "@salesforce/apex/SAP_ApostilleSubmittedRequestController.inHouseRefundFee";
import inHousePartialRefundFee from "@salesforce/apex/SAP_ApostilleSubmittedRequestController.inHousePartialRefundFee";

export default class ApostilleOnlineRequestModel extends NavigationMixin(
  LightningModal
) {
  @track isReadOnly = false;
  @track isModelOpen = true;
  @track AutorityOptions = [];
  @track mode = "";
  @track isCardPayment;
  @track recordId;
  @track workOrderNumber;
  @track isLoading = true;
  @track isAdminUser = false;
  originalPaymentList = [];
  @track currentUserId;
  @track userName;
  @track uploadedFilesForPrePaidShipping = [];
  @track uploadedFilesForOtherOptions = [];


  /**
   * @description Fetches current page reference and initializes recordId and mode.
   *              If mode is "edit", locks the record to prevent simultaneous edits.
   */

  @wire(CurrentPageReference)
  pageRefChanged({ state }) {
    if (state && state.c__record) {
      this.recordId = state.c__record;
      this.mode = state.c__mode || "view";
      this.currentUserId = userId;

      // Call refreshData without chaining then
      this.refreshData();

      // Handle edit mode if needed
      if (this.mode === "edit") {
        this.handleCurrentUser({
          recordId: this.recordId,
          currentUserId: this.currentUserId,
          showToast: this.showToast.bind(this)
        });
      }
    }
  }

  @wire(isCurrentUserAdmin)
  wiredAdminFlag({ data, error }) {
    if (data) {
      this.isAdminUser = data;
      console.log("IS admin flag", this.isAdminUser);
    } else if (error) {
      console.error("Error determining admin status:", error);
    }
  }

  get isWorkOrderStatusEnabled() {
    if (this.isReadOnly || !this.isAdminUser) {
      return true;
    }
    return false;
  }

  // Utility function to handle current user operations
  async handleCurrentUser({ recordId, currentUserId, showToast }) {
    try {
      // Store current user if null
      await storeCurrentUserIfNull({ recordId });

      // Fetch the current user details assigned to the record
      const userDetails = await getCurrentUserDetails({ recordId });

      // Check if the stored user ID matches the current user ID
      if (userDetails.userId && userDetails.userId !== currentUserId) {
        // Show an alert with the name of the user currently handling the request
        this.userName = userDetails.userName || "another user";
        showToast(
          "Alert",
          `This request is currently being handled by ${this.userName}.`,
          "warning"
        );

        // Set read-only mode
        this.isReadOnly = true;
        this.mode = "view";
        return false;
      }

      // Set edit mode
      this.isReadOnly = false;
      this.mode = "edit";
      return true;
    } catch (error) {
      console.error("Error handling current user:", error);
      showToast("Error", "Failed to lock record for editing.", "error");

      // Ensure it is read-only in case of failure
      this.isReadOnly = true;
      this.mode = "view";
      return false;
    }
  }

  // Utility function to clear the current user
  async clearCurrentUserUtil({ recordId, showToast }) {
    try {
      const result = await clearCurrentUser({ recordId });

      if (result === false) {
        // Lock is held by another user
        return false;
      }

      return true;
    } catch (error) {
      console.error("Error clearing current user:", error);
      return false;
    }
  }

  // Helper method to extract readable error messages
  extractErrorMessage(error) {
    let message = "Unknown error";

    if (error) {
      if (error.body && error.body.message) {
        message = error.body.message;
      } else if (error.message) {
        message = error.message;
      } else if (typeof error === "string") {
        message = error;
      }
    }

    return message;
  }

  /**
   * @description Returns the appropriate header text based on record status.
   * @returns {String} Header text for modal.
   */

  get headerText() {
    if (!this.idofrecord) {
      return "View Apostille Request";
    }
    return this.isReadOnly
      ? "View Apostille Request"
      : "Edit Apostille Request";
  }

  /**
   * @description Handles edit button click to unlock the record for editing.
   */

  async handleEditClick() {
    const canEdit = await this.handleCurrentUser({
      recordId: this.recordId,
      currentUserId: this.currentUserId,
      showToast: this.showToast.bind(this)
    });

    if (canEdit) {
      this.isReadOnly = false;
      this.paymentList = this.originalPaymentList.map((payment) => ({
        ...payment,
        readOnlyMode: payment.paymentType === "Card"
      }));
    }
  }

  /**
   * @description Checks if the remove button should be visible for the given index.
   * @param {Number} index - Index of the item in the list.
   * @returns {Boolean} True if the remove button should be visible, false otherwise.
   */

  isRemoveButtonVisible(index) {
    return index > 0;
  }

  /**
   * @description Handles navigation back from the modal and clears user lock.
   */

  async goBackModal() {
    try {
      const cleared = await this.clearCurrentUserUtil({
        recordId: this.recordId,
        showToast: this.showToast.bind(this)
      });

      if (cleared) {
        // Lock was successfully cleared, proceed with next steps
      } else {
        // Lock couldn't be cleared, handle accordingly
        this.isReadOnly = true;
        this.mode = "view";
      }
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_ApostilleOnlineRequest"
        }
      });
    } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
    }
  }

  get selectCountry() {
    return this.isReadOnly ? "" : "Select Country";
  }

  get documentType() {
    return this.isReadOnly ? "" : "Select Document";
  }

  get destinationCountry() {
    return this.isReadOnly ? "" : "Destination country";
  }

  get personName() {
    return this.isReadOnly ? "" : "Enter Name of Person";
  }

  get copyNumberPlaceholder() {
    return this.isReadOnly ? "" : "Enter Copy Number";
  }

  get fedEx() {
    return this.isReadOnly ? "" : "1234 5678 9012";
  }

  get modifiedBy() {
    return this.isReadOnly ? "" : "John Doe";
  }

  get ModifiedDate() {
    return this.isReadOnly ? "" : "mm/dd/yyyy";
  }

  /**
   * @description Loads external CSS styles upon component initialization.
   */

  connectedCallback() {
    this.currentUserId = userId;
    Promise.all([
      loadStyle(this, ADDRESS_STYLES),
      loadStyle(this, NewpopupOnlineRequestModel),
      loadStyle(this, stateExtradition)
    ])
      .then(() => {})
      .catch((error) => {
        console.error("Error loading CSS file:", error);
      });

    this.loadExistingPayment();
    this.processFiles();
  }

  /**
   * @description Refreshes component data.
   */
  refreshData() {
    this.initializeData();
  }

  /**
   * @description Initializes the component, fetching necessary data.
   */
  initializeData() {
    this.isLoading = true;
    this.fetchStaffData();
    if (this.mode === "view") {
      this.isReadOnly = true;
    } else if (!this.recordId) {
      this.isReadOnly = false;
      this.showSaveData();
    }

    if (this.recordId) {
      this.idofrecord = this.recordId;
    }

    this.fetchData();
    this.loadExistingPayment();
    this.clearPaymentFields();
  }

  /**
   * @description Fetches necessary data related to individual and document details.
   *              Adds a slight delay to simulate a loading state.
   */

  async fetchData() {
    setTimeout(() => {
      this.isLoading = false;
    }, 1000);

    refreshApex(this.wiredIndividualData);
    this.refreshKey++;
    refreshApex(this.wiredDocumentData)
      .then(() => {})
      .catch((error) => {
        console.error("Error refreshing document data", error);
      });
  }

  /**
   * @description Fetches staff data for State Seal Staff and filters based on allowed titles.
   *              Populates the list of authority options with formatted name and title.
   */

  async fetchStaffData() {
    getStateSealStaffData()
      .then((result) => {
        const allowedTitles = [
          "Deputy Secretary of the State",
          "Secretary of the State"
        ];
        this.AutorityOptions = result
          .filter((staff) => allowedTitles.includes(staff.SAP_Staff_Title__c))
          .map((staff) => ({
            label: `${staff.FirstName} ${staff.LastName}, ${staff.SAP_Staff_Title__c}`,
            value: staff.Id
          }));
      })
      .catch((error) => {
        console.error("Error fetching staff data: ", error);
      });
  }
  @track recordDetailsList;
  wiredIndividualData;

  /**
   * @description Fetches individual application details based on recordId.
   *              Modifies data to include a flag for 'Order Complete' status.
   */
  @wire(getIndividualApplicationDetails, { recordId: "$recordId" })
  wiredRecordDetails(result) {
    console.log("getIndividualApplicationDetails wire triggered", result);

    this.wiredIndividualData = result;
    const { data, error } = result;
    if (data) {
      const checkStatusAsOrderComplete = data.Status
        ? data.Status.includes("Order Complete")
        : false;
      const modifiedData = { ...data, checkStatusAsOrderComplete };

      this.recordDetailsList = [modifiedData];
      this.assignRecordDetails(modifiedData);
      console.log("individual is working");
    } else if (error) {
      console.error("Error fetching record details:", error);
      this.recordDetailsList = [];
    }
  }

  @track checkStatusAsOrderComplete = false;

  /**
   * @description Assigns record details to class variables for use in UI.
   * @param {Object} recordDetails - Object containing details of the application record.
   */

  @track oldStatus;

  assignRecordDetails(recordDetails) {
    this.oldStatus = recordDetails.Status;
    this.workOrderNumber = recordDetails.SAP_Sequence_Number__c;
    this.lastName = recordDetails.SAP_Last_Name__c;
    this.firstName = recordDetails.SAP_First_Name__c;
    this.organizationName = recordDetails.SAP_Organization_Name__c;
    this.emailAddress = recordDetails.SAP_Email_Address__c;
    this.phoneNumber = recordDetails.SAP_Cell_Phone_Number__c;
    this.workOrderStatus = recordDetails.Status;

    this.addressLine1 = recordDetails.SAP_Address_Line_1_Shipping__c || "";
    this.suite = recordDetails.SAP_Suite_Apartment_Floor_Shipping__c;
    this.city = recordDetails.SAP_City_Shipping__c;
    this.state = recordDetails.SAP_State_Shipping__c;
    this.zipCode = recordDetails.SAP_Zip_Code_Shipping__c;
    this.country = recordDetails.SAP_Country_Shipping__c;

    this.businessName = recordDetails.SAP_Agency_Business_Name__c;
    this.firstNameindividual = recordDetails.SAP_Agency_First_Name__c;
    this.lastNameindividual = recordDetails.SAP_Agency_Last_Name__c;
    this.emailAddressindividual = recordDetails.SAP_Agency_Email_Address__c;
    this.cellPhoneNumber = recordDetails.SAP_Agency_Cell_Phone__c;
    this.emailReceivingApostille =
      recordDetails.Email_Address_For_Receiving_Apostille__c;

    this.selectedCountry = recordDetails.SAP_documentDestinationCountry__c;
    this.selectedHagueStatus = recordDetails.SAP_HagueStatus__c;
    this.destinationCountrySameString =
      recordDetails.SAP_Destination_Country__c;
    this.destinationCountrySame =
      recordDetails.SAP_documentDestinationCountryBoolean__c;
    this.expedite = recordDetails.SAP_Expedited__c;
    this.expediteRequest = recordDetails.SAP_Expedite_Request_Boolean__c;
    this.expediteRequestString = recordDetails.SAP_Expedite_Request__c;

    this.shippingMethod = recordDetails.SAP_Return_Mail_Type__c;
    this.fedEx = recordDetails.SAP_FedEX__c;
    this.isOption1Checked = !(
      recordDetails.SAP_Prepaid_Shipping_Label_Uploaded__c ||
      recordDetails.SAP_Document_Pickup_Notification__c ||
      recordDetails.SAP_return_Mail_e_Apostille_Customer__c
    );
    this.pre_paid_shipping_label =
      recordDetails.SAP_Prepaid_Shipping_Label_Uploaded__c;
    this.documentPickedUp = recordDetails.SAP_Document_Pickup_Notification__c;
    this.e_Apostille_customer_upload =
      recordDetails.SAP_return_Mail_e_Apostille_Customer__c;

    this.modifiedBy = recordDetails.LastModifiedBy?.Name;
    this.ModifiedDate = recordDetails.LastModifiedDate;
    this.additionalServiceRequest = recordDetails.SAP_Instructions__c;
    this.notes = recordDetails.SAP_Notes_on_Receipt__c;
    this.memo = recordDetails.SAP_Receipt_Memo__c;
    this.checkStatusAsOrderComplete = recordDetails.checkStatusAsOrderComplete;
  }

  /**
   * @description Handles key down event for phone number input.
   *              Ensures only numeric values and necessary control keys are allowed.
   * @param {Event} event - The keydown event object.
   */

  handlePhoneKeyDown(event) {
    const allowedKeys = [
      "Backspace",
      "ArrowLeft",
      "ArrowRight",
      "Delete",
      "Tab",
      "Home",
      "End"
    ];

    if (
      /^\d$/.test(event.key) ||
      allowedKeys.includes(event.key) ||
      (event.key.toLowerCase() === "a" && (event.ctrlKey || event.metaKey))
    ) {
      return;
    }

    event.preventDefault();
  }

  // Helper function to find the position in formatted string after a specific number of digits
  getPositionAfterFormat(formattedValue, digitCount) {
    let position = 0;
    let foundDigits = 0;

    while (foundDigits < digitCount && position < formattedValue.length) {
      if (/\d/.test(formattedValue[position])) {
        foundDigits++;
      }
      position++;
    }

    return position;
  }

  formatPhoneNumber(value) {
    const digitsOnly = value.replace(/\D/g, "");
    let formattedValue = "";

    if (digitsOnly.length > 0) {
      formattedValue += `(${digitsOnly.slice(0, 3)}`;
    }
    if (digitsOnly.length > 3) {
      formattedValue += `) ${digitsOnly.slice(3, 6)}`;
    }
    if (digitsOnly.length > 6) {
      formattedValue += `-${digitsOnly.slice(6, 10)}`;
    }

    return formattedValue;
  }

  /**
   * @description Handles input changes and applies formatting for phone number fields.
   * @param {Event} event - The input change event.
   */
  handleInputChange(event) {
    const field = event.target.name;
    const value = event.target.value;

    if (field === "emailAddress") {
      // Regular expression for basic email validation
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

      if (!emailPattern.test(value)) {
        event.target.setCustomValidity(
          "Enter a valid email address, such as name@email.com"
        );
      } else {
        event.target.setCustomValidity("");
      }

      event.target.reportValidity();
      this.emailAddress = value;
    } else if (field === "phoneNumber") {
      const input = event.target;
      const cursorPos = input.selectionStart;

      // Get the previous value and digits
      const previousValue = this.phoneNumber || "";
      const previousDigits = previousValue.replace(/\D/g, "");

      // Get the new value and digits
      const digitsOnly = value.replace(/\D/g, "");
      const truncatedDigits = digitsOnly.slice(0, 10);

      // Determine if a digit was added or removed
      const isAddingDigit = digitsOnly.length > previousDigits.length;
      const isDeletingDigit = digitsOnly.length < previousDigits.length;

      // Format the new value
      const formattedValue = this.formatPhoneNumber(truncatedDigits);
      this.phoneNumber = formattedValue;

      input.setCustomValidity("");
      input.reportValidity();

      // Calculate the new cursor position
      let newCursorPos = cursorPos;

      if (isDeletingDigit) {
        // When deleting, adjust the cursor position only if it's at a formatting character
        if (previousValue.charAt(cursorPos - 1).match(/\D/)) {
          newCursorPos -= 1;
        }
      } else if (isAddingDigit) {
        // When adding, move the cursor forward if a formatting character is added
        if (
          formattedValue.charAt(cursorPos).match(/\D/) &&
          cursorPos < formattedValue.length
        ) {
          newCursorPos += 1;
        }
      }

      // Ensure the cursor position stays within bounds
      newCursorPos = Math.max(0, Math.min(newCursorPos, formattedValue.length));

      // Set the cursor position after the DOM updates
      requestAnimationFrame(() => {
        const phoneInput = this.template.querySelector(
          'lightning-input[name="phoneNumber"]'
        );
        if (phoneInput) {
          phoneInput.setSelectionRange(newCursorPos, newCursorPos);
          phoneInput.focus();
        }
      });
    } else if (field === "lastName") {
      if (value.length >= 1) {
        event.target.setCustomValidity("");
        event.target.reportValidity();
      }
      this.lastName = value;
    } else if (field === "firstName") {
      if (value.length >= 1) {
        event.target.setCustomValidity("");
        event.target.reportValidity();
      }
      this.firstName = value;
    } else {
      this[field] = value;
    }
  }

  @track lastName;
  @track workOrderStatus;

  apostilleStatusOptions = [
    { label: "Payment Captured", value: "Payment Captured" },
    { label: "Payment Pending", value: "Payment Pending" },
    { label: "Documents Received", value: "Documents Received" },
    { label: "Cancelled By Staff", value: "Cancelled By Staff" },
    { label: "Cancelled By Customer", value: "Cancelled By Customer" },
    { label: "Order Completed - Mail", value: "Order Completed - Mail" },
    { label: "Order Completed – Pick Up", value: "Order Completed – Pick Up" }
  ];

  @track expediteRequest = false;
  @track expedite;
  @track expediteRequestString = "no";
  @track destinationCountrySame = false;
  @track sameAddressString = "no";
  @track destinationCountrySameString;
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
  @track statusOptions = [];
  @track documentsForPrintCertificate = [];

  @track selectedFileId = null;
  @track selectedFileName = null;
  @track selectedDocId = null;

  recordTypeId;

  /**
   * @description Fetches object metadata for Contact and extracts Record Type ID.
   */
  @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
  contactObjectInfo({ error, data }) {
    if (data) {
      const recordTypeName = "Apostille Official";
      const recordTypes = data.recordTypeInfos;

      for (let key in recordTypes) {
        if (
          recordTypes[key].name === recordTypeName ||
          recordTypes[key].developerName === recordTypeName
        ) {
          this.recordTypeId = recordTypes[key].recordTypeId;
          break;
        }
      }

      if (!this.recordTypeId) {
        console.error(
          `Record Type '${recordTypeName}' not found for Contact object.`
        );
      }
    } else if (error) {
      console.error("Error fetching Contact object info", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: DocumentChecklistItem_OBJECT })
  documentChecklistItemObjectInfo;

  /**
   * @description Fetches and maps picklist values for signing authority positions.
   */

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: POSITION_FIELD
  })
  positionPicklistValues({ error, data }) {
    if (data) {
      // Adding the 'None' option at the start of the picklist options
      this.signedByPositionOptions = [
        { label: "-- None --", value: "" }, // Static "None" option
        ...data.values.map((picklistOption) => ({
          label: picklistOption.label,
          value: picklistOption.value
        }))
      ];
    } else if (error) {
      console.error("Error fetching signed by values", error);
      this.signedByPositionOptions = [];
    }
  }

  statusOptions = [
    { label: "Document Received", value: "Document Received" },
    { label: "Rejected", value: "Rejected" },
    { label: "Approved", value: "Approved" },
    { label: "Pending Documents", value: "Pending" }
  ];

  /**
   * @description Fetches checklist items and generates JSON structure for processing.
   */

  @track refreshKey = 0;

  wiredDocumentData;
  @wire(generateJsonFromChecklistItemsByParentId, {
    individualApplicationId: "$recordId",
    refreshKey: "$refreshKey"
  })
  wiredChecklistItems(value) {
    console.log("Checklist wire triggered", value);

    this.wiredDocumentData = value;
    const { error, data } = value;

    if (data) {
      try {
        const parsedDocuments = JSON.parse(data);

        // Assign payment list
        this.paymentList = (parsedDocuments.paymentDetails || []).map(
          (payment) => {
            return {
              ...payment,
              readOnlyMode:
                this.mode == "view" ? true : payment.paymentType === "Card",
              isCardPayment: payment.paymentType === "Card"
            };
          }
        );

        this.originalPaymentList = JSON.parse(JSON.stringify(this.paymentList));

        // Assign document for printDocumentCertificate
        this.documentsForPrintCertificate = (
          parsedDocuments.documentChecklistItems || []
        )
          .filter(
            (doc) => doc.status === "Approved" || doc.status === "Accepted"
          )
          .map((doc) => ({
            docId: doc.id,
            status: doc.status,
            personName: doc.personName,
            docType: doc.typeOfDocument,
            certificateNo: doc.certificateNumber,
            sealStramp: doc.signedStamp || "",
            lastModDate: doc.lastModDate,
            signedBy: doc.signedByName,
            position: doc.signedByPosition,
            destination: doc.destinationCountry,
            hagueStatus: doc.hague,
            signingAuthorityName: doc.autorityName,
            signningAuthorityTitle: doc.authorityTitle,
            parentRecordId: this.recordId,
            copyNumber: doc.copyNumber
          }));

        console.log(
          "documentsForPrintCertificate:",
          JSON.stringify(this.documentsForPrintCertificate, null, 2)
        );

        // Process documents and add statusRejected flag
        this.documents = (parsedDocuments.documentChecklistItems || []).map(
          (doc) => ({
            ...doc,
            statusRejected: doc.status === "Rejected"
          })
        );

        console.log(
          "documentsForTable:",
          JSON.stringify(this.documents, null, 2)
        );

        // Call additional methods with safeguards
        if (this.updateDocumentFees) {
          this.updateDocumentFees();
        } else {
          console.error("updateDocumentFees method is not defined.");
        }

        if (this.initializeRadioStates) {
          this.initializeRadioStates();
        } else {
          console.error("initializeRadioStates method is not defined.");
        }

        if (this.updateCountryFieldState) {
          this.updateCountryFieldState();
        } else {
          console.error("updateCountryFieldState method is not defined.");
        }
      } catch (parseError) {
        console.error("Error parsing documents:", parseError);
        console.error("Original result:", data);
      }
    } else if (error) {
      console.error("Error fetching documents:", error);
    }
  }

  /**
   * Initializes the state of various radio button options based on current property values.
   * - Sets `expediteRequest`, `expedite`, and `expediteRequestString` values based on `expediteRequest`.
   * - Updates the CSS class for the expedite radio button selection.
   * - Determines if the destination country is the same and updates related properties.
   * - Determines if the same address is being used and updates related properties.
   */

  initializeRadioStates() {
    if (this.expediteRequest === true) {
      this.expediteRequest = true;
      this.expedite = true;
      this.expediteRequestString === "yes";
      this.radioCssExp = "radioOptionsChecked";
      this.radioCssCheckedExp = "radioOptions";
    } else {
      this.expediteRequest = false;
      this.expedite = false;
      this.expediteRequestString === "no";
      this.radioCssExp = "radioOptions";
      this.radioCssCheckedExp = "radioOptionsChecked";
    }
    if (this.destinationCountrySameString === "yes") {
      this.destinationCountrySame = true;
      this.radioCssDes = "radioOptionsChecked";
      this.radioCssCheckedDes = "radioOptions";
    } else {
      this.destinationCountrySame = false;
      this.radioCssDes = "radioOptions";
      this.radioCssCheckedDes = "radioOptionsChecked";
    }

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

    this.updateDocumentFees();
  }

  /**
   * Retrieves document types and associated fees from the server.
   * - Filters out the "Expedite" fee and stores it separately.
   * - Maps the remaining document types to be used in a dropdown/select list.
   * - Stores the fee for each document type in an object for easy access.
   * - Calls `updateDocumentFees()` to ensure fees are properly updated.
   */

  @wire(getDocumentTypesAndFees)
  wiredDocumentTypesAndFees({ error, data }) {
    if (data) {
      const filteredData = data.filter((item) => {
        if (item.Label === "Expedite") {
          this.expediteFee = item.SAP_Fee__c;
          return false;
        }
        return true;
      });
      this.documentTypes = filteredData.map((item) => {
        // Correct the label first
        const correctedLabel = item.Label.startsWith(
          "Articles of Incorporation (Certified Cop"
        )
          ? "Articles of Incorporation (Certified Copy)"
          : item.Label;

        // Store fee with the corrected label
        this.documentFees[correctedLabel] = item.SAP_Fee__c;

        return {
          label: correctedLabel,
          value: correctedLabel
        };
      });

      this.updateDocumentFees();
    } else if (error) {
      console.error("Error fetching Document Types and Fees", error);
    }
  }

  /**
   * Retrieves country-Hague mappings from the server.
   * - Maps the country names for use in dropdown/select fields.
   * - Stores the Hague convention status for each country.
   */
  @wire(getCountryHagueMappings)
  wiredCountryHagueMappings({ error, data }) {
    if (data) {
      this.countryOptions = data.map((item) => ({
        label: item.SAP_Country__c,
        value: item.SAP_Country__c
      }));

      data.forEach((item) => {
        this.hagueMapping[item.SAP_Country__c] = item.SAP_Hague_Status__c;
      });
    } else if (error) {
      console.error("Error fetching Country Hague Mappings", error);
    }
  }
  /**
   * Handles input changes for various document-related fields.
   * - Prevents modification if the form is in read-only mode.
   * - Updates `selectedCountry` and Hague status when country selection changes.
   * - Handles changes to the "destinationCountrySameString" field, updating related state variables.
   * - Updates document fees and checks for expedite-related adoption document errors.
   */
  handleInputChangeDocument(event) {
    if (this.isReadOnly) return;

    const { name, value } = event.target;

    if (name === "selectedCountry") {
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
        this.selectedHagueStatus = "";
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
        this.expedite = true;
        this.radioCssExp = "radioOptionsChecked";
        this.radioCssCheckedExp = "radioOptions";
        this.updateDocumentFees();

        const hasAdoptionDocument = this.documents.some(
          (doc) => doc.typeOfDocument === "Adoption Documents"
        );
        if (hasAdoptionDocument) {
          this.showExpediteAdoptionError = true;
        } else {
          this.showExpediteAdoptionError = false;
        }
      } else if (value === "no") {
        this.expediteRequestString = "no";
        this.expediteRequest = false;
        this.expedite = false;
        this.radioCssExp = "radioOptions";
        this.radioCssCheckedExp = "radioOptionsChecked";
        this.updateDocumentFees();
        this.showExpediteAdoptionError = false;
      }
    }
  }
  /**
   * Updates the Hague status based on the selected country.
   * - Fetches the Hague status from `hagueMapping`.
   * - Calls `updateCountryFieldState()` to apply changes.
   */
  updateHagueStatus(selectedCountry) {
    const hagueStatus = this.hagueMapping[selectedCountry];

    this.selectedHagueStatus = hagueStatus;
    this.updateCountryFieldState();
  }
  /**
   * Updates country-related field states in the document list.
   * - Ensures that documents reflect the selected country and Hague status.
   * - Calls `updateDocumentFees()` to recalculate fees accordingly.
   */
  updateCountryFieldState() {
    if (this.destinationCountrySameString === "yes" && this.selectedCountry) {
      this.documents = this.documents.map((doc) => ({
        ...doc,
        country: this.selectedCountry,
        hague: this.selectedHagueStatus === "True" ? "Yes" : "No"
      }));
    }

    this.updateDocumentFees();
  }
  /**
   * Adds a new document entry to the list.
   * - Prevents action if in read-only mode.
   * - Pre-fills authority field based on available options.
   * - Assigns a unique ID to the document.
   * - Ensures Hague status is stored as "Yes" or "No".
   * - Calls `updateDocumentFees()` after adding the new document.
   */

  handleAction(event) {
    const action = event.detail.value;
    const rowId = event.target.dataset.id;
    console.log("Action Click", rowId);

    if (action === "delete_doc") {
      this.handleRemoveDocument(rowId);
    } else if (action === "no_fee") {
      this.documents = this.documents.map((doc) => {
        if (doc.id === rowId) {
          return { ...doc, isNoFee: !doc.isNoFee }; // toggle value
        }
        return doc;
      });
    }
  }
  handleAddDocument() {
    if (this.isReadOnly) return;

    const defaultAuthority = this.AutorityOptions.find((option) =>
      option.label.toLowerCase().includes("secretary of the state")
    );

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
      copyNumber: "",
      fee: "0.00",
      baseFee: "0.00",
      feeDisplay: "$0.00",
      signedByName: "",
      signedByPosition: "",
      selectedContactID: "",
      autority: defaultAuthority ? defaultAuthority.value : "",
      status: "Pending",
      termStart: null,
      termEnd: null,
      uploadedFiles: [],
      isAddedByAgent: true,
      isNoFee: false
    };

    newDocument.hague = newDocument.hague ? "Yes" : "No";

    this.documents = [...this.documents, newDocument];

    this.updateDocumentFees();
  }
  /**
   * Removes a document from the list based on its ID.
   * - Prevents action if in read-only mode.
   * - Updates document fees after removal.
   * - Checks if the removed document affects the expedite request validation.
   */
  handleRemoveDocument(id) {
    if (this.isReadOnly) return;

    this.documents = this.documents.filter(
      (doc) => String(doc.id) !== String(id)
    );

    const hasAdoptionDocumentWithExpedite = this.documents.some(
      (doc) =>
        doc.typeOfDocument === "Adoption Documents" &&
        this.isExpedited === "true"
    );

    if (!hasAdoptionDocumentWithExpedite) {
      this.showExpediteAdoptionError = false;
    }

    this.updateDocumentFees();
  }

  /**
   * Handles document field changes dynamically.
   * - Updates the corresponding document property based on the event name.
   * - Updates fees when document type changes.
   * - Handles Hague status and uploaded files.
   */

  handleDocumentChange(event) {
    const { name, value, dataset } = event.target;
    const id = dataset.id;

    console.log("field name:  " + name + " value is :  " + value);

    this.documents = this.documents.map((doc) => {
      if (doc.id === id) {
        let updatedFee = doc.fee;
        let baseFee = doc.baseFee;
        let updatedHagueStatus = doc.hague;
        let updatedCountry = doc.country;
        let updatedPersonName = doc.personName;
        let updatedCopyNumber = doc.copyNumber;
        let updatedSignedByName = doc.signedByName;
        let updatedSignedByPosition = doc.signedByPosition;
        let updatedselectedContactID = doc.selectedContactID;
        let updatedStatus = doc.status;
        let updatedAutority = doc.autority;
        let updatedTermStart = doc.termStart;
        let updatedTermEnd = doc.termEnd;
        let updatedcheckDocumentType = doc.checkDocumentType;
        let updatedUploadedFiles = doc.uploadedFiles || [];
        let contentDocumentId =
          updatedUploadedFiles.length > 0
            ? updatedUploadedFiles[0].documentId
            : null;
        let updatedStatusRejected = doc.statusRejected || false;
        let updatedRejectionReason = doc.rejectionReason || null;
        let updatedCustomerRejectionReason =
          doc.customerRejectionReason || null;

        switch (name) {
          case "typeOfDocument":
            if (this.documentFees[value]) {
              baseFee = this.documentFees[value];
              updatedFee = baseFee;
              updatedcheckDocumentType =
                value == "SOTS Certified Copies" ? true : false;
              if (updatedcheckDocumentType == false) {
                this.deleteFileById(contentDocumentId);
                updatedUploadedFiles = [];
              }
            }

            if (
              value === "Adoption Documents" &&
              this.expediteRequestString === "yes"
            ) {
              this.showExpediteAdoptionError = true;
            } else {
              this.showExpediteAdoptionError = false;
            }
            break;
          case "destinationCountry":
            if (this.hagueMapping[value] !== undefined) {
              updatedHagueStatus =
                this.hagueMapping[value] === "True" ? "Yes" : "No";
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
            if (doc.status === "Rejected" && value !== "Rejected") {
              updatedStatusRejected = false;
              updatedRejectionReason = null;
              updatedCustomerRejectionReason = null;
            }
            updatedStatusRejected = value === "Rejected";
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
          selectedContactID: updatedselectedContactID,
          status: updatedStatus,
          autority: updatedAutority,
          termStart: updatedTermStart,
          termEnd: updatedTermEnd,
          checkDocumentType: updatedcheckDocumentType,
          uploadedFiles: updatedUploadedFiles,
          statusRejected: updatedStatusRejected,
          rejectionReason: updatedRejectionReason,
          customerRejectionReason: updatedCustomerRejectionReason
        };
      }
      return doc;
    });

    this.documents = [...this.documents];

    this.updateDocumentFees();
  }
  /**
   * Handles contact search based on key type into input box.
   */
  async handleSearch(event) {
    const docId = event.target.dataset.id;
    const currentDoc = this.documents.find((doc) => doc.id === docId);
    const searchKey = currentDoc.signedByName;
    const position = currentDoc.signedByPosition;

    if (searchKey) {
      document.body.style.overflow = "hidden";
      try {
        if (searchKey.length >= 2) {
          const selectedContact = await ContactSearchModal.open({
            size: "medium",
            description: "Select Contact",
            searchKey: searchKey,
            position: position
          });

          if (selectedContact) {
            currentDoc.signedByName = selectedContact.Name;
            console.log("Selected Officla Stamp", selectedContact.sealstamp);
            this.updateDocumentFields(
              docId,
              selectedContact.name,
              selectedContact.sealstamp,
              selectedContact.position,
              selectedContact.selectedContactID,
              selectedContact.termStart,
              selectedContact.termEnd
            );
          }
        }
      } finally {
        document.body.style.overflow = "auto";
      }
    }
  }
  /**
   * Handles selected contact and update.
   */
  updateDocumentFields(
    docId,
    name,
    sealstamp,
    position,
    selectedID,
    termStart,
    termEnd
  ) {
    const docIndex = this.documents.findIndex((doc) => doc.id === docId);

    if (docIndex !== -1) {
      this.documents[docIndex].signedByName = name;
      this.documents[docIndex].signedByPosition = position;
      this.documents[docIndex].signedStamp = sealstamp;
      this.documents[docIndex].selectedContactID = selectedID;
      this.documents[docIndex].termStart = termStart;
      this.documents[docIndex].termEnd = termEnd;
      this.documents = [...this.documents];
    } else {
      console.error(
        `Document with ID ${docId} not found in updateDocumentFields.`
      );
    }
    console.log(
      "Document after contact select:",
      JSON.stringify(this.documents[docIndex], null, 2)
    );
  }

  fileData;
  /**
   * Handles file upload and updates the document object with the uploaded file.
   */
  openfileUpload(event) {
    const file = event.target.files[0];
    const docId = event.target.closest("div").dataset.docId;

    var reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(",")[1];
      const filename = file.name;

      this.fileData = {
        filename: file.name,
        base64: base64,
        recordId: docId
      };

      const mergeFileNameBased64 = { filename, base64 };

      this.handleDocumentChange({
        target: {
          name: "uploadedFiles",
          value: mergeFileNameBased64,
          dataset: { id: docId }
        }
      });
    };

    reader.onerror = () => {
      console.error("Error reading the file");
    };
    reader.readAsDataURL(file);
  }
  /**
   * Computes the formatted total fee by summing base fees and expedite fees.
   */
  get formattedTotalFee() {
    // Filter out documents marked as No Fee
    const billableDocs = this.documents.filter((doc) => !doc.isNoFee);

    const baseTotalFee = billableDocs.reduce(
      (acc, doc) => acc + parseFloat(doc.baseFee || 0),
      0
    );

    const expediteTotalFee = billableDocs.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);

    const total = baseTotalFee + expediteTotalFee;
    this.totalAmount = total.toFixed(2);

    return `$${total.toFixed(2)}`;
  }

  get isDestinationCountrySame() {
    return this.destinationCountrySame == true;
  }

  get isNotDestinationCountrySame() {
    return this.destinationCountrySame == false;
  }

  get isHagueStatusYes() {
    return this.selectedHagueStatus === "True";
  }

  get isHagueStatusNo() {
    return this.selectedHagueStatus === "False";
  }

  get isExpediteSelected() {
    return this.expediteRequest == true;
  }
  get isNotExpediteSelected() {
    return this.expediteRequest == false;
  }
  /**
   * Computes the formatted base fee.
   */
  get formattedBaseFee() {
    const baseTotalFee = this.documents.reduce(
      (acc, doc) => acc + parseFloat(doc.baseFee || 0),
      0
    );
    this.totalAmount = baseTotalFee.toFixed(2);
    return `$${baseTotalFee.toFixed(2)}`;
  }
  /**
   * Computes the formatted expedite fee.
   */
  get formattedExpediteFee() {
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      if (!doc.isNoFee && doc.isExpedited) {
        return acc + parseFloat(this.expediteFee);
      }
      return acc;
    }, 0);

    return `$${expediteTotalFee.toFixed(2)}`;
  }

  /**
   * Updates the fee details for all documents based on the expedite request status.
   */
  updateDocumentFees() {
    const isExpediteSelected = this.expediteRequest == true;

    this.documents = this.documents.map((doc) => {
      let baseFee = parseFloat(doc.baseFee || 0);
      let expediteFee = 0;
      let totalFee = baseFee;
      let feeDisplay = `$${baseFee.toFixed(2)}`;

      if (isExpediteSelected) {
        expediteFee = parseFloat(this.expediteFee || 0);
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

  @track businessName;
  @track firstNameindividual;
  @track lastNameindividual;
  @track emailAddressindividual;
  @track cellPhoneNumber;
  @track phoneNumber;
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

  @track previousTrnxnPayment = [];
  @track isAdd = true;
  @track isEdit = false;
  @track editTransactionID = "";
  @track transactionIdToDelete = "";
  @track isCreditCard = false;
  @track isCheck = false;
  @track isMoneyOrder = false;
  @track paymentType = "";
  @track cardType = "";
  @track last4Digits = "";
  @track checkNumber = "";
  @track moneyOrderNo = "";
  @track paymentAmount = "";
  @track showConfirmationModal = false;
  @track totalAmountPayment = "";
  @track rows = [];

  @track paymentList = [];
  @track records = [];

  paymentTypeOptions = [
    { label: "Card", value: "Card" },
    { label: "Cash", value: "Cash" },
    { label: "Check", value: "Check" },
    { label: "Money Order", value: "Money Order" }
  ];

  cardTypeOptions = [
    { label: "Visa", value: "Visa" },
    { label: "MasterCard", value: "MasterCard" },
    { label: "American Express", value: "American Express" },
    { label: "Discover", value: "Discover" }
  ];

  /**
   * Loads and formats the previous payment records associated with the current transaction.
   * This function fetches payment records using the `loadPreviousPayment` method, processes them,
   * and updates the `previousTrnxnPayment` array with relevant payment details.
   */
  loadExistingPayment() {
    loadPreviousPayment({ recordId: this.recordId })
      .then((result) => {
        let totalNewAmount = 0;
        let totalRefundAmount = 0;

        this.previousTrnxnPayment = result.records.map((record) => {
          const formattedDate = this.formatDate(record.CreatedDate);
          const isRefund = record.RecordType?.Name === "Refund Transaction";

          // Parse amount (remove $ if present)
          const amount = parseFloat(
            record.TotalFeeAmount.toString().replace("$", "")
          );

          // Accumulate totals
          if (isRefund) {
            totalRefundAmount += amount;
          } else {
            totalNewAmount += amount;
          }

          // Format amount with minus sign for refunds
          const formattedAmount = `${isRefund ? "-" : ""}$${amount.toFixed(2)}`;

          const paymentNumber =
            record.SAP_Card_Number__c ||
            record.SAP_CK_Number__c ||
            record.SAP_Money_Order_Number__c;

          const cardType =
            record.SAP_Brand__c != ""
              ? record.SAP_Brand__c || record.SAP_Card_Type__c
              : "";

          const isCard = record.SAP_Payment_Type__c === "Card";
          const isDisabled = !!record.SAP_Auth_Code__c;

          return {
            ...record,
            TotalFeeAmount: formattedAmount,
            cardType,
            isCommunityUser: isDisabled,
            isCard,
            paymentNumber,
            CreatedDate: formattedDate
          };
        });

        // Final calculated total
        const finalAmount = totalNewAmount - totalRefundAmount;
        this.totalAmountPayment = `$${finalAmount.toFixed(2)}`;
      })
      .catch((error) => {
        console.error("Error fetching records", error);
        this.error = error;
      });

    this.isLoading = false;
  }

  /**
   * Capitalizes the first letter of each word in a given string.
   *
   * @param {string} str - The input string to be capitalized.
   * @returns {string} The capitalized string.
   */

  formatDate(dateString) {
    if (!dateString) {
      return "";
    }

    const dateObj = new Date(dateString);

    if (isNaN(dateObj.getTime())) {
      return dateString;
    }

    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(2, "0");
    const day = String(dateObj.getDate()).padStart(2, "0");

    return `${month}/${day}/${year}`;
  }
  /**
   * Handles changes in payment type selection (Card, Check, Money Order).
   * Based on the selected payment type, it resets other payment-specific fields (cardType, checkNumber, moneyOrderNo).
   *
   * @param {Event} event - The event triggered by the payment type selection.
   * @returns {void} Updates the relevant flags (`isCreditCard`, `isCheck`, `isMoneyOrder`) and resets the fields.
   */

  handleTypeChange(event) {
    this.paymentType = event.detail.value;
    this.isCreditCard = this.paymentType === "Card";
    this.isCheck = this.paymentType === "Check";
    this.isMoneyOrder = this.paymentType === "Money Order";
    event.target.setCustomValidity("");
    event.target.reportValidity();
    if (this.isCreditCard) {
      this.checkNumber = "";
      this.moneyOrderNo = "";
    } else if (this.isCheck) {
      this.cardType = "";
      this.last4Digits = "";
      this.moneyOrderNo = "";
    } else if (this.isMoneyOrder) {
      this.checkNumber = "";
      this.cardType = "";
      this.last4Digits = "";
    } else {
      this.checkNumber = "";
      this.moneyOrderNo = "";
      this.cardType = "";
      this.last4Digits = "";
    }
  }
  /**
   * Handles input field changes for payment information.
   * Based on the input field name, it updates the corresponding payment property.
   *
   * @param {Event} event - The event triggered by the input field change.
   * @returns {void} Updates the relevant payment property.
   */
  handleInputChangePayment(event) {
    const inputField = event.target.name;
    const value = event.detail.value;

    switch (inputField) {
      case "cardType":
        this.cardType = value;
        event.target.setCustomValidity("");
        event.target.reportValidity();
        break;
      case "last4Digits":
        this.last4Digits = value;
        event.target.setCustomValidity("");
        event.target.reportValidity();
        break;
      case "checkNumber":
        this.checkNumber = value;
        event.target.setCustomValidity("");
        event.target.reportValidity();
        break;
      case "moneyOrderNo":
        this.moneyOrderNo = value;
        event.target.setCustomValidity("");
        event.target.reportValidity();
        break;
      case "paymentAmount":
        this.paymentAmount = this.addDollarPrefix(value);
        console.log("value length is : " + value.length);

        if (value.length === 1 && value.charAt(0) === "$") {
          event.target.setCustomValidity("Please enter payment amount");
          event.target.reportValidity();
        } else {
          event.target.setCustomValidity("");
          event.target.reportValidity();
        }

        break;
      default:
        console.warn("Unhandled field:", inputField);
    }
  }

  handleKeyPress(event) {
    const charCode = event.which ? event.which : event.keyCode;
    // Allow only digits (0-9)
    if (charCode < 48 || charCode > 57) {
      event.preventDefault();
    }
  }

  handleKeyPressAmount(event) {
    const charCode = event.which ? event.which : event.keyCode;

    const charStr = String.fromCharCode(charCode);

    // Allow digits (0-9), dot (.) and dollar sign ($)
    if (!/[0-9.]/.test(charStr)) {
      event.preventDefault();
    }
  }

  /**
   * Adds a dollar sign prefix to the payment amount if not already present.
   *
   * @param {string} value - The payment amount value to be formatted.
   * @returns {string} The formatted payment amount with a dollar sign prefix.
   */
  addDollarPrefix(value) {
    if (
      value === undefined ||
      value === null ||
      (value.length === 1 && value.charAt(0) === "$")
    ) {
      return "";
    }

    value = String(value).trim();

    if (value.charAt(0) !== "$") {
      value = `$${value}`;
    }

    return value;
  }
  /**
   * Validates payment input fields to ensure required fields are filled based on the selected payment type.
   *
   * @returns {boolean} Returns true if all required fields are filled, otherwise false and shows a toast with missing fields.
   */
  // validatePaymentInputs() {
  //   let allValid = true;
  //   let missingFields = [];
  //   this.paymentError = {
  //     showErrorPaymentType: false,
  //     showErrorCardType: false,
  //     showErrorCardDigits: false,
  //     showErrorCheckNo: false,
  //     showErrorMoneyNo: false,
  //     showErrorPaymentAmount: false
  //   };

  //   const requiredFields = {
  //     paymentType: "Payment Type",
  //     paymentAmount: "Payment Amount"
  //   };

  //   if (this.paymentType === "Card") {
  //     requiredFields.cardType = "Card Type";
  //     requiredFields.last4Digits = "Last 4 Digits";
  //   } else if (this.paymentType === "Check") {
  //     requiredFields.checkNumber = "Check Number";
  //   } else if (this.paymentType === "Money Order") {
  //     requiredFields.moneyOrderNo = "Money Order Number";
  //   }

  //   Object.keys(requiredFields).forEach((field) => {
  //     if (!this[field] || this[field].toString().trim() === "") {
  //       allValid = false;
  //       missingFields.push(requiredFields[field]);

  //       // Set corresponding error flags dynamically
  //       switch (field) {
  //         case "paymentType":
  //           this.paymentError.showErrorPaymentType = true;
  //           break;
  //         case "cardType":
  //           this.paymentError.showErrorCardType = true;
  //           break;
  //         case "last4Digits":
  //           this.paymentError.showErrorCardDigits = true;
  //           break;
  //         case "checkNumber":
  //           this.paymentError.showErrorCheckNo = true;
  //           break;
  //         case "moneyOrderNo":
  //           this.paymentError.showErrorMoneyNo = true;
  //           break;
  //         case "paymentAmount":
  //           this.paymentError.showErrorPaymentAmount = true;
  //           break;
  //       }
  //     }
  //   });

  //   if (this.paymentType === "Card" && this.last4Digits && this.last4Digits.length < 4) {
  //     this.paymentError.showErrorCardDigits = true;
  //     allValid = false;
  //     if (!missingFields.includes("Last 4 Digits")) {
  //       missingFields.push("Last 4 Digits");
  //     }
  //   }

  //   if (!allValid) {
  //     const message = `Please fill in the required fields: ${missingFields.join(", ")}`;
  //     this.showToast("Warning", message, "warning");
  //     return false;
  //   }

  //   return true;
  // }

  validatePaymentInputs() {
    let allValid = true;
    console.log("Starting validation...");

    // Payment Type

    console.log("payment type values is : checking");

    const paymentTypeField = this.template.querySelector(
      '[data-id="paymentType"]'
    );
    console.log("Found PaymentType Field:", paymentTypeField);

    if (paymentTypeField) {
      if (!this.paymentType) {
        console.log("paymentType is empty/null");
        paymentTypeField.setCustomValidity("Please select payment type");
        allValid = false;
      } else {
        paymentTypeField.setCustomValidity(""); // Clear previous error
      }
      paymentTypeField.reportValidity();
    } else {
      console.error("Payment Type field not found!");
    }

    // Card Type if needed
    if (this.isCreditCard) {
      const cardTypeField = this.template.querySelector('[data-id="cardType"]');
      if (!this.cardType) {
        cardTypeField.setCustomValidity("Please select card type");
        allValid = false;
      } else {
        cardTypeField.setCustomValidity("");
      }
      cardTypeField.reportValidity();

      const last4DigitsField = this.template.querySelector(
        '[data-id="last4Digits"]'
      );
      if (!this.last4Digits || this.last4Digits.length < 4) {
        last4DigitsField.setCustomValidity("Please enter exactly 4 digits");
        allValid = false;
      } else {
        last4DigitsField.setCustomValidity("");
      }
      last4DigitsField.reportValidity();
    }

    // Check Number if needed
    if (this.isCheck) {
      const checkNumberField = this.template.querySelector(
        '[data-id="checkNumber"]'
      );
      if (!this.checkNumber) {
        checkNumberField.setCustomValidity("Please enter check number");
        allValid = false;
      } else {
        checkNumberField.setCustomValidity("");
      }
      checkNumberField.reportValidity();
    }

    // Money Order Number if needed
    if (this.isMoneyOrder) {
      const moneyOrderNoField = this.template.querySelector(
        '[data-id="moneyOrderNo"]'
      );
      if (!this.moneyOrderNo) {
        moneyOrderNoField.setCustomValidity("Please enter money order number");
        allValid = false;
      } else {
        moneyOrderNoField.setCustomValidity("");
      }
      moneyOrderNoField.reportValidity();
    }

    // Payment Amount
    const paymentAmountField = this.template.querySelector(
      '[data-id="paymentAmount"]'
    );
    if (!this.paymentAmount) {
      console.log("payment Amount values is : " + paymentAmountField);
      paymentAmountField.setCustomValidity("Please enter payment amount");
      allValid = false;
    } else {
      paymentAmountField.setCustomValidity("");
    }
    paymentAmountField.reportValidity();

    return allValid;
  }
  /**
   * Handles adding a payment. First validates input fields, calculates the new total,
   * and ensures the payment amount is within valid limits.
   *
   * @returns {void} Adds the payment to the payment list, updates the total amount, and creates a record.
   */
  handleAddPayment() {
    if (!this.validatePaymentInputs()) {
      return;
    }
    const newPaymentAmount = this.paymentAmount
      ? parseFloat(this.paymentAmount.replace(/\$/g, ""))
      : 0;
    const totalPaidSoFar = this.totalAmountPayment
      ? parseFloat(this.totalAmountPayment.replace(/\$/g, ""))
      : 0;
    const totalFee = this.totalAmount
      ? parseFloat(this.totalAmount.replace(/\$/g, ""))
      : 0;

    const newTotalAmount = totalPaidSoFar + newPaymentAmount;

    if (newPaymentAmount <= 0) {
      this.isLoading = false;
      this.showToast(
        "Validation",
        "Total payment amount cannot be Zero or Negative value",
        "warning"
      );
      return;
    }

    if (newTotalAmount == totalFee) {
      this.workOrderStatus = "Payment Captured";
    } else {
      this.workOrderStatus = "Payment Pending";
    }

    if (newTotalAmount > totalFee) {
      this.isLoading = false;
      this.showToast(
        "Validation",
        "Total payment amount cannot exceed the filing fee",
        "warning"
      );
      return;
    }

    const newPayment = {
      id: this.rows.length + 1,
      type: this.paymentType,
      isCreditCard: this.paymentType === "Card",
      isCheque: this.paymentType === "Check",
      cardType: this.paymentType === "Card" ? this.cardType : "",
      last4Digits: this.paymentType === "Card" ? this.last4Digits : null,
      checkNumber: this.paymentType === "Check" ? this.checkNumber : null,
      moneyOrder: this.paymentType === "Money Order" ? this.moneyOrderNo : null,
      paymentAmount: newPaymentAmount,
      workOrder: this.workOrder,
      authCode: this.authCode,
      recordIdIndApp: this.recordId,
      dateOfPayment: this.dateOfPayment || this.todayDate,
      isRemovable: true
    };

    this.rows = [...this.rows, newPayment];

    this.totalAmountPayment = `$${newTotalAmount.toFixed(2)}`;

    this.createRecord();

    this.clearPaymentFields();
  }
  /**
   * Creates a new payment record after adding the payment.
   *
   * @returns {void} Creates the record and updates the payment data.
   */
  async createRecord() {
    const totalSum = await createMultipleTransaction({ rows: this.rows });
    // this.showToast("Success", "Payment Added Successfully", "Success");
    this.loadExistingPayment();
    this.rows = [];
    this.paymentType = "";
    this.isCreditCard = false;
    this.isCheck = false;
    this.isMoneyOrder = false;
    this.isLoading = false;
  }

  /**
   * Clears all payment fields, resetting the state for a new payment.
   *
   * @returns {void} Resets payment type, card type, last 4 digits, check number, payment amount, and money order number.
   */
  clearPaymentFields() {
    this.paymentType = "";
    this.cardType = "";
    this.last4Digits = "";
    this.checkNumber = "";
    this.paymentAmount = "";
    this.moneyOrderNo = "";
  }
  /**
   * Handles the editing of an existing transaction. Loads the selected transaction data into the form for editing.
   *
   * @param {Event} event - The event triggered by selecting an existing transaction.
   * @returns {void} Populates the payment form with the selected transaction's data.
   */
  handleEditTransaction(event) {
    const transactionId = event.target.dataset.id;
    this.isAdd = false;
    this.isEdit = true;

    const selectedTransaction = this.previousTrnxnPayment.find(
      (trx) => trx.Id == transactionId
    );

    this.editTransactionID = selectedTransaction.Id;

    if (!selectedTransaction) {
      this.showToast("Error", "Transaction not found", "error");
      return;
    }

    this.paymentType = selectedTransaction.SAP_Payment_Type__c || "";
    this.isCreditCard = this.paymentType === "Card";
    this.isCheck = this.paymentType === "Check";
    this.isMoneyOrder = this.paymentType === "Money Order";

    if (this.isCreditCard) {
      this.cardType = selectedTransaction.cardType || "";
      this.last4Digits = selectedTransaction.SAP_Card_Number__c
        ? selectedTransaction.SAP_Card_Number__c
        : "";
      this.checkNumber = "";
      this.moneyOrderNo = "";
    } else if (this.isCheck) {
      this.checkNumber = selectedTransaction.SAP_CK_Number__c
        ? selectedTransaction.SAP_CK_Number__c
        : "";
      this.cardType = "";
      this.last4Digits = "";
      this.moneyOrderNo = "";
    } else if (this.isMoneyOrder) {
      this.checkNumber = "";
      this.cardType = "";
      this.last4Digits = "";
      this.moneyOrderNo = selectedTransaction.SAP_Money_Order_Number__c
        ? selectedTransaction.SAP_Money_Order_Number__c
        : "";
    }

    this.paymentAmount = selectedTransaction.TotalFeeAmount;
  }
  /**
   * Handles the saving (editing) of an updated payment transaction. Validates the inputs and updates the payment record.
   *
   * @returns {void} Validates input, calculates the total amount, and updates the transaction record.
   */
  handleEditPayment() {
    if (!this.validatePaymentInputs()) {
      return;
    }

    const totalPaidSoFar = this.previousTrnxnPayment.reduce((total, trx) => {
      const amount = trx.paymentAmount
        ? parseFloat(trx.paymentAmount.toString().replace(/\$/g, ""))
        : 0;
      return trx.Id !== this.editTransactionID ? total + amount : total;
    }, 0);

    const totalFee = this.totalAmount
      ? parseFloat(this.totalAmount.replace(/\$/g, ""))
      : 0;
    const newPaymentAmount = this.paymentAmount
      ? parseFloat(this.paymentAmount.replace(/\$/g, ""))
      : 0;
    const newTotalAmount = totalPaidSoFar + newPaymentAmount;

    if (newPaymentAmount <= 0) {
      this.isLoading = false;
      this.showToast(
        "Validation",
        "Total payment amount cannot be Zero or Negative value",
        "warning"
      );
      return;
    }

    if (newTotalAmount == totalFee) {
      this.workOrderStatus = "Payment Captured";
    } else {
      this.workOrderStatus = "Payment Pending";
    }

    if (newTotalAmount > totalFee) {
      this.showToast(
        "Validation",
        "Total payment amount cannot exceed the filing fee",
        "warning"
      );
      return;
    }

    const paymentData = {
      recordIdTnnx: this.editTransactionID || null,
      type: this.paymentType,
      isCreditCard: this.paymentType === "Card",
      isCheque: this.paymentType === "Check",
      isMoneyOrder: this.paymentType === "Money Order",
      cardType: this.paymentType === "Card" ? this.cardType : "",
      last4Digits: this.paymentType === "Card" ? this.last4Digits : null,
      checkNumber: this.paymentType === "Check" ? this.checkNumber : null,
      moneyOrder: this.paymentType === "Money Order" ? this.moneyOrderNo : null,
      paymentAmount: this.paymentAmount
        ? parseFloat(this.paymentAmount.replace(/\$/g, ""))
        : 0,
      workOrder: this.workOrder,
      authCode: this.authCode,
      recordIdIndApp: this.recordId,
      dateOfPayment: this.dateOfPayment || this.todayDate,
      isRemovable: true
    };

    this.updateRecord(paymentData);
  }

  /**
   * Updates the payment record in the system by calling the update transaction API.
   *
   * @param {Object} paymentData - The payment data to be updated.
   * @returns {void} Updates the record and resets the form fields upon success.
   */
  updateRecord(paymentData) {
    const paymentJson = JSON.stringify(paymentData);
    updateTransaction({ paymentJson }).then((result) => {
      // this.showToast(
      //   "Success",
      //   "Payment transaction saved successfully.",
      //   "success"
      // );
      this.clearPaymentFields();
      this.loadExistingPayment();
      this.setToDefault();
      this.paymentType = "";
      this.isCreditCard = false;
      this.isCheck = false;
      this.isMoneyOrder = false;
    });
  }

  setToDefault() {
    this.isAdd = true;
    this.isEdit = false;
    this.editTransactionID = "";
  }

  handleDeleteTransaction(event) {
    const transactionId = event.target.dataset.id;
    this.showConfirmationModal = true;
    this.transactionIdToDelete = transactionId;
    this.showAfterSave = true;
  }

  confirmDelete() {
    if (!this.transactionIdToDelete) {
      this.showToast("Error", "Invalid Transaction ID", "error");
      return;
    }

    deleteTransaction({ transactionId: this.transactionIdToDelete })
      .then(() => {
        this.showToast(
          "Apostille in-house",
          "Transaction deleted successfully!",
          "success"
        );
        this.transactionIdToDelete = null;
        this.showConfirmationModal = false;
        this.loadExistingPayment();
        this.paymentType = "";
        this.isCreditCard = false;
        this.isCheck = false;
        this.isMoneyOrder = false;
      })
      .catch((error) => {
        console.error("Error deleting transaction:", error);
        this.showToast(
          "Apostille in-house",
          "Failed to delete transaction",
          "error"
        );
        this.showConfirmationModal = false;
      });
    if (this.totalAmountPayment == this.totalAmount) {
      this.workOrderStatus = "Payment Captured";
    } else {
      this.workOrderStatus = "Payment Pending";
    }
  }

  cancelDelete() {
    this.transactionIdToDelete = null;
    this.showConfirmationModal = false;
  }

  @track paymentDetailsModal = [];
  @track itemDetails = [];
  @track appliedDate;
  @track workOrderNumberModal;
  @track addressLine;
  @track cityModal;
  @track stateModal;
  @track zipCodeModal;
  @track individualName;

  /**
   * Loads payment details for a given record ID, including total fee amount, partial refunds, and payment methods.
   *
   * @param {string} recordId - The record ID for which payment details need to be loaded.
   * @returns {void} Sets payment details in the `paymentDetailsModal` for display.
   */
  async loadPaymentDetails(recordId) {
    try {
      const data = await getPaymentDetails({ itemId: recordId });

      let totalPaymentAmount = 0;
      let totalPartialRefund = 0;

      const newTransactionTypes = new Set();
      const refundTransactionTypes = new Set();

      data.forEach((payment) => {
        const amount = payment.TotalFeeAmount
          ? parseFloat(payment.TotalFeeAmount)
          : 0;
        const recordType = payment.RecordType?.Name;
        const paymentType = payment.SAP_Payment_Type__c?.trim();

        if (recordType === "New Transaction") {
          totalPaymentAmount += amount;
          if (paymentType) {
            newTransactionTypes.add(paymentType);
          }
        } else if (recordType === "Refund Transaction") {
          totalPartialRefund += amount;
          if (paymentType) {
            refundTransactionTypes.add(paymentType);
          }
        }
      });

      // Convert Sets to strings
      const newPaymentTypes =
        Array.from(newTransactionTypes).join(", ") || "---";
      const refundPaymentTypes =
        Array.from(refundTransactionTypes).join(", ") || "---";

      this.paymentDetailsModal = [
        {
          TotalFeeAmount: totalPaymentAmount.toFixed(2),
          Partial_Refund__c: totalPartialRefund.toFixed(2),
          New_Transaction_Types: newPaymentTypes,
          Refund_Transaction_Types: refundPaymentTypes
        }
      ];
    } catch (error) {
      console.error("Error fetching payment details:", error);
      this.paymentDetailsModal = [
        {
          TotalFeeAmount: "0.00",
          Partial_Refund__c: "0.00",
          New_Transaction_Types: "---",
          Refund_Transaction_Types: "---"
        }
      ];
    }
  }

  /**
   * Loads item details for a given record ID, including document details and individual application data.
   *
   * @param {string} recordId - The record ID for which item details need to be loaded.
   * @returns {void} Sets item details and other relevant application data in the modal.
   */
  async loadItemDetails(recordId) {
    getDocumentChecklistItemDetails({ itemId: recordId })
      .then((data) => {
        this.itemDetails = data.document.map((doc) => {
          let numberedReasons = [];

          if (doc.RejectionReason) {
            const reasons = doc.RejectionReason.split(";")
              .map((r) => r.trim())
              .filter((r) => r);
            reasons.forEach((reason, index) => {
              numberedReasons.push(`${index + 1}. ${reason}`);
            });
          }

          if (
            doc.customRejectionReason &&
            doc.customRejectionReason.trim() !== ""
          ) {
            numberedReasons.push(
              `${numberedReasons.length + 1}. ${doc.customRejectionReason}`
            );
          }
          console.log(numberedReasons);

          return {
            ...doc,
            nameDisplay: doc.name || "---",
            countryDisplay: doc.country || "---",
            hagueStatusDisplay: doc.hagueStatus || "---",
            statusDisplay: doc.status || "---",
            rejectionReasonDisplay:
              numberedReasons.length > 0 ? numberedReasons.join("\n") : "---",
            notesDisplay: doc.Notes || "---"
          };
        });

        this.appliedDate = data.individualAppData.AppliedDate;
        this.workOrderNumberModal = data.individualAppData.SequenceNumber;
        this.addressLine = data.individualAppData.AddressLine;
        this.cityModal = data.individualAppData.City;
        this.stateModal = data.individualAppData.State;
        this.zipCodeModal = data.individualAppData.ZipCode;
        this.individualName = data.individualAppData.name;

        return this.itemDetails; // Return the result
      })
      .catch((error) => {
        this.error = error;
        this.itemDetails = undefined;
      });
  }

  /**
   * Generates the payment receipt PDF by preparing the necessary data and invoking the child component.
   *
   * @returns {void} Prepares the data for printing the payment receipt and invokes the PDF generation in the child component.
   */
  async handlePrintPaymentReceiptModel() {
    this.records = this.previousTrnxnPayment.map((row) => ({
      totalAmountPaid: row.TotalFeeAmount
        ? row.TotalFeeAmount
        : row.TotalFeeAmount,
      paymentMethod: row.Payment_Type__c,
      authCode: row.Auth_Code__c || "N/A",
      dateOfPayment: this.formatDate(row.CreatedDate)
    }));

    this.records = this.records.map((record) => ({
      ...record,
      workOrder: this.workOrderNumber,
      authCode: this.authCode || "N/A"
    }));

    const childComponent = this.template.querySelector(
      '[data-id="pdfGeneratorPaymentReceipt"]'
    );

    if (this.records) {
      childComponent.generateDataForApostillePrintPaymentReceipt(this.records);
    }
  }
  /**
   * Generates the order details PDF by fetching the relevant data and invoking the child component.
   *
   * @returns {void} Fetches payment and item details, then generates the order details PDF in the child component.
   */
  async handlePrintOrderDetails() {
    try {
      this.footerOprions = true;
      await new Promise((resolve) => setTimeout(resolve, 1000));
      await Promise.all([
        this.loadPaymentDetails(this.recordId),
        this.loadItemDetails(this.recordId)
      ]);
      await new Promise((resolve) => setTimeout(resolve, 1000));
      console.log(JSON.stringify(this.paymentDetailsModal, null, 2));
      const childComponent1 = this.template.querySelector(
        '[data-id="pdfGeneratorOrderDeails"]'
      );
      if (childComponent1) {
        const certificateNo = this.certificateNo;
        childComponent1.LetterCertificatePdfGenerator(certificateNo);
      }
    } catch (error) {
      console.error("Error opening letter modal:", error);
    } finally {
      this.footerOprions = false;
    }
  }

  /**
   * Removes a payment from the payment list based on the clicked button index.
   *
   * @param {Event} event - The event triggered by the "Remove" button.
   * @returns {void} Removes the payment from the list.
   */
  handleRemovePayment(event) {
    const index = event.target.dataset.index;
    this.paymentList.splice(index, 1);
  }

  updateRemoveButtonVisibility() {
    this.paymentList.forEach((payment, index) => {
      payment.showRemoveButton = index > 0;
    });
  }

  /**
   * Handles changes in the payment type for a specific payment in the list.
   *
   * @param {Event} event - The event triggered by the change in payment type.
   * @returns {void} Updates the payment type and corresponding fields.
   */
  handlePaymentTypeChange(event) {
    const index = event.target.dataset.index;
    const name = event.target.name;
    const value = event.target.value;
    if (name == "paymentType") {
      if (value == "Check") {
        this.paymentList[index].isCardPayment = false;
        this.paymentList[index].last4Digits = null;
      } else {
        this.paymentList[index].isCardPayment = true;
        this.paymentList[index].ckNumber = null;
      }
    }
    this.paymentList[index].paymentType = event.target.value;
  }

  handleCardTypeChange(event) {
    const index = event.target.dataset.index;
    this.paymentList[index].cardType = event.target.value;
  }

  handleLast4DigitsChange(event) {
    const index = event.target.dataset.index;
    this.paymentList[index].last4Digits = event.target.value;
  }

  handleckNumberChange(event) {
    const index = event.target.dataset.index;
    this.paymentList[index].ckNumber = event.target.value;
  }
  /**
   * Handles changes in the payment amount for a specific payment.
   *
   * @param {Event} event - The event triggered by the payment amount change.
   * @returns {void} Updates the payment amount and checks if the total exceeds the allowed amount.
   */
  handlePaymentAmountChange(event) {
    const index = event.target.dataset.index;
    const newAmount = parseFloat(event.target.value) || 0;
    this.paymentList[index].paymentAmount = newAmount;

    const totalPayments = this.paymentList.reduce((sum, payment) => {
      return sum + (parseFloat(payment.paymentAmount) || 0);
    }, 0);

    if (totalPayments > this.totalAmount) {
      this.showPaymentError = true;
      this.paymentList.forEach((payment) => {
        payment.errorMessage = "Total payment cannot exceed the allowed amount";
      });
      console.error("Error: Total payment exceeds the allowed amount");
    } else {
      this.showPaymentError = false;
      this.paymentList.forEach((payment) => {
        payment.errorMessage = "";
      });
    }
  }

  @track e_apostille_upload = false;
  @track showUploadLink = false;
  @track showEapostilleUploadLink = false;
  @track pre_paid_shipping_label = false;
  @track e_Apostille_customer_upload = false;
  @track showfirstOption = false;
  @track showThirdOption = false;
  @track isModalOpen = false;
  // @track isModalOpen2 = false;
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
  @track fedEx;
  @track pre_paid_shipping_labelisReadOnly = false;
  @track fourthOptionisReadOnly = false;
  @track secondOptionisReadOnly = false;
  @track e_Apostille_customer_uploadisReadOnly = false;
  @track thirdOptionisReadOnly = false;
  @track showSelectedSubOptions = false;
  @track documentPickedUp = false;
  @track notReadOnly = true;
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

  shippingOptions = [
    { label: "UPS", value: "UPS" },
    { label: "FedEx", value: "FedEx" },
    { label: "DHL", value: "DHL" },
    { label: "SOS MAIL", value: "SOS Mail" },
    { label: "SOS MAIL (OUT OF COUNTRY)", value: "SOS Mail (Out Of Country)" }
  ];

  handleShippingMethodChange(event) {
    this.shippingMethod = event.target.value;
    this.dynamicLabel = `${this.shippingMethod} #`;
    this.fedEx = "";
  }

  handleFedExChange(event) {
    this.fedEx = event.target.value;
  }

  @wire(getRelatedFilesByRecordId, { recordId: "$recordId" })
  wiredFiles({ error, data }) {
    if (data) {
      this.uploadedFiles = Object.keys(data).map((id) => ({
        filename: data[id],
        value: id,
        versionId: id,
        documentId: id,
        url: `/sfc/servlet.shepherd/document/download/${id}`
      }));
    } else if (error) {
      console.error("Error fetching files: ", error);
    }
  }

  handlePreview(event) {
    // Get the file ID from the element that was clicked
    const fileId = event.currentTarget.dataset.id;

    // Log for debugging
    console.log("Preview file ID:", fileId);

    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        selectedRecordId: fileId
      }
    });
  }

  // get firstOption1() {
  //   return this.isOption1Checked ? 'slds-form-element__label bold-text' : 'slds-form-element__label';
  // }

  // get secondOption2() {
  //   return this.isOption2Checked ? 'slds-form-element__label bold-text' : 'slds-form-element__label';
  // }

  // get thirdOption3() {
  //   return this.isOption3Checked ? 'slds-form-element__label bold-text' : 'slds-form-element__label';
  // }

  // get fourthOption4() {
  //   return this.isOption4Checked ? 'slds-form-element__label bold-text' : 'slds-form-element__label';
  // }

  get acceptedFormats() {
    return [".pdf", ".png"];
  }

  get showFileUpload() {
    return this.returnOptions.find((option) => option.value === "upload")
      .checked;
  }

  //   handleUploadFinished(event) {
  //     const uploadedFiles = event.detail.files;
  //     this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];
  // }

  closeModal() {
    this.close("close");
  }

  openUploadModal() {
    this.isModalOpen = true;
    // this.isModalOpen2 = false;
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

  // openUploadModal2() {
  //   this.isModalOpen2 = true;
  //   this.isModalOpen = false;
  // }

  // closeUploadModal2() {
  //   this.isModalOpen2 = false;
  //   this.newUploadedFilesEApostille.forEach((file) => {
  //     this.uploadedFileApostille = this.uploadedFileApostille.filter(
  //       (f) => f.documentId !== file.documentId
  //     );
  //     deleteFile({ fileId: file.documentId }).catch((error) =>
  //       console.error("Error deleting file:", error)
  //     );
  //   });
  //   this.uploadedFileApostille = this.uploadedFileApostille.filter(
  //     (file) => !this.newUploadedFilesEApostille.includes(file)
  //   );

  //   if (this.upload2Clicked) this.e_Apostille_customer_upload = true;
  // }

  handleUploadLinkClick(event) {
    event.preventDefault();
    this.pre_paid_shipping_label = false;
    this.sotsUpload = false;
    this.openUploadModal();
  }

  // handleUploadLinkClick2(event) {
  //   event.preventDefault();
  //   this.e_Apostille_customer_upload = false;
  //   this.openUploadModal2();
  // }

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
      this.pre_paid_shipping_label = false;
      this.e_Apostille_customer_upload = false;
      this.documentPickedUp = true;
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

  get hasDocumentSelected() {
    return this.documentPickedUp;
  }
  /**
   * Handles the file upload process by reading the selected files, converting them to base64 format,
   * and uploading them to the server. Updates the list of uploaded files and content version IDs.
   *
   * @param {Event} event - The event triggered by the file upload component.
   * @returns {void} Reads the files, converts them to base64, and uploads them.
   */

  @track prePaidFileLoader = false;
  handleUploadFinished(event) {
    this.prePaidFileLoader = true;
    const files = Array.from(event.target.files);
    const filePromises = files.map((file) => {
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
        const uploadedFiles = result.map((docId, index) => ({
          filename: files[index].name,
          documentId: docId
        }));

        // Merge new files with existing files
        this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];

        this.prePaidFileLoader = false;
      })
      .catch((error) => {
        this.prePaidFileLoader = false;
        console.error("Error during file upload:", error);
      });
  }

  /**
   * Handles the file upload for a specific e-apostille process by converting files to base64
   * and uploading them to the server, and updates the lists of uploaded files.
   *
   * @param {Event} event - The event triggered by the file upload component.
   * @returns {void} Processes the uploaded files and updates relevant lists.
   */
  // handleUploadFinished2(event) {
  //   const files = event.target.files;

  //   const filePromises = Array.from(files).map((file) => {
  //     return new Promise((resolve, reject) => {
  //       const reader = new FileReader();

  //       reader.onload = () => {
  //         const base64 = reader.result.split(",")[1];
  //         const fileData = {
  //           filename: file.name,
  //           base64: base64,
  //           RecordId: this.recordId
  //         };

  //         if (fileData && fileData.base64 && fileData.filename) {
  //           resolve(fileData);
  //         } else {
  //           reject("File data is not ready");
  //         }
  //       };

  //       reader.onerror = () => {
  //         reject("Error reading file");
  //       };

  //       reader.readAsDataURL(file);
  //     });
  //   });

  //   Promise.all(filePromises)
  //     .then((fileInfos) => {
  //       return uploadFiles({ fileInfos });
  //     })
  //     .then((result) => {
  //       const uploadedFiles = result.map((docId, index) => ({
  //         filename: files[index].name,
  //         documentId: docId
  //       }));

  //       this.newUploadedFilesEApostille = [
  //         ...this.newUploadedFilesEApostille,
  //         ...uploadedFiles
  //       ];
  //       this.uploadedFileApostille = [
  //         ...this.uploadedFileApostille,
  //         ...uploadedFiles
  //       ];
  //       this.contentVersionIds = [...this.contentVersionIds, ...result];
  //     })
  //     .catch((error) => {
  //       console.error("Error during file upload:", error);
  //     });
  // }

  /**
   * Deletes a file from the uploaded files list by its document ID and updates the lists accordingly.
   *
   * @param {Event} event - The event triggered by the delete button for the file.
   * @returns {void} Deletes the file from the server and updates the list of uploaded files.
   */
  handleDeleteFile(event) {
    const index = event.target.dataset.index;
    const fileToDelete = this.uploadedFiles[index];

    // Use documentId if available, fall back to value (which should be the same)
    const fileId = fileToDelete.documentId || fileToDelete.value;

    deleteFile({ fileId: fileId })
      .then(() => {
        this.uploadedFiles.splice(index, 1);
        this.uploadedFiles = [...this.uploadedFiles];

        this.titleuploadedFiles = [];
        this.titleuploadedFiles = this.uploadedFiles.map(
          (file) => file.filename
        );
        this.uploadedFilesID = [];
        this.uploadedFilesID = this.uploadedFiles.map(
          (file) => file.documentId || file.value
        );
      })
      .catch((error) => {
        console.error("Error deleting file:", error);
      });
  }

  // handleDeleteFile2(event) {
  //   const index = event.target.dataset.index;
  //   const fileToDelete = this.uploadedFileApostille[index];

  //   deleteFile({ fileId: fileToDelete.documentId })
  //     .then(() => {
  //       this.uploadedFileApostille.splice(index, 1);
  //       this.uploadedFileApostille = [...this.uploadedFileApostille];

  //       this.titleuploadedFileApostille = [];
  //       this.titleuploadedFileApostille = this.uploadedFileApostille.map(
  //         (file) => file.filename
  //       );

  //       this.uploadedFileApostilleID = [];
  //       this.uploadedFileApostilleID = this.uploadedFileApostille.map(
  //         (file) => file.documentId
  //       );
  //     })
  //     .catch((error) => {
  //       console.error("Error deleting file:", error);
  //     });
  // }
  /**
   * Initializes the upload process by resetting relevant variables and setting the modal states.
   *
   * @returns {void} Resets uploaded files, clears IDs, and opens the modal for the file upload.
   */
  handleUpload() {
    this.titleuploadedFiles = [];
    this.newUploadedFiles = [];
    this.uploadClicked = true;
    this.pre_paid_shipping_label = true;
    this.isModalOpen = false;

    this.uploadedFilesID = [];
    this.uploadedFilesID = this.uploadedFiles.map((file) => file.documentId);

    this.titleuploadedFiles = this.uploadedFiles.map((file) => file.filename);
    console.log("title uploaded: ", JSON.stringify(this.titleuploadedFiles));
    console.log("uploadedFilesID: ", JSON.stringify(this.uploadedFilesID));
  }

  // handleUpload2() {
  //   this.titleuploadedFileApostille = [];
  //   this.newUploadedFilesEApostille = [];
  //   this.e_Apostille_customer_upload = true;
  //   this.upload2Clicked = true;
  //   this.isModalOpen2 = false;
  //   this.uploadedFileApostilleID = [];
  //   this.uploadedFileApostilleID = this.uploadedFileApostille.map(
  //     (file) => file.documentId
  //   );
  //   this.titleuploadedFileApostille = this.uploadedFileApostille.map(
  //     (file) => file.filename
  //   );
  // }

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
        .then(() => {})
        .catch((error) => console.error("Error deleting file:", error));
    });
    this.uploadedFiles = [];
  }

  changeTodeleteeApostille() {
    this.uploadedFileApostille.forEach((file) => {
      deleteFile({ fileId: file.documentId })
        .then(() => {})
        .catch((error) => console.error("Error deleting file:", error));
    });
    this.uploadedFileApostille = [];
  }

  @track addressLine1;
  @track suite;
  @track city;
  @track state;
  @track zipCode;
  @track country;
  @track validationError = "";
  @track sameAsContactAddressString = "No";

  handleAddressChange(event) {
    this.addressLine1 = event.detail.street
      ? event.detail.street.toUpperCase()
      : "";
    this.city = event.detail.city ? event.detail.city.toUpperCase() : "";
    this.suite = event.detail.subpremise
      ? event.detail.subpremise.toUpperCase()
      : "";
    this.state = event.detail.province
      ? event.detail.province.toUpperCase()
      : "";
    this.country = event.detail.country
      ? event.detail.country.toUpperCase()
      : "";

    const zipCode = event.detail.postalCode;
    const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

    if (!zipCodePattern.test(zipCode)) {
      this.validationError = "Zip Code can only contain digits and hyphen.";
      this.zipCode = "";
    } else {
      this.validationError = "";
      this.zipCode = zipCode;
    }
  }

  @track additionalServiceRequest;

  handleAdditionalServiceChange(event) {
    const value = event.target.value;

    this.additionalServiceRequest = value;
  }

  @track memo;
  @track notes;

  handleMemoChange(event) {
    const value = event.target.value;
    this.memo = value;
  }

  handleNotesChange(event) {
    const value = event.target.value;
    this.notes = value;
  }

  @track modifiedBy;
  @track ModifiedDate;
  @track footerOprions = false;
  @track generateCertificate = false;
  /**
   * Handles the process of adding or updating a request. It validates input fields, checks document uploads,
   * and ensures no errors are present before submitting the data. The method constructs the data object,
   * validates the documents, and updates the request accordingly.
   *
   * @returns {void} Validates inputs, uploads documents, and sends the data to be updated.
   */

  async handleAdd() {
    const isValid = this.validateInputs();
    const rejectionValid = this.validateDocAndRejectionReason();

    if (
      !isValid ||
      !rejectionValid ||
      (this.validationError && this.validationError.trim() !== "")
    ) {
      if (isValid && this.showDocError) {
        this.showToast(
          "Apostille in-house",
          "Please upload missing document.",
          "error"
        );
      } else if (isValid && this.showError) {
        this.showToast(
          "Apostille in-house",
          "Please select rejection reason for document.",
          "error"
        );
      } else if (isValid && this.showPaymentError) {
        this.showToast(
          "Apostille in-house",
          "Payment Amount cannot exceeds Total Amount.",
          "error"
        );
      } else if (isValid && this.showExpediteAdoptionError) {
        this.showToast(
          "Apostille in-house",
          "Adoption documents cannot be expedited. Please file a separate request.",
          "error"
        );
      }
      return;
    }
    const cleanedTotalAmount = parseFloat(
      this.totalAmountPayment.replace("$", "") || 0
    );
    console.log("total payment amount", this.totalAmountPayment);
    console.log("Filing Fee", this.totalAmount);

    if (cleanedTotalAmount > this.totalAmount) {
      this.showToast(
        "Apostille in-house",
        "Payment Amount cannot be more than Filing Fee.",
        "error"
      );
      return;
    } else if (cleanedTotalAmount < this.totalAmount) {
      this.showToast(
        "Apostille in-house",
        "Payment Amount cannot be less than Filing Fee.",
        "error"
      );
      return;
    }
    const invalidApprovedDocs = this.documents.filter(
      (doc) =>
        doc.status === "Approved" &&
        (!doc.signedByPosition ||
          !doc.autority ||
          !doc.signedByName ||
          !doc.signedStamp)
    );

    console.log("Invalid Docs:", JSON.stringify(invalidApprovedDocs, null, 2));

    if (invalidApprovedDocs.length > 0) {
      const errorMessages = invalidApprovedDocs.map((doc) => {
        let missingFields = [];
        if (!doc.signedByPosition) missingFields.push("Position");
        if (!doc.autority) missingFields.push("Signing Authority");
        if (!doc.signedByName) missingFields.push("Signing Official");
        if (!doc.signedStamp) missingFields.push("Seal Stamp");

        return `Document "${doc.typeOfDocument || "Unknown"}": missing ${missingFields.join(", ")}`;
      });

      this.showToast(
        "Validation Error",
        `Please complete the missing fields:\n${errorMessages.join("\n")}`,
        "warning"
      );
      this.footerOprions = false;
      return;
    }

    const allDocsReceivedStatus = this.documents.every(
      (doc) => doc.status === "Document Received"
    );

    console.log("All Documents Received:", allDocsReceivedStatus);

    if (allDocsReceivedStatus) {
      this.workOrderStatus = "Documents Received";
    }

    const data = {
      SAP_Sequence_Number__c: this.workOrderNumber,
      SAP_Prepaid_Shipping_Label_Uploaded__c: this.pre_paid_shipping_label,
      SAP_Last_Name__c: this.lastName,
      SAP_First_Name__c: this.firstName,
      SAP_Organization_Name__c: this.organizationName,
      SAP_Email_Address__c: this.emailAddress,
      SAP_Cell_Phone_Number__c: this.phoneNumber,
      Status: this.workOrderStatus,
      SAP_Agency_Business_Name__c: this.businessName,
      SAP_Agency_First_Name__c: this.firstNameindividual,
      SAP_Agency_Last_Name__c: this.lastNameindividual,
      SAP_Agency_Email_Address__c: this.emailAddressindividual,
      SAP_Agency_Cell_Phone__c: this.cellPhoneNumber,
      SAP_Email_Address_For_Receiving_Apostille__c:
        this.emailReceivingApostille,
      SAP_Address_Line_1_Shipping__c: this.addressLine1 || "",
      SAP_Suite_Apartment_Floor_Shipping__c: this.suite,
      SAP_City_Shipping__c: this.city,
      SAP_State_Shipping__c: this.state,
      SAP_Country_Shipping__c: this.country,
      SAP_Zip_Code_Shipping__c: this.zipCode,
      SAP_documentDestinationCountry__c: this.selectedCountry,
      SAP_HagueStatus__c: this.selectedHagueStatus,
      SAP_Destination_Country__c: this.destinationCountrySameString,
      SAP_documentDestinationCountryBoolean__c: this.destinationCountrySame,
      SAP_Expedite_Request_Boolean__c: this.expediteRequest,
      SAP_Expedite_Request__c: this.expediteRequestString,
      SAP_Expedited__c: this.expedite,
      SAP_Return_Mail_Type__c: this.shippingMethod,
      SAP_FedEX__c: this.fedEx,
      SAP_Document_Pickup_Notification__c: this.documentPickedUp,
      SAP_return_Mail_e_Apostille_Customer__c: this.e_Apostille_customer_upload,
      SAP_Instructions__c: this.additionalServiceRequest,
      SAP_Notes_on_Receipt__c: this.notes,
      SAP_Receipt_Memo__c: this.memo,
      Id: this.recordId
    };

    this.footerOprions = true;

    const allData = {
      individualApplication: JSON.stringify(data),
      uploadedFiles: this.uploadedFiles,
      documents: this.documents ? JSON.stringify(this.documents) : [],
      recordId: this.recordId,
      destinationCountry: this.destinationCountrySameString
    };

    if (allData.documents === "[]") {
      this.showToast(
        "Apostille in-house",
        "Add at least one document before proceeding.",
        "error"
      );
      this.footerOprions = false;
      return;
    }

    const hasEmptyType = this.documents.some((doc) => !doc.typeOfDocument);
    if (hasEmptyType) {
      this.showToast(
        "Apostille in-house",
        "Please select a document type to proceed.",
        "error"
      );
      this.footerOprions = false;
      return;
    }

    // Update data and link files
    try {
      const result = await updateAllData({
        allDataJson: JSON.stringify(allData)
      });

      if (result === "Success") {
        this.showToast(
          "Apostille in-house",
          "Request updated successfully!",
          "success"
        );

        if (
          this.oldStatus == "Payment Captured" &&
          this.workOrderStatus == "Cancelled By Staff" &&
          this.recordId
        ) {
          try {
            await inHouseRefundFee({ applicationId: this.recordId });
          } catch (error) {
            console.error("Error processing refund:", error);
            return;
          }
        }

        console.log("this document: ", JSON.stringify(this.documents));

        const refundPromises = this.documents
          .filter((doc) => doc.id != null && doc.status === "Rejected")
          .map((doc) => {
            console.log("doc id: ", doc.id);
            return inHousePartialRefundFee({ documentChecklistId: doc.id });
          });

        try {
          await Promise.all(refundPromises);
        } catch (error) {
          console.error("One or more refunds failed:", error);
        }

        const cleared = await this.clearCurrentUserUtil({
          recordId: this.recordId,
          showToast: this.showToast.bind(this)
        });
        if (cleared) {
        } else {
          // Lock couldn't be cleared, handle accordingly
          this.isReadOnly = true;
          this.mode = "view";
        }
        this.refreshData();
        this.mode = "view";

        if (this.mode === "view") {
          this.isReadOnly = true;
          if (this.paymentList) {
            this.paymentList = this.originalPaymentList.map((payment) => ({
              ...payment,
              readOnlyMode:
                this.mode === "view" ? true : payment.paymentType === "Card"
            }));
          }
        }

        await Promise.all([
          refreshApex(this.wiredIndividualData),
          refreshApex(this.wiredDocumentData)
        ]);
      }
    } catch (error) {
      console.error("Error updating records:", error);
      this.showToast(
        "Apostille in-house",
        "Unable to process the request. Please try again.",
        "error"
      );
    } finally {
      this.footerOprions = false;
    }
  }

  async cancelEditPage() {
    this.footerOprions = true;
    this.mode = "view";
    this.isReadOnly = true;

    const cleared = await this.clearCurrentUserUtil({
      recordId: this.recordId,
      showToast: this.showToast.bind(this)
    });

    if (cleared) {
    } else {
      // Lock couldn't be cleared, handle accordingly
      this.isReadOnly = true;
      this.mode = "view";
    }

    this.refreshData();
    this.paymentType = "";
    this.isCreditCard = false;
    this.isCheck = false;
    this.isMoneyOrder = false;

    this.paymentList = this.originalPaymentList.map((payment) => ({
      ...payment,
      readOnlyMode: this.mode === "view" ? true : payment.paymentType === "Card"
    }));
    this.resetAllLightningFields();

    this.footerOprions = false;
  }

  resetAllLightningFields() {
    const fieldsToReset = this.template.querySelectorAll(
      "lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group"
    );

    fieldsToReset.forEach((field) => {
      if (typeof field.setCustomValidity === "function") {
        field.setCustomValidity("");
        field.reportValidity();
      }
    });
  }

  showToast(title, message, variant) {
    const toast = this.template.querySelector(
      "c-sap_-toast-message-state-modal"
    );
    if (toast) {
      toast.showToast({
        title: title,
        message: message,
        variant: variant
      });
    }
  }

  validateInputs(showErrors = true) {
    let allValid = true;
    let missingFields = [];
    const inputComponents = this.template.querySelectorAll(
      "lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group"
    );

    inputComponents.forEach((inputCmp) => {
      const fieldName = inputCmp.name;

      if (
        fieldName === "paymentType" ||
        fieldName === "cardType" ||
        fieldName === "last4Digits" ||
        fieldName === "checkNumber" ||
        fieldName === "moneyOrderNo" ||
        fieldName === "paymentAmount"
      ) {
        return;
      }
      if (showErrors) {
        inputCmp.reportValidity();
      }

      if (!inputCmp.checkValidity()) {
        allValid = false;
        missingFields.push(inputCmp.label);
      }
    });

    const addressCmp = this.template.querySelector("lightning-input-address");
    if (addressCmp) {
      const addressFields = [
        { field: "street", label: "Address Line 1" },
        { field: "city", label: "City" },
        { field: "province", label: "State" },
        { field: "postalCode", label: "Zip Code" },
        { field: "country", label: "Country" }
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
      const message = `Please fill in the required fields: ${missingFields.join(", ")}`;
      this.showToast("Apostille in-house", message, "error");
    }

    return allValid;
  }

  @api
  get fullName() {
    return `${this.firstName} ${this.lastName}`;
  }

  /**
   * Handles the process of printing the payment receipt by opening a modal.
   * It temporarily hides the page's overflow to prevent scrolling while the modal is open.
   * Once the modal is closed (or cancelled), the overflow is restored.
   *
   * @returns {void} Opens the print payment receipt modal and manages page overflow.
   */
  async handlePrintPaymentReceipt() {
    try {
      document.body.style.overflow = "hidden";

      const result = await PrintPaymentReceiptModal2.open({
        size: "medium",
        description: "Print Payment Recipt",
        recordId: this.recordId
      });
      if (result === "cancel") {
      }
    } finally {
      document.body.style.overflow = "auto";
    }
  }

  /**
   * Handles the process of printing the submission certificate by opening a modal.
   * It temporarily hides the page's overflow to prevent scrolling while the modal is open.
   * Once the modal is closed (or cancelled), the overflow is restored.
   *
   * @param {Event} event - The event that triggers the modal opening (unused here).
   * @returns {void} Opens the apostille print submission document modal and manages page overflow.
   */

  @api price;
  @api authCode;
  @api paymentDate;
  @api paymentMethod;
  @api cardLastDigit;
  @api creditCardName;
  @api emailToSend;

  async printApostilleSubmissionDoc() {
    try {
      // Fetch application details from Apex
      const result = await getApplicationDetails({ recordId: this.recordId });

      console.log("result is : " + JSON.stringify(result));

      // If data is retrieved, update component properties
      if (result) {
        this.authCode = result.AuthenticationCode;
        this.paymentDate = result.DateofPayment;
        this.paymentMethod = result.MethodofPayment;
        this.creditCardName = result.CreditCardName;
        this.cardLastDigit = result.CardLastDigit;
        this.price = result.TotalFees;
        this.emailToSend = result.emailAddress;

        // Call the PDF generator child component
        const childComponent = this.template.querySelector(
          '[data-id="pdfGenerator"]'
        );
        this.isLoading = true;
        if (childComponent) {
          childComponent.pdfForApostilleSuccess("download");
          this.isLoading = false;
        } else {
          console.error("PDF generator component not found.");
        }
      } else {
        console.error("No data returned from getApplicationDetails.");
      }
    } catch (error) {
      console.error("Error in handleDownload:", error);
    }
  }

  @track printAllCertificate = false;

  handlePrintAllCertificate() {
    this.printAllCertificate = true;
  }

  toTitleCase(str) {
    return str.replace(
      /\w\S*/g,
      (txt) => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    );
  }

  checklistData = {};

  /**
   * Opens the certificate modal and prepares the checklist data based on the attributes passed from the event.
   * If the status is "Approved" or "Accepted", it attempts to generate a certificate using the Apostille PDF generator.
   * If the certificate number is missing, it shows an error message.
   *
   * @param {Event} event - The event that triggers the modal opening.
   * @returns {void} Opens the certificate modal or generates the apostille certificate based on conditions.
   */
  async openCertificateModal(event) {
    const recordId = event.target.dataset.id;
    const documentType = event.target.dataset.doc;
    const status = event.target.dataset.status;
    const certificateNo = event.target.dataset.certificate;
    const signedBy = event.target.dataset.signedby;
    const sealStramp = event.target.dataset.sealstramp;
    const position = event.target.dataset.position;
    const destination = event.target.dataset.destination;
    const hagueStatus = event.target.dataset.haguestatus;
    const signingAuthorityName = event.target.dataset.signingauthorityname;
    const signningAuthorityTitle = event.target.dataset.signingauthoritytitle;
    const lastModifiedDate = event.target.dataset.lastmoddate;
    const docId = event.target.dataset.docid;
    console.log("sealStramp: ", sealStramp);

    this.checklistData = {
      certificateNumber: certificateNo ? certificateNo.toUpperCase() : "",
      signedBy: signedBy ? signedBy.toUpperCase() : "",
      sealStramp: sealStramp ? sealStramp.toUpperCase() : "",
      position: position ? position.toUpperCase() : "",
      destination: this.toTitleCase(destination || ""),
      hagueStatus: hagueStatus ? hagueStatus.toUpperCase() : "",
      documentType: this.toTitleCase(documentType || ""),
      Signing_Authority_Name: signingAuthorityName
        ? this.toTitleCase(signingAuthorityName)
        : "",
      Signing_Authority_Title: signningAuthorityTitle
        ? this.toTitleCase(signningAuthorityTitle)
        : "",
      recordId: recordId,
      lastModifiedDate: lastModifiedDate,
      docId: docId
    };
    console.log("ChecklistData: ", this.checklistData.certificateNumber);

    if (status === "Approved" || status === "Accepted") {
      this.generateCertificate = true;

      if (!this.checklistData.certificateNumber) {
        this.showToast(
          "Apostille in-house",
          "Certificate number is not present.",
          "error"
        );
        return;
      }

      const pdfgenerator = this.template.querySelector(
        "c-sap_-apostille-pdf-generator"
      );
      if (pdfgenerator) {
        const result = await pdfgenerator.generateApostilleCertificate(
          this.checklistData,
          "print"
        );
        if (result === "success") this.generateCertificate = false;
      } else {
        console.error("PDF generator component not found");
      }
    } else {
      const message = `Cannot generate the certificate for ${status} status`;
      this.showToast("Info", message, "info");
    }
  }
  async openCertificateModalDownload(event) {
    const recordId = event.target.dataset.id;
    const documentType = event.target.dataset.doc;
    const status = event.target.dataset.status;
    const certificateNo = event.target.dataset.certificate;
    const signedBy = event.target.dataset.signedby;
    const sealStramp = event.target.dataset.sealstramp;
    const position = event.target.dataset.position;
    const destination = event.target.dataset.destination;
    const hagueStatus = event.target.dataset.haguestatus;
    const signingAuthorityName = event.target.dataset.signingauthorityname;
    const signningAuthorityTitle = event.target.dataset.signingauthoritytitle;
    const lastModifiedDate = event.target.dataset.lastmoddate;
    const docId = event.target.dataset.docid;
    console.log("sealStramp: ", sealStramp);

    this.checklistData = {
      certificateNumber: certificateNo ? certificateNo.toUpperCase() : "",
      signedBy: signedBy ? signedBy.toUpperCase() : "",
      sealStramp: sealStramp ? sealStramp.toUpperCase() : "",
      position: position ? position.toUpperCase() : "",
      destination: this.toTitleCase(destination || ""),
      hagueStatus: hagueStatus ? hagueStatus.toUpperCase() : "",
      documentType: this.toTitleCase(documentType || ""),
      Signing_Authority_Name: signingAuthorityName
        ? this.toTitleCase(signingAuthorityName)
        : "",
      Signing_Authority_Title: signningAuthorityTitle
        ? this.toTitleCase(signningAuthorityTitle)
        : "",
      recordId: recordId,
      lastModifiedDate: lastModifiedDate,
      docId: docId
    };
    console.log("ChecklistData: ", this.checklistData.certificateNumber);

    if (status === "Approved" || status === "Accepted") {
      this.generateCertificate = true;

      if (!this.checklistData.certificateNumber) {
        this.showToast(
          "Apostille in-house",
          "Certificate number is not present.",
          "error"
        );
        return;
      }

      const pdfgenerator = this.template.querySelector(
        "c-sap_-apostille-pdf-generator"
      );
      if (pdfgenerator) {
        const result = await pdfgenerator.generateApostilleCertificate(
          this.checklistData,
          "download"
        );
        if (result === "success") this.generateCertificate = false;
      } else {
        console.error("PDF generator component not found");
      }
    } else {
      const message = `Cannot generate the certificate for ${status} status`;
      this.showToast("Info", message, "info");
    }
  }

  closePrintAllCerti() {
    this.printAllCertificate = false;
  }

  showToast(title, message, variant) {
    const toast = this.template.querySelector(
      "c-sap_-toast-message-state-modal"
    );
    if (toast) {
      toast.showToast({
        title: title,
        message: message,
        variant: variant
      });
    }
  }

  @track isModalOpen = false;
  @track sotsUpload = false;
  @track sotRowId;
  @track showDocError = false;
  @track isReupload = false;
  @track isFileLoading = false;

  /**
   * Processes the files uploaded for each document and stores the processed file information.
   * For each document that has uploaded files, it maps the file details (filename, documentId, and download URL).
   *
   * @returns {void} Processes the uploaded files and stores them in filesList.
   */
  processFiles() {
    this.uploadedFilesForPrePaidShipping = this.uploadedFiles.map((file) => ({
      documentId: file.documentId,
      filename: file.filename
    }));
  }

  /**
   * Handles the preview of a file by navigating to the file preview page.
   * It passes the documentId in the state to preview the specific document.
   *
   * @param {Event} event - The event that triggers the preview.
   * @returns {void} Navigates to the file preview page with the documentId in the state.
   */

  previewHandler(event) {
    const documentId = event.target.dataset.documentId;

    if (documentId) {
      this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
          pageName: "filePreview"
        },
        state: {
          selectedRecordId: documentId
        }
      });
    } else {
      console.error("Document ID is missing.");
    }
  }

  get filteredDocuments() {
    const filteredDocs = this.documents.filter(
      (doc) => doc.uploadedFiles && doc.uploadedFiles.length > 0
    );
    return filteredDocs;
  }

  handleUploadForDocument(event) {
    this.sotRowId = event.target.dataset.id;
    this.isModalOpen = true;
    this.sotsUpload = true;
    this.isReupload = event.currentTarget.dataset.value === "reUpload";
  }

  closeUploadSotsModal() {
    this.isModalOpen = false;
    if (!this.isReupload) {
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

  /**
   * Handles file upload for the SOT (Statement of Truth) by converting the uploaded file to Base64 and uploading it.
   * Once uploaded, it updates the document with the uploaded file's documentId and clears any previous file if necessary.
   *
   * @param {Event} event - The event triggered after file upload finishes.
   * @returns {void} Uploads the file and updates the document with the new file's information.
   */
  handleUploadFinishedSot(event) {
    this.isFileLoading = true;
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();

      reader.onload = () => {
        const base64 = reader.result.split(",")[1];
        const fileData = {
          filename: file.name,
          base64: base64
        };

        uploadFiles({ fileInfos: [fileData] })
          .then((result) => {
            const uploadedFile = {
              filename: file.name,
              documentId: result[0]
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
          })
          .catch((error) => {
            console.error("Error during file upload:", error);
          })
          .finally(() => {
            this.isFileLoading = false;
          });
      };
      reader.readAsDataURL(file);
    }
  }

  /**
   * Deletes a file for the SOT (Statement of Truth) by identifying the file based on the document's ID and deleting it.
   *
   * @param {Event} event - The event triggered to delete the file.
   * @returns {void} Deletes the file for the specified document.
   */
  deleteFileSot(event) {
    const id = event.target.dataset.id;
    let deletionPromise = Promise.resolve();

    for (const doc of this.documents) {
      if (
        (doc.id === id || doc.id === this.sotRowId) &&
        doc.uploadedFiles.length > 0
      ) {
        const fileId = doc.uploadedFiles[0].documentId;

        deletionPromise = deleteFile({ fileId: fileId })
          .then(() => {
            doc.uploadedFiles = [];
            return doc;
          })
          .catch((error) => {
            console.error("Error deleting file:", error);
            return doc;
          });

        break;
      }
    }

    deletionPromise
      .then(() => {})
      .catch((error) => {
        console.error("Error in file deletion:", error);
      });
  }

  deleteFileById(fileId) {
    deleteFile({ fileId: fileId })
      .then(() => {})
      .catch((error) => {
        console.error(`Error deleting file with ID ${fileId}:`, error);
      });
  }

  get hasUploadedFiles() {
    return this.documents.filter(
      (doc) =>
        doc.id === this.sotRowId &&
        doc.uploadedFiles &&
        doc.uploadedFiles.length > 0
    );
  }

  @track rejectionModal = false;
  @track rejectionReasonOptions = [];
  @track selectedRejectionReasons = [];
  @track selectedReason = "";
  @track customRejectionReason = "";
  @track currentEditingDocumentId;
  @track showError = false;
  @track showPaymentError = false;
  @track showExpediteAdoptionError = false;

  openRejectionModal(event) {
    this.currentEditingDocumentId = event.target.dataset.id;
    const currentDoc = this.documents.find(
      (doc) => doc.id === this.currentEditingDocumentId
    );

    if (currentDoc) {
      this.selectedRejectionReasons = currentDoc.rejectionReason
        ? typeof currentDoc.rejectionReason === "string"
          ? currentDoc.rejectionReason.split(";").map((reason) => reason.trim())
          : currentDoc.rejectionReason
        : [];

      this.customRejectionReason = currentDoc.customRejectionReason || "";
    }

    setTimeout(() => {
      this.template.querySelectorAll("lightning-input").forEach((checkbox) => {
        if (
          checkbox.type === "radio" &&
          (checkbox.name === "destinationCountrySameString" ||
            checkbox.name === "selectedHagueStatus" ||
            checkbox.name === "expediteRequestString")
        ) {
          // Do nothing for this specific input
        } else {
          const value = checkbox.dataset.value?.trim();
          const isChecked = this.selectedRejectionReasons.includes(value);
          checkbox.checked = isChecked;
          const checkboxContainer = checkbox.closest(".slds-p-top_small");
          if (checkbox.checked && checkboxContainer) {
            checkboxContainer.classList.add("checked-background");
          } else if (checkboxContainer) {
            checkboxContainer.classList.remove("checked-background");
          }
        }
      });
    }, 0);
    this.rejectionModal = true;
  }

  closeRejectionModal() {
    this.rejectionModal = false;
  }

  @wire(getRejectionReasonPicklistValues)
  wiredPicklistValues({ data, error }) {
    if (data) {
      this.rejectionReasonOptions = data.map((label) => ({
        label: label,
        value: label
      }));
    } else if (error) {
      console.error("Error fetching rejection reason values", error);
    }
  }

  handleReasonChange(event) {
    const value = event.target.dataset.value;
    const checkboxContainer = event.target.closest(".slds-p-top_small");

    if (event.target.checked) {
      this.selectedRejectionReasons = [...this.selectedRejectionReasons, value];
      checkboxContainer.classList.add("checked-background");
    } else {
      this.selectedRejectionReasons = this.selectedRejectionReasons.filter(
        (selectedValue) => selectedValue !== value
      );
      checkboxContainer.classList.remove("checked-background");
    }
  }

  handleReset() {
    this.selectedRejectionReasons = [];
    this.customRejectionReason = "";

    const checkboxes = this.template.querySelectorAll("lightning-input");

    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;

      const checkboxContainer = checkbox.closest(".slds-p-top_small");
      if (checkboxContainer) {
        checkboxContainer.classList.remove("checked-background");
      }
    });
  }

  handleCustomReasonChange(event) {
    this.customRejectionReason = event.detail.value;
  }

  handleRejection() {
    const predefinedReasons =
      this.selectedRejectionReasons.length > 0
        ? this.selectedRejectionReasons.join("; ")
        : "";

    this.documents = this.documents.map((doc) =>
      doc.id === this.currentEditingDocumentId
        ? {
            ...doc,
            rejectionReason: predefinedReasons,
            customRejectionReason: this.customRejectionReason || null
          }
        : doc
    );

    this.selectedRejectionReasons = [];
    this.customRejectionReason = "";
    this.rejectionModal = false;
  }

  /**
   * Validates the documents, rejection reasons, and payment amounts to ensure they meet the required conditions.
   * The function checks for the following:
   * - If a document requires a file upload but none exists, it flags a document error.
   * - If a document is rejected but no rejection reason is provided, it flags an error.
   * - If "Adoption Documents" are requested with an expedited adoption, it flags an error.
   * - If the total payment exceeds the required amount, it flags a payment error.
   *
   * @returns {boolean} Returns `true` if all validations pass, otherwise `false`.
   */
  validateDocAndRejectionReason() {
    let isValid = true;
    this.showDocError = false;
    this.showError = false;
    this.showPaymentError = false;
    this.showExpediteAdoptionError = false;

    this.documents.forEach((doc) => {
      if (
        doc.checkDocumentType &&
        (!doc.uploadedFiles || doc.uploadedFiles.length === 0)
      ) {
        this.showDocError = true;
        isValid = false;
      }

      if (
        doc.statusRejected &&
        !doc.rejectionReason &&
        !doc.customRejectionReason
      ) {
        this.showError = true;
        isValid = false;
      }

      if (
        doc.typeOfDocument === "Adoption Documents" &&
        this.expediteRequestString === "yes"
      ) {
        this.showExpediteAdoptionError = true;
        isValid = false;
      }
    });

    const totalPayments = this.paymentList.reduce((sum, payment) => {
      return sum + (parseFloat(payment.paymentAmount) || 0);
    }, 0);

    const cleanedTotalAmount = parseFloat(
      this.totalAmountPayment.replace("$", "") || 0
    );

    if (cleanedTotalAmount > this.totalAmount) {
      this.showPaymentError = true;
      isValid = false;
    } else {
      this.paymentList.forEach((payment) => {
        payment.errorMessage = "";
      });
    }

    return isValid;
  }

  /**
   * Handles the download of the apostille document by invoking the child component to generate and download the PDF.
   *
   * @returns {void} Downloads the apostille document if the PDF generator component is found.
   */
  handleDownloadApostilleDoc() {
    const childComponent = this.template.querySelector(
      '[data-id="pdfGenerator"]'
    );
    if (childComponent) {
      childComponent.pdfForApostilleSuccess("download");
    } else {
    }
  }
}