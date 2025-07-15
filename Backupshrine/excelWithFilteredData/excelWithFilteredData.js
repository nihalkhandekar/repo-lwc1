import { LightningElement, track, wire, api } from "lwc";
//import { CloseActionScreenEvent } from "lightning/actions";
import SheetJS from "@salesforce/resourceUrl/SheetJS"; // The static resource for SheetJS //include in new org
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
// import getOptions from "@salesforce/apex/CopyWayleaveLocationController.getOptions";
// import getFirstRecordId from "@salesforce/apex/CopyWayleaveLocationController.getFirstRecordId";
// import getRecordCount from "@salesforce/apex/CopyWayleaveLocationController.getRecordCount";
// import getWayleaveLocations from "@salesforce/apex/CopyWayleaveLocationController.getWayleaveLocations";

// const DEFAULT_SELECTED_FIELDS = ["RegulatoryTrxnFeeItem.RegulatoryTrxnFee.Transaction_Id__c",
// "RegulatoryTrxnFeeItem.RegulatoryTrxnFee.Account.LastName",
// "RegulatoryTrxnFeeItem.RegulatoryTrxnFee.Account.FirstName",
// "RegulatoryTrxnFeeItem.Select_Activity__c",
// "RegulatoryTrxnFeeItem.Payment_Type__c",
// "RegulatoryTrxnFeeItem.FeeAmount",
// //"check/cc#",
// "RegulatoryTrxnFeeItem.RegulatoryTrxnFee.Batch__c",
// "RegulatoryTrxnFeeItem.Transaction_Status__c",
// "Transaction_Date__c",
// "RegulatoryTrxnFeeItem.RegulatoryTrxnFee.Account.Customer_ID__pc"];

const Transaction_ExportResult = ["TransactionId","CustomerLastName","CustomerFirstName","SelectActivity","PaymentType","FeeAmount","CheckNumber","Batch","TrxnStatus","TransactionDate","CustomerId",];
const Report_Refund_ExportResult=["Completed_Date__c","Work_Order_Number__c","Payer__c","Refund_Status__c","Requested_By__c","Payment_Number__c","Payment_Amount__c","Refund_Amount__c"];
export default class excelWithFilteredData extends LightningElement {
    showWayleaveLocationsModal = false;
    showWayleaveLocationsFieldsModal = true;
    @api recordId;
    downloadOptions = [];
    selectedOption = "";
    wayleaveLocations = [];
    totalRecordCounts = 0;
    selectedOptionStartIndex = 0;
    firstRecordId = null;
    callerComponent='';
    Fields;

    //column options for first screen
    // fieldOptions = [
    //     { label: "Release Code", value: "Release Code" },
    //     { label: "UPRN", value: "UPRN" },
    //     { label: "Location Address", value: "Location Address" },
    //     { label: "Service", value: "Service" }
    // ];


    //Fields = Transaction_ExportResult;
    //selectedColumns = this.initializeSelectedColumns();
    //@api filteredWayleaveLocations = [];

    // initializeSelectedColumns() {
    //     return this.fieldOptions
    //         .filter((option) => this.selectedFields.includes(option.value))
    //         .map((option) => ({ label: option.label, fieldName: option.value }));
    // }

    // @wire(getOptions, { wayLeaveAgreementId: "$recordId" })
    // wiredGetOptions({ error, data }) {
    //     if (data) {
    //         this.downloadOptions = data.map((option) => ({
    //             label: option,
    //             value: option
    //         }));
    //         this.selectedOption = this.downloadOptions.length > 0 ? this.downloadOptions[0].value : "";
    //     } else if (error) {
    //         console.error("Error retrieving options:", error);
    //     }
    // }

    // @wire(getFirstRecordId, { wayLeaveAgreementId: "$recordId" })
    // wiredgetFirstRecordId({ error, data }) {
    //     if (data) {
    //         this.firstRecordId = data;
    //     } else if (error) {
    //         console.error("Error retrieving options:", error);
    //     }
    // }

    // @wire(getRecordCount, { wayLeaveAgreementId: "$recordId" })
    // wiredGetRecordCount({ error, data }) {
    //     if (data) {
    //         this.totalRecordCounts = data;
    //     } else if (error) {
    //         console.error("Error retrieving Total counts:", error);
    //     }
    // }

    // handleOptionChange(event) {
    //     this.selectedOption = event.detail.value;
    //     this.selectedOptionStartIndex = parseInt(this.selectedOption.split("-")[0]);
    // }



    connectedCallback() {
        //this.filteredWayleaveLocations = this.wayleaveLocations;
        this.loadSheetJS();
    }

    async loadSheetJS() {
        await loadScript(this, SheetJS); // load the library
        this.version = XLSX.version;
        
    }


    // upar na kamna functions 6 script load thay 6

    // @wire(getWayleaveLocations, {
    //     wayLeaveAgreementId: "$recordId",
    //     selectedOptionStartIndex: "$selectedOptionStartIndex",
    //     firstId: "$firstRecordId"
    // })
    // wiredWayleaveLocations({ error, data }) {
    //     if (data) {
    //         this.wayleaveLocations = data;
    //         this.filteredWayleaveLocations = [];
    //         this.filteredWayleaveLocations = this.filterSelectedColumns(data);
    //         const datatableentity = this.template.querySelector("c-lwc-datatable-utility");
    //         if (datatableentity) {
    //             datatableentity.refresh(this.filteredWayleaveLocations, this.filteredWayleaveLocations.length);
    //         }
    //     } else if (error) {
    //         console.error("Error retrieving wayleave locations:", error);
    //     }
    // }





