import { LightningElement, track,api,wire } from 'lwc';
import getCertifyRecords from '@salesforce/apex/RecoveryCertifyDataController.getCertifyRecords';
import getCertifyCount from '@salesforce/apex/RecoveryCertifyDataController.getCertifyCount';
import label_Recovery_NoResultMessage from '@salesforce/label/c.Recovery_NoResultMessage';
import label_Recovery_SearchResults from '@salesforce/label/c.Recovery_SearchResults';
import label_Recovery_SearchResultsFor from '@salesforce/label/c.Recovery_SearchResultsFor';
import label_Recovery_AllResults from '@salesforce/label/c.Recovery_AllResults';
import label_Recovery_Found from '@salesforce/label/c.Recovery_Found';
import label_Recovery_Page from '@salesforce/label/c.Recovery_Page';
import label_Recovery_Of from '@salesforce/label/c.Recovery_Of';
import label_Recovery_Next from '@salesforce/label/c.Recovery_Next';
import label_Recovery_Previous from '@salesforce/label/c.Recovery_Previous';
import label_Recovery_Last from '@salesforce/label/c.Recovery_Last';
import label_Recovery_Redirect from '@salesforce/label/c.Recovery_Redirect';
import label_Recovery_FilterError from '@salesforce/label/c.Recovery_FilterError';
import label_Recovery_CertifyDataResultsPerPage from '@salesforce/label/c.Recovery_CertifyDataResultsPerPage';
import label_Recovery_CertifyDataDropdownValues from '@salesforce/label/c.Recovery_CertifyDataDropdownValues';
//importing spanish translation labels
import label_busniessName from '@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel';
import label_zipcode from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessZipCode';
import label_city from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderCity';
import label_county from '@salesforce/label/c.recovery_transparencyCountyLabel';
import label_sector from '@salesforce/label/c.Recovery_Sector';
import Recovery_CertifyDataCSVName from '@salesforce/label/c.Recovery_CertifyDataCSVName';
import Recovery_CertifyDataDownload from '@salesforce/label/c.Recovery_CertifyDataDownload';
import Recovery_CertifyDataOffsetError from '@salesforce/label/c.Recovery_CertifyDataOffsetError';
import Recovery_CertifyDataOffsetHelpText from '@salesforce/label/c.Recovery_CertifyDataOffsetHelpText'

const columns = [
    { label: 'Business Name', fieldName: 'Business_Name__c', wrapText: true, spanishLabel:label_busniessName},
    { label: 'City', fieldName: 'Business_Address_City__c', wrapText: true, spanishLabel:label_city},
    { label: 'County', fieldName: 'Business_Address_County__c', wrapText: true, spanishLabel:label_county},
    { label: 'Sector', fieldName: 'Sector__c', wrapText: true, spanishLabel:label_sector},
    { label: 'Zip Code', fieldName: 'Business_Address_Zip_Code__c', spanishLabel:label_zipcode}
];
export default class RecoveryCertifyData extends LightningElement {
    @track certifyRecords = [];
    @track certifyRecordsCSVFile = [];
    @track offsetLimit = 2000;
    @track governerLimit = 50000;
    @track columns = columns;
    @track paginationRange = [];
    @track totalRecords;
    @track currentPage = 1;
    @track totalPageNumber;
    @track isLastPage = false;
    @track isPrevious = false;
    @track isNext = true;
    @track isAll = true;
    @track isSearch = false;
    @track isResult = true;
    @track fieldapiname = 'Business_Name__c';
    @track selectedRecLimit;
    @track searchtext;
    @track sector=[];
    @track county=[];
    @track isfilter = true;
    @track isNoResult = false;
    @track languageValue='en_US';
    @track offsetExceeded = false;
    @track offsetHelpText = false;

