import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from "lightning/platformResourceLoader";
import searchContacts from '@salesforce/apex/DocumentChecklistJsonGenerator.searchContacts';
import requestedCss from "@salesforce/resourceUrl/requestedCss";




export default class ContactSearchModal extends LightningModal {
    contacts = [];
    isLoading = true;
    noResults = false;

    @api searchKey;
    @api position;

    @track isNameHistoryModalOpen = false;
    @track nameHistory = [];
    @track errorMessage ;


    async connectedCallback() {
        loadStyle(this, requestedCss)
            .then(() => console.log("CSS file loaded successfully"))
            .catch((error) => console.error("Error loading CSS file:", error));

        console.log('Search key is:', this.searchKey);
        console.log('position is :', this.position);

        await this.searchContact(this.searchKey,this.position);


    }

    get headerName(){
        if (this.position === 'Notary Public')
            return ' Notary Public Name';
        else
            return 'Public Officials Name';
    }



    async searchContact(searchKey, position) {
        console.log('Currently isLoading is', this.isLoading);

        this.isLoading = true;
        this.noResults = false;
        this.errorMessage = '';

        try {
            const resultString = await searchContacts({ searchKey: searchKey, position: position });
            const result = JSON.parse(resultString); // Parse JSON string into JavaScript object
            console.log('Parsed result:', result);

            const today = new Date();
            this.contacts = result.map(contact => {
                const endTermDate = contact.EndTerm ? new Date(contact.EndTerm) : null;
                console.log(`Indefinite Term: ${contact.IndefiniteTerm}`);

                const indefinite = contact.IndefiniteTerm ? true : false;
                const status = ((endTermDate!=null && endTermDate > today ) || indefinite )? 'Active' : 'Inactive';
                const updatedStartTerm = (contact.IndefiniteTerm && contact.StartTerm == null )? 'N/A' : contact.StartTerm;
                const updatedEndTerm = (contact.IndefiniteTerm && contact.EndTerm == null ) ? 'Indefinite Term' : contact.EndTerm;

                const updatedTermHistory = contact.termHistory.map(term => ({
                    ...term,
                    Start_Term__c: term.Start_Term__c === "Indefinite Term" ? "N/A" : term.Start_Term__c,
                }));


                return {
                    ...contact,
                    Status: status,
                    StartTerm:updatedStartTerm,
                    EndTerm: updatedEndTerm,
                    termHistory: updatedTermHistory,
                    isExpanded: false,
                    iconName: contact.hasTermHistory ? 'utility:chevronright': '',
                    IndefiniteTerm: contact.IndefiniteTerm ? 'Yes' : 'No' // Set to 'Yes' or 'No'
                };
            });
               this.noResults = this.contacts.length === 0;
               if (this.noResults) {
                this.errorMessage = 'No matching contacts found.';
            }
               console.log(JSON.stringify(this.contacts));

        } catch (error) {
            console.error('Error searching contacts:', error);

             // Handle specific errors and set error message
            if (error.body && error.body.message && error.body.message.includes('Too many SOQL queries')) {
                this.errorMessage = 'Too many records to process. Please refine your search criteria.';
            } else {
                this.errorMessage = 'An error occurred while searching for contacts. Please try again later.';
            }
            this.contacts = [];
            this.noResults = true;
        } finally {
            this.isLoading = false;
        }
    }

    get iconClass() {
        return `upDownIcon ${this.hasDocuments ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
    }

    openNameHistory(event) {
        const contactId = event.currentTarget.dataset.id; // Get the contact ID
        const contact = this.contacts.find((c) => c.Id === contactId); // Retrieve the full contact object
        console.log(contact.nameHistory); // Access the List
        if (contact && contact.nameHistory) {
            this.nameHistory = contact.nameHistory; // Set the name history to be displayed
        } else {
            this.nameHistory = []; // Default to empty if no history exists
        }
        this.isNameHistoryModalOpen = true;


    }

    closeNameHistoryModal() {
        // Close name history modal
        this.isNameHistoryModalOpen = false;
        this.nameHistory = [];
    }


    // method for see Term history
     toggleDocument(event) {
         const rowId = event.currentTarget.dataset.id;
         console.log('Clicked row id:', rowId);
         this.contacts = this.contacts.map(row => {
            if (row.Id === rowId) {
                const isExpanded = !row.isExpanded;
                console.log(`Toggling row ID: ${rowId} to isExpanded: ${isExpanded}`);
                return {
                    ...row,
                    isExpanded: isExpanded,
                    iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright'
                };
            }
            return row;
        });
    }

    handleRadioChange(event) {
        // const selectedContactID = event.target.value;
        console.log('Selected  ID:', event.target.value);
        const contactid = event.currentTarget.dataset.contactid;
        const contactName = event.currentTarget.dataset.name;
        const contactPosition = event.currentTarget.dataset.position;
        const start = event.currentTarget.dataset.startterm ;
        const termStart = start !=null ? start : null;
        const end = event.currentTarget.dataset.endterm;
        const termEnd = end !=null ? end :null;

        console.log(`Contact Details:
            - ID: ${contactid}
            - Name: ${contactName}
            - Position: ${contactPosition}
            - Term Start: ${termStart}
            - Term End: ${termEnd}`);

        this.close({ name: contactName, position: contactPosition, selectedContactID: contactid, termStart: termStart, termEnd: termEnd });

    }



    handleOutsideClick(event) {
        // console.log('working outside');
        // // If the click is directly on the container (not the modal)
        // console.log('custom-modal : ',event.target.classList.contains('custom-modal'));
        // console.log('modal-backdrop : ',event.target.classList.contains('modal-backdrop'));

        let customModal = event.target.classList.contains('custom-modal');
        let modalBackdrop = event.target.classList.contains('modal-backdrop');

        // console.log('modalBackdrop value is  :'+modalBackdrop );
        // console.log('customModal value is:'+customModal);


        if (customModal || modalBackdrop) {
            this.handleClose();
        }
    }


    handleClose() {
        this.close();
    }
}