    // Handle input change for 'from' and 'to' fields
    // handleInputChange(event) {
    //     const { name, value } = event.target;
    //     this[name] = value;
    // }

    // handleCancel() {
    //     const closeAction = new CloseActionScreenEvent();
    //     this.dispatchEvent(closeAction);
    // }

    // 
    //First screen  

    // handleCheckboxChange(event) {
    //     this.selectedFields = event.detail.value;
    //     //this.selectedColumns = this.initializeSelectedColumns();
    //     this.selectedColumns;
    //     this.filteredWayleaveLocations = this.filterSelectedColumns(this.wayleaveLocations);
    // }

    // filterSelectedColumns(data) {
    //     return data.map((item) => {
    //         let filteredItem = {};
    //         this.selectedColumns.forEach((column) => {
    //             if (column.fieldName == "Release Code") {
    //                 filteredItem[column.fieldName] =
    //                     item["Location__r"] && item["Location__r"]["Release__r"]
    //                         ? item["Location__r"]["Release__r"]["Name"]
    //                             ? item["Location__r"]["Release__r"]["Name"]
    //                             : ""
    //                         : "";
    //             }
    //             if (column.fieldName == "UPRN") {
    //                 filteredItem[column.fieldName] = item["UPRN__c"] ? item["UPRN__c"] : "";
    //             }
    //             if (column.fieldName == "Location Address") {
    //                 filteredItem[column.fieldName] = item["Location_Address__c"] ? item["Location_Address__c"] : "";
    //             }
    //             if (column.fieldName == "Service") {
    //                 filteredItem[column.fieldName] = item["Service__r"]
    //                     ? item["Service__r"]["Name"]
    //                         ? item["Service__r"]["Name"]
    //                         : ""
    //                     : "";
    //             }
    //         });
    //         return filteredItem;
    //     });
    // }

    // filteredWayleaveLocations==Insert Data into it
    //  

    fieldValueSet(nameOfComponent){

        if(this.callerComponent=='Transaction'){
            this.Fields = Transaction_ExportResult;
        }
        else if(this.callerComponent=='reportRefund'){
            this.Fields = Report_Refund_ExportResult;
        }
        else{
            console.log('value is not oppropriate');
        }
    }

    @api
    exportToExcel(data,flag) {

        // passing from which component it is called
        this.callerComponent=flag; 
        this.fieldValueSet(this.callerComponent);

        console.log('Data Generated' , JSON.stringify(data));
        const allData = data.map((record) => {
            const selectedRecord = {};
            this.Fields.forEach((field) => {
               // console.log('fields',field);
                selectedRecord[field] = record[field];
            });
            return selectedRecord;
        });
       // const map = new Map(data.map(item => [item.id, item]));
        console.log('map',JSON.stringify(allData));

        // Disable button if there are no records to export
        if (allData.length === 0) {
            // Assuming your button has an id of "exportButton"
            console.log('data is not there');
            // const exportButton = this.template.querySelector(".exportButton");
            // //this.showCustomToast("warning", "No Records to export for this wayleave agreement", "warning");
            // exportButton.disabled = true;
            return;
        }

        const filename = "ExportResult.xlsx";
        const workbook = XLSX.utils.book_new();
        const worksheetData = XLSX.utils.json_to_sheet(allData);
        XLSX.utils.book_append_sheet(workbook, worksheetData, "Wayleave_Locations");

        const excelBuffer = XLSX.write(workbook, {
            bookType: "xlsx",
            type: "array"
        });
        const blob = new Blob([excelBuffer], { type: "application/octet-stream" });

        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = filename;
        a.click();
        URL.revokeObjectURL(a.href);
    
    }

    // handleCopyToClipboard() {
    //     const allData = this.filteredWayleaveLocations.map((record) => {
    //         const selectedRecord = {};
    //         this.selectedFields.forEach((field) => {
    //             selectedRecord[field] = record[field];
    //         });
    //         return selectedRecord;
    //     });

    //     // Format data as a table for copying to clipboard
    //     let clipboardData = "";

    //     // Add header row
    //     clipboardData += this.selectedFields.join("\t") + "\n";

    //     // Add data rows
    //     allData.forEach((record) => {
    //         const rowData = this.selectedFields.map((field) => record[field]).join("\t");
    //         clipboardData += rowData + "\n";
    //     });

    //     // Create a temporary textarea element to copy the data
    //     const tempTextarea = document.createElement("textarea");
    //     tempTextarea.value = clipboardData;
    //     document.body.appendChild(tempTextarea);
    //     tempTextarea.select();

    //     // Execute copy command
    //     try {
    //         document.execCommand("copy");
    //         this.showCustomToast("success", "Data copied to clipboard successfully", "Success");
    //     } catch (error) {
    //         console.error("Error copying to clipboard:", error);
    //         this.showCustomToast("error", "Failed to copy data to clipboard", "Error");
    //     } finally {
    //         // Clean up
    //         document.body.removeChild(tempTextarea);
    //     }
    // }

    // showCustomToast(variant, message, title) {
    //     const evt = new ShowToastEvent({
    //         title: title,
    //         message: message,
    //         variant: variant
    //     });
    //     this.dispatchEvent(evt);
    // }
}


/*

instead of selectedFields name changed to Transaction_ExportResult_Fields
instead of Fields Fields introduced.
instead of one argument we take two arguments for multiple uses


if you want to reuse this module 
than
1> get data in array of object.
2> create array of fields.
2.1> in array of field use name of fields which is in actully passed here.
3> pass appropriatly.

*/