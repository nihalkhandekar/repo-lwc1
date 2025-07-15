/**
 * @File Name          : ModalPopup
 * @Description        : Displays a Popup reminding Business User to File Annual Report
 * @Author             : Govind Varshney
 * @Last Modified By   : Govind Varshney
 * @Last Modified On   : 3.07.2023
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    03.07.2023       Govind Varshney         Initial Version
 **/
import { LightningElement, track } from 'lwc';
import Annual_Report_Link from '@salesforce/label/c.Annual_Report_Link';
import { NavigationMixin } from "lightning/navigation";
import File_Report from '@salesforce/label/c.Modal_File_Your_Annual_Report';
import Enter_Your_ALEI from '@salesforce/label/c.Modal_Enter_your_ALEI';
import Button_Label from '@salesforce/label/c.Modal_Button_Label';

export default class ModalPopup extends NavigationMixin(
    LightningElement
) {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen;
    label = { File_Report, Enter_Your_ALEI, Button_Label }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        sessionStorage.setItem('modalFlag', 'close');
     
    }

    connectedCallback() {
        const d = new Date();
        let month = d.getMonth();
        let boolean = (month < 3) ? true : false;
        if (sessionStorage.getItem('modalFlag')) {
            this.isModalOpen = false;
        }
        else {
        this.isModalOpen = boolean;
        }

    }

    submitDetails() {
        const inputText = this.template.querySelector("input");
        if (inputText.value) {
            sessionStorage.setItem('searchText', inputText.value);
            sessionStorage.setItem('modalFlag', 'close');
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/businessfiling?rt=ar'
            },
            state: {}
        });

    }

    goToAnnualReportFiling() {
        this.isModalOpen = false;
        window.location.href = Annual_Report_Link;

    }
}