import { track, api, wire } from "lwc";
import LightningModal from "lightning/modal";
import sap_modalStateStaff from "@salesforce/resourceUrl/sap_modalStateStaff";
import { loadStyle } from "lightning/platformResourceLoader";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import StaffData_OBJECT from "@salesforce/schema/Contact";
import StaffTitle_FIELD from "@salesforce/schema/Contact.SAP_Staff_Title__c";
import StaffDivision_FIELD from "@salesforce/schema/Contact.SAP_Division__c";
import createContactWithFile from "@salesforce/apex/SAP_MaintainStaffDataController.createContactWithFile";
import getContactById from "@salesforce/apex/SAP_MaintainStaffDataController.getContactById";
import updateContactWithFile from "@salesforce/apex/SAP_MaintainStaffDataController.updateContactWithFile";
import downloadFile from "@salesforce/apex/SAP_MaintainStaffDataController.downloadFile";

/**
 * This Lightning Web Component (LWC) provides a modal interface for adding, editing, and viewing staff contact information.
 * It includes functionality for:
 * - Adding new staff contacts with associated files
 * - Editing existing staff contact records
 * - Viewing staff contact details in a read-only mode
 * - Uploading and managing files associated with staff contacts
 * - Validating form inputs and displaying error messages
 * - Handling file downloads and deletions
 * - Integrating with Salesforce Apex controllers for data operations
 */

export default class StaffModal extends LightningModal {
  @track lastName = "";
  @track firstName = "";
  @track middleInitial = "";
  @track suffix = "";
  @track status = "";
  @track phone = "";
  @track esq = false;
  @track title = "";
  @track division = "";
  @track uploadedFiles = [];
  @track staffTitleOptions = [];
  @track staffDivisionOptions = [];
  acceptedFormats = [".jpg", ".gif", ".png"];
  @track fileNames = "";
  @api contactRecordId = "";
  @api readOnly = false;
  @api isEditVisible = false;
  @track dynamicHeading = "Add Staff Data";
  @track isViewStaff = false;
  @track customButtonLabel = "Add";
  @track fieldErrors = {};
  @track contactData;