    label = {
        label_Recovery_NoResultMessage,
        label_Recovery_SearchResults,
        label_Recovery_SearchResultsFor,
        label_Recovery_AllResults,
        label_Recovery_Found,
        label_Recovery_Page,
        label_Recovery_Of,
        label_Recovery_Next,
        label_Recovery_Previous,
        label_Recovery_Last,
        label_Recovery_FilterError,
        label_Recovery_CertifyDataResultsPerPage,
        label_busniessName,
        label_zipcode,
        label_city,
        label_county,
        label_sector,
        Recovery_CertifyDataDownload,
        Recovery_CertifyDataOffsetError,
        Recovery_CertifyDataOffsetHelpText
    };
    hanldeInputValueChange(event) {
        this.searchtext = event.detail
        this.data();
    }
    handleSelectedFilterTypeChange(event){
        this.fieldapiname = event.detail;        
        if(this.searchtext!=undefined && this.searchtext.length>0){            
            this.data();
        }
    }
    handleSelectedSectorValuesChange(event){
        this.sector = event.detail;
        this.data();
    }
    handleSelectedCountyValuesChange(event){
        this.county = event.detail;
        this.data();
    }
    get listOfRecLimits() {    
        let recLimitsList =  label_Recovery_CertifyDataDropdownValues.toString().split(';');
        let items = [];
        let i = 0;
        for(i=0; i<recLimitsList.length; i++)  {
            items = [...items ,{value: recLimitsList[i] , label: recLimitsList[i]}];                                       
        }
        return items;
    }
    handleRecLimitValue(event){
        this.selectedRecLimit = event.detail.value;
        this.data();
    }
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    connectedCallback() {
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
        this.offsetExceeded = false;
        let recLimitsList =  label_Recovery_CertifyDataDropdownValues.toString().split(';');
        this.selectedRecLimit = recLimitsList[0];
        getCertifyCount().then(count => {
            if (count) {
                //get the total count of records
                this.totalRecords = count;
                if(this.totalRecords > this.offsetLimit){
                    this.offsetHelpText = true;
                }
                else{
                    this.offsetHelpText = false;
                }
                this.paginationRange = [];
                this.isLastPage = false;
                getCertifyRecords({ recordLimit: this.governerLimit}).then(data => {
                    this.certifyRecordsCSVFile = data;                    
                });
                getCertifyRecords({ recordLimit: this.selectedRecLimit}).then(data => {
                    this.certifyRecords = data;
                    if(this.totalRecords > this.offsetLimit){
                        const paginationNumbers1 = Math.ceil(this.offsetLimit / Number(this.selectedRecLimit));
                        this.totalPageNumber = paginationNumbers1;
                    }
                    else{
                        const paginationNumbers2 = Math.ceil(this.totalRecords / Number(this.selectedRecLimit));
                        this.totalPageNumber = paginationNumbers2;
                    }                    
                    let offset;                    
					if(this.totalPageNumber<=5){
						offset = this.currentPage+this.totalPageNumber;
                        this.isLastPage = true;
					}
					else{
                        offset = this.currentPage+5;						
					}
                    for(let i=this.currentPage;i<offset;i++){
                        this.paginationRange.push(i);
                    }
                    if(this.currentPage == this.totalPageNumber){
                        if(this.totalRecords > this.offsetLimit){
                            this.isNext = true;
                        }
                        else{
                            this.isNext = false; 
                        }
                    }
                    else{
                        this.isNext = true;
                    }
                });
            }
            else{ 
                this.isResult = false;
                this.offsetHelpText = false;
                this.isfilter = false;
            }
        });        
    }
    showPageNumber(event){
        if(this.currentPage<=this.totalPageNumber){
            this.offsetExceeded = false;
            this.paginationRange = [];
            let offset = this.currentPage+5;
            for(let i=this.currentPage;i<offset;i++){
                if(i<=this.totalPageNumber){
                    this.paginationRange.push(i);
                }
                if(i===this.totalPageNumber){
                    this.isLastPage = true;
                }
            }
        }
        else {
            if(this.currentPage == this.totalPageNumber){
                if(this.totalRecords > this.offsetLimit){
                    this.isNext = true;
                }
                else{
                    this.isNext = false; 
                }
            }
            else{
                this.isNext = true;
            }
        }        
    }
    handlePaginationClick(event) {
        if(this.currentPage != this.totalPageNumber || event.target.dataset.targetNumber != undefined){
            this.isPrevious = true;
            this.offsetExceeded = false;
            let offsetNumber;
            
            if(event.target.dataset.targetNumber === undefined){
                this.currentPage = this.currentPage + 1;
                offsetNumber = this.currentPage;
            }
            else{
                offsetNumber = event.target.dataset.targetNumber;
                this.currentPage = Number(offsetNumber);
            }
            
            getCertifyRecords({ recordLimit: this.selectedRecLimit, offsetRange: Number(this.selectedRecLimit) * (offsetNumber - 1), fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county})
                .then(data => {
                    this.certifyRecords = data;
                })
                .catch(error => {
                });
                if(offsetNumber>this.paginationRange[Number(this.paginationRange.length-1)]){
                    this.showPageNumber(); 
                }
            
                if(this.currentPage == this.totalPageNumber){
                    if(this.totalRecords > this.offsetLimit){
                        this.isNext = true;
                    }
                    else{
                        this.isNext = false; 
                    }
                }
                else{
                    this.isNext = true;
                }
        }
        else{
            this.offsetExceeded = true;      
            this.currentPage = this.currentPage + 1;
            if(this.currentPage == this.totalPageNumber){
                if(this.totalRecords > this.offsetLimit){
                    this.isNext = true;
                }
                else{
                    this.isNext = false; 
                }
            }
            else{
                this.isNext = true;
            }
        }
    }

