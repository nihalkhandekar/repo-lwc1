import { LightningElement, api, track } from 'lwc';
import getPublicOfficial from '@salesforce/apex/SAP_PublicOfficialExcelController.getPublicOfficial';
import getElectionOffices from '@salesforce/apex/SAP_PublicOfficialExcelController.getElectionOffices';
import getPublicElectionOfficial from '@salesforce/apex/SAP_PublicOfficialExcelController.getPublicElectionOfficial';
import getElectionOfficesRedristrict from '@salesforce/apex/SAP_PublicOfficialExcelController.getElectionOfficesRedristrict';
import legislativeData from '@salesforce/apex/SAP_PublicOfficialExcelController.legislativeData';
import SHEETJS from '@salesforce/resourceUrl/sap_SheetJS';
import { loadScript } from 'lightning/platformResourceLoader';

export default class PublicOfficialExportToExcel extends LightningElement {
    @track paginatedResult = [];
    @api fileName = 'PublicOfficialsExport'; // Default file name
    @api columns; // Columns passed from the parent component
    sheetJsInitialized = false;

    connectedCallback() {
        if (!this.sheetJsInitialized) {
            loadScript(this, SHEETJS)
                .then(() => {
                    this.sheetJsInitialized = true;
                    console.log('SheetJS loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading SheetJS:', error);
                });
        }
    }

    @api
    exportDataToExcelOfficials(columns, searchCriteria, fileName) {
        this.columns = columns; // Store columns for CSV generation
        this.fileName = fileName

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getPublicOfficial({ searchCriteriaJson })
            .then(result => {
                // Process the result and store the paginated data
                this.paginatedResult = result.map(record => {
                    return {
                        ...record,
                        Office: record.SAP_Office__c ? record.Office__r.SAP_Name__c : '',
                        formattedStartDate: this.formatDate(record.SAP_Start_Term__c),
                        formattedEndDate: this.formatDate(record.SAP_End_Term__c),
                    };
                });

                // Generate the Excel file with SheetJS
                this.generateExcelWithSheetJS();

                // // Once the data is fetched, generate and download the CSV
                // const csvContent = this.generateCSVContent();
                // this.downloadCSVFile(csvContent);
            })
            .catch(error => {
                console.error('Error fetching public officials: ', error);
            });
    }

    @api
    exportDataToExcelLegislative(columns, searchCriteria, fileName) {
        this.columns = columns; // Store columns for Excel generation
        this.fileName = fileName;

        const searchCriteriaJson = JSON.stringify(searchCriteria);
    
        legislativeData({ searchCriteriaJson })
            .then(result => {
                // Map the result and store in paginatedResult
                this.paginatedResult = result.map(record => {
                    return {
                        Title: record.SAP_Legislator_Title__c || '',
                        Party: record.SAP_Party__c || '',
                        LastName: record.LastName || '',
                        FirstName: record.FirstName || '',
                        MiddleName: record.MiddleName || '',
                        District: record.SAP_DistrictID__c || ''
                    };
                });
    
                // Generate the Excel file using SheetJS
                this.generateExcelWithSheetJS();
            })
            .catch(error => {
                console.error('Error fetching legislative data:', error);
            });
    }
    
    @api
    exportDataToExcelElectionOffice(columns, searchCriteria, fileName) {
        this.columns = columns; // Store columns for CSV generation
        this.fileName = fileName

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getElectionOffices({ searchCriteriaJson })
            .then(result => {
                // Process the result to map the relevant data for export
                this.paginatedResult = result.map(record => {
                    return {
                        //officeId: record.office.SAP_Id__c || '',
                        officeId: record.office.SAP_Id__c != null && String(record.office.SAP_Id__c).length < 3 
                            ? String(record.office.SAP_Id__c).padStart(3, '0')
                            : String(record.office.SAP_Id__c), // Pad SAP_Id__c to ensure length of 3
                        Office: record.office.SAP_Name__c,
                        emailAddress: record.office.SAP_Business_Email__c || '',
                        rovName: record.office.SAP_ROV_Name__c || '',
                        Address: record.office.SAP_Mailing_Address_Line_1__c || '',
                        State: record.office.SAP_Mailing_Address_State__c || '',
                        Zip: record.office.SAP_Mailing_Address_Zip__c || '',
                        Country: record.office.SAP_Mailing_Address_Country__c || '',
                        ElectionHeld: record.office.SAP_Election_Held_In__c || '',
                        City: record.office.SAP_Mailing_Address_City__c || '',
                        CongressionalDistrict: record.congressionalDist,
                        HouseAssemblyDistrict: record.houseAssemblyDist,
                        SenatorialDistrict: record.senatorialDist,
                        Title: record.office.SAP_ROV_Name__c
                    };
                });

                this.generateExcelWithSheetJS();

                // // Once the data is fetched, generate and download the CSV
                // const csvContent = this.generateCSVContent();
                // this.downloadCSVFile(csvContent);
            })
            .catch(error => {
                console.error('Error fetching public officials: ', error);
            });
    }