  // Load CSS and initialize data when the component is connected
  connectedCallback() {
    loadStyle(this, sap_modalStateStaff)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));

    if (this.contactRecordId && !this.readOnly) {
      this.dynamicHeading = "Edit Staff Data";
      this.customButtonLabel = "Save";
    }

    if (this.contactRecordId) {
      this.autofillFieldsWithRecordId();
    }
  }

  // Options for suffix dropdown
  suffixOptions = [
    { label: "Mr", value: "Mr" },
    { label: "Ms", value: "Ms" },
    { label: "Mrs", value: "Mrs" }
  ];

  // Options for status dropdown
  statusOptions = [
    { label: "Active", value: "Active" },
    { label: "Inactive", value: "Inactive" }
  ];

  // Wire method to get object info for the Contact object
  @wire(getObjectInfo, { objectApiName: StaffData_OBJECT })
  objectInfo;

  // Wire method to get picklist values for the Staff Title field
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: StaffTitle_FIELD
  })
  staffTitlePicklistValues({ error, data }) {
    if (data) {
      this.staffTitleOptions = data.values;
    } else if (error) {
      console.error("Error retrieving picklist values", error);
    }
  }

  // Wire method to get picklist values for the Staff Division field
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: StaffDivision_FIELD
  })
  staffDivisionPicklistValues({ error, data }) {
    if (data) {
      this.staffDivisionOptions = data.values;
    } else if (error) {
      console.error("Error retrieving picklist values", error);
    }
  }

  // Handle input changes for form fields
  handleInputChange(event) {
    const field = event.target.name;

    if (field === "phone") {
      const formattedNumber = this.formatPhoneNumber(event.target.value);
      this[field] = formattedNumber;
      event.target.value = formattedNumber;
    } else {
      this[field] = event.target.value;
    }
  }

  // Handle ESQ checkbox change
  handleEsqChange() {
    this.esq = !this.esq;
  }

  // Handle keydown events for the phone input field
  handlePhoneKeyDown(event) {
    const allowedKeys = [
      "Backspace",
      "ArrowLeft",
      "ArrowRight",
      "Delete",
      "Tab"
    ];

    // Handle backspace and delete
    if (event.key === "Backspace" || event.key === "Delete") {
      const input = event.target;
      const selectionStart = input.selectionStart;
      const selectionEnd = input.selectionEnd;
      const value = input.value;
      const digitsOnly = value.replace(/\D/g, "");

      // Case 1: All text is selected (including Ctrl+A case)
      if (selectionStart === 0 && selectionEnd === value.length) {
        event.preventDefault();
        this.handleInputChange({
          target: {
            name: "phone",
            value: ""
          }
        });
        return;
      }

      // Case 2: A portion of text is selected
      if (selectionStart !== selectionEnd) {
        event.preventDefault();
        const beforeSelection = value
          .slice(0, selectionStart)
          .replace(/\D/g, "");
        const afterSelection = value.slice(selectionEnd).replace(/\D/g, "");
        const newValue = beforeSelection + afterSelection;

        this.handleInputChange({
          target: {
            name: "phone",
            value: newValue
          }
        });
        return;
      }

      // Case 3: Regular backspace at a position
      if (event.key === "Backspace") {
        event.preventDefault();
        const newDigits = digitsOnly.slice(0, -1);
        this.handleInputChange({
          target: {
            name: "phone",
            value: newDigits
          }
        });
      }
    }
    // Handle non-numeric keys
    else if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
      // Allow Ctrl+A
      if (event.key.toLowerCase() === "a" && (event.ctrlKey || event.metaKey)) {
        return;
      }
      event.preventDefault();
    }
    // Handle numeric input length restriction
    else {
      const currentValue = event.target.value.replace(/\D/g, "");
      if (
        currentValue.length >= 10 &&
        !allowedKeys.includes(event.key) &&
        !/[0-9]/.test(event.key)
      ) {
        event.preventDefault();
      }
    }
  }

  // Format the phone number input
  formatPhoneNumber(phoneNumberString) {
    let cleaned = phoneNumberString.replace(/\D/g, "");

    cleaned = cleaned.substring(0, 10);

    if (cleaned.length >= 6) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
    } else if (cleaned.length >= 3) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
    } else if (cleaned.length > 0) {
      return `(${cleaned}`;
    }
    return "";
  }

  // Validate form fields
  validateFields() {
    let isValid = true;
    this.fieldErrors = {};
    let missingFields = [];

    if (!this.lastName || this.lastName.trim() === "") {
      this.fieldErrors.lastName = "Last Name is required";
      missingFields.push("Last Name");
      isValid = false;
    }

    if (!this.firstName || this.firstName.trim() === "") {
      this.fieldErrors.firstName = "First Name is required";
      missingFields.push("First Name");
      isValid = false;
    }

    const phoneDigits = this.phone.replace(/\D/g, "");
    if (!this.phone || phoneDigits.length !== 10) {
      this.fieldErrors.phone = "Valid phone number is required (10 digits)";
      missingFields.push("Phone Number");
      isValid = false;
    }

    if (!this.title || this.title.trim() === "") {
      this.fieldErrors.title = "Title is required";
      missingFields.push("Title");
      isValid = false;
    }

    if (!this.division || this.division.trim() === "") {
      this.fieldErrors.division = "Division is required";
      missingFields.push("Division");
      isValid = false;
    }

    this.updateValidationUI();

    if (!isValid) {
      const message = `Please fill in the required fields: ${missingFields.join(", ")}`;
      this.showToast("Error", message, "error");
    }

    return isValid;
  }

  // Show toast message utility method
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

  // Update validation UI for form fields
  updateValidationUI() {
    this.template
      .querySelectorAll("lightning-input, lightning-combobox")
      .forEach((element) => {
        const fieldName = element.name;
        if (this.fieldErrors[fieldName]) {
          element.setCustomValidity(this.fieldErrors[fieldName]);
        } else {
          element.setCustomValidity("");
        }
        element.reportValidity();
      });
  }

  // Handle edit button click to switch to edit mode
  handleEdit() {
    this.readOnly = false;
    this.isEditVisible = false;
    this.dynamicHeading = "Edit Staff Data";
    this.customButtonLabel = "Save";
  }

handleUploadFinished(event) {
  const uploadedFiles = event.detail.files;

  // If there's already a file, delete it before adding the new one
  if (this.uploadedFiles.length > 0) {
    const deletedFileId = this.uploadedFiles[0].documentId;
    this.uploadedFiles = []; // Clear the existing file

    // Track the deleted file for backend processing
    if (!this.deletedFileIds) {
      this.deletedFileIds = [];
    }
    this.deletedFileIds.push(deletedFileId);
  }

  // Add the new file
  this.uploadedFiles = [...uploadedFiles];
}