    // handleLast(event){
    //     let offsetNumber = this.totalPageNumber;
    //     this.currentPage = Number(offsetNumber);
    //     this.isPrevious = true;
    //     getCertifyRecords({ recordLimit: this.selectedRecLimit, offsetRange: Number(this.selectedRecLimit) * (offsetNumber - 1), fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county })
    //         .then(data => {
    //             this.certifyRecords = data;
    //         })
    //         .catch(error => {
    //         });
    // }

    handlePrevious(event){
        this.isAll = false;
        this.isSearch=true;
        this.offsetExceeded = false;
        if(this.currentPage>1){            
            let offsetNumber = this.currentPage-1;
            this.currentPage = Number(offsetNumber);
            getCertifyRecords({ recordLimit: this.selectedRecLimit, offsetRange: Number(this.selectedRecLimit) * (offsetNumber - 1), fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county })
                .then(data => {
                    this.certifyRecords = data;
                })
                .catch(error => {
                });
            if(offsetNumber<this.paginationRange[0] || offsetNumber === this.totalPageNumber-1){
                this.showPreviousPageNumber();  
            }

            if(this.currentPage == this.totalPageNumber){
                if(this.totalRecords > this.offsetLimit){
                    this.isNext = true;
                }
                else{
                    this.isNext = false; 
                }
            }
            else{
                this.isNext = true;
            }
        }
        if(this.currentPage === 1){
            this.isPrevious = false;
            if(this.currentPage == this.totalPageNumber){
                if(this.totalRecords > this.offsetLimit){
                    this.isNext = true;
                }
                else{
                    this.isNext = false; 
                }
            }
            else{
                this.isNext = true;
            }
        }
    }
    showPreviousPageNumber(event){
        this.offsetExceeded = false;
        if(this.currentPage<this.paginationRange[0]){
            this.paginationRange = [];
            let offset= this.currentPage-4;
            for(let i=offset;i<=this.currentPage;i++){
                this.isLastPage = false;
                this.paginationRange.push(i);
            }
        } 
        if(this.currentPage===this.totalPageNumber-1){
            let offset = (this.currentPage+1) - this.currentPage%5;            
			if(this.currentPage%5 != 0){	                
                this.paginationRange = [];		
				for(let i=offset;i<=this.currentPage+1;i++){
                    this.isLastPage = true;
                    this.paginationRange.push(i);
				}
			}
        }
        if(this.currentPage == this.totalPageNumber){
            if(this.totalRecords > this.offsetLimit){
                this.isNext = true;
            }
            else{
                this.isNext = false; 
            }
        }
        else{
            this.isNext = true;
        }        
    }
    data() {
        this.currentPage = 1;
        this.isPrevious = false;
        this.isLastPage = false;
        this.isResult = true;
        this.isfilter = true;
        this.isNoResult = false;
        this.paginationRange = [];
        this.offsetExceeded = false;  
        getCertifyCount({ fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county}).then(count => {
            if (count) {
                //get the total count of records                
                this.totalRecords = count;
                if(this.totalRecords > this.offsetLimit){
                    this.offsetHelpText = true;
                }
                else{
                    this.offsetHelpText = false;
                }
                if(this.searchtext!=undefined){
                    this.isSearch = true;
                    this.isAll = false;
                }
                getCertifyRecords({ recordLimit: this.governerLimit, fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county}).then(data => {
                    this.certifyRecordsCSVFile = data;                    
                });
                getCertifyRecords({ recordLimit: this.selectedRecLimit, fieldName: this.fieldapiname, searchText: this.searchtext, sector : this.sector, county: this.county}).then(data => {
                    this.certifyRecords = data;
                    if(this.totalRecords > this.offsetLimit){
                        const paginationNumbers1 = Math.ceil(this.offsetLimit / Number(this.selectedRecLimit));
                        this.totalPageNumber = paginationNumbers1;
                    }
                    else{
                        const paginationNumbers2 = Math.ceil(this.totalRecords / Number(this.selectedRecLimit));
                        this.totalPageNumber = paginationNumbers2;
                    }
                    let offset;                    
					if(this.totalPageNumber<=5){
						offset = this.currentPage+this.totalPageNumber;
                        this.isLastPage = true;                        
					}
					else{
                        offset = this.currentPage+5;				
                    }
                    this.paginationRange = [];
                    for(let i=this.currentPage;i<offset;i++){
                        this.paginationRange.push(i);                    
                    }
                    if(this.currentPage == this.totalPageNumber){
                        if(this.totalRecords > this.offsetLimit){
                            this.isNext = true;
                        }
                        else{
                            this.isNext = false; 
                        }
                    }
                    else{
                        this.isNext = true;
                    }                   
                });
            }
            else{
                this.isResult = false;
                this.offsetHelpText = false;              
                if(this.searchtext != undefined){
                    this.isNoResult = true;
                }
                else{
                    this.isfilter = false
                }
                
            }
        });
        if(this.sector.length<1 && this.county.length<1 && this.searchtext.length<1){              
            location.href = label_Recovery_Redirect;
        }
    }