    @api
    exportDataToExcelElectionOfficial(columns, searchCriteria, fileName) {
        this.columns = columns; // Store columns for CSV generation
        this.fileName = fileName

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getPublicElectionOfficial({ searchCriteriaJson })
            .then(result => {
                // Process the result and store the paginated data
                this.paginatedResult = result.map(record => {
                    return {
                        ...record,
                        formattedStartDate: this.formatDate(record.SAP_Start_Term__c),
                        formattedEndDate: this.formatDate(record.SAP_End_Term__c),
                    };
                });

                this.generateExcelWithSheetJS();

                // // Once the data is fetched, generate and download the CSV
                // const csvContent = this.generateCSVContent();
                // this.downloadCSVFile(csvContent);
            })
            .catch(error => {
                console.error('Error fetching public officials: ', error);
            });
    }

    // New function for exporting districts data
    @api
    exportDataToExcelReDistricts(columns, searchCriteria, fileName) {
        this.columns = columns;
        this.fileName = fileName;

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getElectionOfficesRedristrict({ searchCriteriaJson })
        .then(result => {
            // Process the result to map the relevant data for export
            this.paginatedResult = result.map(record => {
                return {
                    Office: record.office.SAP_Name__c,
                    CongressionalDistrict: record.congressionalDist,
                    HouseAssemblyDistrict: record.houseAssemblyDist,
                    SenatorialDistrict: record.senatorialDist
                };
            });

            this.generateExcelWithSheetJS();

            // // Once the data is processed, generate and download the CSV
            // const csvContent = this.generateCSVContent();
            // this.downloadCSVFile(csvContent);
        })
        .catch(error => {
            console.error('Error fetching redistrict data: ', error);
        });
    }

    // Function to generate Excel file using SheetJS with dynamic column width
    generateExcelWithSheetJS() {
        // Convert columns and data into SheetJS format
        const headers = this.columns.map(col => col.label);
        const data = this.paginatedResult.map(record =>
            this.columns.map(col => record[col.fieldName] || '')
        );

        // Insert headers as the first row
        data.unshift(headers);

        // Create worksheet from data
        const ws = XLSX.utils.aoa_to_sheet(data);

        // Set column widths based on max content length
        ws['!cols'] = this.columns.map((col, index) => {
            const maxLength = data.reduce((max, row) => {
                return row[index] && row[index].length > max ? row[index].length : max;
            }, col.label.length); // Include header length for comparison
            return { wch: maxLength + 2 }; // Add padding to each column
        });

        // Create workbook and add the worksheet
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'PublicOfficials');

        // Write workbook to file
        XLSX.writeFile(wb, `${this.fileName}.xlsx`);
    }

    // Generate CSV content based on columns and paginatedResult
    generateCSVContent() {
        // Generate the header row
        const headerRow = this.columns.map(col => col.label).join(',') + '\n';

        // Generate the data rows
        const dataRows = this.paginatedResult.map(record => {
            return this.columns.map(col => {
                let value = record[col.fieldName];
                return `"${value ? value.toString().replace(/"/g, '""') : ''}"`; // Escape double quotes
            }).join(',');
        }).join('\n');

        return headerRow + dataRows;
    }

    // Method to trigger CSV download
    downloadCSVFile(csvContent) {
        // Create a Blob from the CSV content with a more generic MIME type
        let blob = new Blob([csvContent], { type: 'application/octet-stream' });
    
        // Create a link element to download the CSV file
        let downloadLink = document.createElement('a');
        let url = URL.createObjectURL(blob);
        downloadLink.href = url;
        downloadLink.download = this.fileName + '.csv'; // File name
    
        // Append the link to the DOM
        document.body.appendChild(downloadLink);
    
        // Trigger the download
        downloadLink.click();
    
        // Clean up and remove the link
        document.body.removeChild(downloadLink);
    }

    // Helper function to format date for CSV export
    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${month}-${day}-${year}`;
    }
}