async handleAdd() {
  if (!this.validateFields()) {
    return;
  }

  const uploadedFileIds = this.uploadedFiles.map((file) => file.documentId);

  if (this.contactRecordId) {
    const params = {
      contactId: this.contactRecordId,
      lastName: this.lastName,
      firstName: this.firstName,
      middleInitial: this.middleInitial,
      suffix: this.suffix,
      title: this.title,
      division: this.division,
      esq: this.esq,
      phone: this.phone,
      status: this.status,
      uploadedFileIds: uploadedFileIds,
      deletedFileIds: this.deletedFileIds || [] // Default to an empty array
    };

    await updateContactWithFile({
      contactData: params
    })
      .then((result) => {
        const passer = this.template.querySelector("c-sap_-event-passer");
        passer.passEvent(
          new CustomEvent("confirmevent", {
            bubbles: true,
            composed: true,
            detail: { message: "confirm" }
          })
        );
        this.handleCancel();
      })
      .catch((error) => {
        console.error('Error saving record:', error);
        let errorMessage = 'Error processing the request. Please try again.';

        if (error && error.body) {
          if (error.body.message) {
            errorMessage = error.body.message;
          } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
            errorMessage = error.body.pageErrors[0].message;
          } else if (error.body.fieldErrors) {
            for (let field in error.body.fieldErrors) {
              if (error.body.fieldErrors[field].length > 0) {
                errorMessage = error.body.fieldErrors[field][0].message;
                break;
              }
            }
          } else if (error.body.actions && error.body.actions.length > 0) {
            let actionError = error.body.actions[0].error;
            if (actionError && actionError.length > 0) {
              if (actionError[0].message) {
                errorMessage = actionError[0].message;
              } else if (actionError[0].pageErrors && actionError[0].pageErrors.length > 0) {
                errorMessage = actionError[0].pageErrors[0].message;
              }
            }
          }
        }

        this.showToast('Staff', errorMessage, 'error');
      });
  } else {
    const params = {
      lastName: this.lastName,
      firstName: this.firstName,
      middleInitial: this.middleInitial,
      suffix: this.suffix,
      title: this.title,
      division: this.division,
      esq: this.esq,
      phone: this.phone,
      status: this.status,
      uploadedFileIds: uploadedFileIds
    };
    await createContactWithFile({
      contactData: params
    })
      .then((result) => {
        const passer = this.template.querySelector("c-sap_-event-passer");
        passer.passEvent(
          new CustomEvent("confirmevent", {
            bubbles: true,
            composed: true,
            detail: { message: "confirm" }
          })
        );

        this.handleCancel();
      })
      .catch((error) => {
        console.error("Error creating contact:", error);
      });
  }
}
  
  // Modified handleDeleteFile
  handleDeleteFile(event) {
    const index = parseInt(event.target.dataset.index, 10);
    // Store the deleted file ID before removing it from the array
    const deletedFileId = this.uploadedFiles[index].documentId;
    this.uploadedFiles.splice(index, 1);
    this.uploadedFiles = [...this.uploadedFiles];
  
    // Keep track of deleted files for backend processing
    if (!this.deletedFileIds) {
      this.deletedFileIds = [];
    }
    this.deletedFileIds.push(deletedFileId);
    // Flag that files have been changed
    this.filesChanged = true;
  }

  // Autofill form fields with data from the recordId
  async autofillFieldsWithRecordId() {
    try {
      // Force fresh data fetch by adding timestamp
      const timestamp = new Date().getTime();
      const result = await getContactById({
        recordId: this.contactRecordId,
        timestamp: timestamp
      });

      const contact = result.contact;
      // Cache the fresh data
      this.contactData = { ...contact };

      // Update the form fields
      this.firstName = contact.FirstName;
      this.lastName = contact.LastName;
      this.middleInitial = contact.MiddleName;
      this.suffix = contact.Suffix;
      this.phone = contact.Phone;
      this.title = contact.SAP_Staff_Title__c;
      this.division = contact.SAP_Division__c;
      this.status = contact.SAP_Status__c;
      this.esq = contact.SAP_Esquire__c;

      // Handle the files
      this.uploadedFiles = result.files.map((file) => ({
        documentId: file.documentId,
        name: file.fileName,
        extension: file.fileExtension
      }));
    } catch (error) {
      console.error("Error retrieving contact:", error);
      throw error;
    }
  }

  // Handle cancel button click to close the modal
  handleCancel() {
    this.close();
  }

  // Handle file download
  async handleFileDownload(event) {
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

      for (
        let offset = 0;
        offset < byteCharacters.length;
        offset += sliceSize
      ) {
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
      const downloadLink = document.createElement("a");
      downloadLink.href = downloadUrl;
      downloadLink.download = fileName;

      document.body.appendChild(downloadLink);
      downloadLink.click();
      document.body.removeChild(downloadLink);

      window.URL.revokeObjectURL(downloadUrl);
    } catch (error) {
      console.error("Error downloading file:", error);
    }
  }

  // Get file template for rendering uploaded files
  get fileTemplate() {
    return this.uploadedFiles.map((file) => ({
      ...file,
      isImage: ["jpg", "jpeg", "png", "gif"].includes(
        file.extension?.toLowerCase()
      )
    }));
  }
}