    downloadCSVFile(){
        let rowEnd = '\n';
        let csvString = '';
        // Set to contain API names and labels for columns
        let rowData = new Set();
        let rowDataLabel = new Set();
        let rowDataLabelSpanish = new Set();

        //setting API names and labels from data

        this.columns.forEach(function (record) {
            rowData.add(record.fieldName);         
            rowDataLabel.add(record.label);
            rowDataLabelSpanish.add(record.spanishLabel);         
        });

        rowData = Array.from(rowData);
        rowDataLabel = Array.from(rowDataLabel);
        rowDataLabelSpanish = Array.from(rowDataLabelSpanish);
        
        // splitting using ',' (Add labels as row header for csv file)
        if(this.languageValue === 'en_US'){
            csvString += rowDataLabel.join(',');
        }
        else{
            csvString += rowDataLabelSpanish.join(',');
        }
        csvString += rowEnd;

        // main for loop to get the data based on field API value
        for(let i=0; i < this.certifyRecordsCSVFile.length; i++){
            //Get data based on the Field API. If the column is undefined, it as blank in the CSV file.
            let value0 = this.certifyRecordsCSVFile[i]['Business_Name__c'] === undefined ? '' : this.certifyRecordsCSVFile[i]['Business_Name__c'];
            csvString += '"'+ value0 +'"';
            csvString += ',';            
            let value1 = this.certifyRecordsCSVFile[i]['Business_Address_City__c'] === undefined ? '' : this.certifyRecordsCSVFile[i]['Business_Address_City__c'];
            csvString += '"'+ value1 +'"';
            csvString += ',';            
            let value2 = this.certifyRecordsCSVFile[i]['Business_Address_County__c'] === undefined ? '' : this.certifyRecordsCSVFile[i]['Business_Address_County__c'];
            csvString += '"'+ value2 +'"';
            csvString += ',';
            let value3 = this.certifyRecordsCSVFile[i]['Sector__c'] === undefined ? '' : this.certifyRecordsCSVFile[i]['Sector__c'];
            csvString += '"'+ value3 +'"';
            csvString += ',';
            let value4 = this.certifyRecordsCSVFile[i]['Business_Address_Zip_Code__c'] === undefined ? '' : this.certifyRecordsCSVFile[i]['Business_Address_Zip_Code__c'];
            csvString += '"'+ value4 +'"';
            csvString += rowEnd;
        }

        var universalBOM = "\uFEFF";
       // Creating anchor element to download
        let downloadElement = document.createElement('a');
        // This  encodeURIComponent encodes special characters.
        downloadElement.href = 'data:text/csv;charset=UTF-8,' + encodeURIComponent(universalBOM+csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = Recovery_CertifyDataCSVName+'.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }
}