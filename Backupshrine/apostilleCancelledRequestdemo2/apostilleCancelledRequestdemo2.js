import { LightningElement, track, wire } from "lwc";
import getCancelled from "@salesforce/apex/ApostilleDraftsController.getCancelled";
import getCancelledCount from "@salesforce/apex/ApostilleDraftsController.getCancelledCount";
import updateApplicationStatusToDraft from "@salesforce/apex/ApostilleDraftsController.updateApplicationStatusToDraft";
import { loadStyle } from "lightning/platformResourceLoader";
import requestedCss from "@salesforce/resourceUrl/requestedCss";

export default class ApostilleCancelledRequest extends LightningElement {
    @track data = []; // Stores fetched data in batches (20 at a time)
    @track paginatedResult = []; // Stores 10 records for the current page
    @track sortedBy = "workOrder";
    @track sortDirection = "asc";
    @track currentPage = 1;
    @track pageSize = 10; // Number of records per page
    @track totalPages = 0;
    @track startRecord = 1;
    @track endRecord = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track reinstateOrder = false;
    @track showTable = false;
    @track selectedRecordId;
    @track isLoading = true; // To control the initial loader for the entire component
    @track isRecordsLoading = true; // Flag to show loading spinner while loading records
    offsetVal = 0; // Used for server offset to fetch data (set to multiples of 20)
    loadedRecords = 0; // Tracks the total number of records fetched

    connectedCallback() {
        // Load the CSS file
        loadStyle(this, requestedCss)
            .then(() => console.log("CSS file loaded successfully"))
            .catch((error) => console.error("Error loading CSS file:", error));
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
                // Fetch data here and set it to this.data
    
                // Once data is fetched, hide the loader
                this.isLoading = false;
                this.loadCancelldCount();
            }, 1000);     
    }

    loadCancelldCount() {
        // Fetch the total count of draft records
        getCancelledCount()
            .then(count => {
                this.totalRecords = count;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.showPages = this.totalPages > 1;
                // Load initial drafts data
                this.loadCancelled();
            })
            .catch(error => {
                console.error('Error fetching draft count:', error);
            });
    }

    loadCancelled() {
        this.isRecordsLoading = true;
        getCancelled({
            offsetVal: this.offsetVal,
            pageSize: 20, // or whatever your pagination limit is
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection
        })
        .then(data => {
            // Log the data to check if records are coming in
            console.log('Received data: ', data);
            if (data && data.length > 0) {
                this.data = [...this.data, ...data];
                this.loadedRecords += data.length; // Update the loadedRecords variable
                this.updatePaginatedResult(); // Update the paginated result
            }
            this.isRecordsLoading = false; 
           
        })
        .catch(error => {
            console.error('Error loading cancelled records: ', error);
            this.isRecordsLoading = false;  // Stop loading spinner
        });
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
                // Already have enough records loaded locally
                this.updatePaginatedResult();
            } else {
                // Need to load more data from server
                this.offsetVal += 20;
                this.loadCancelled();
            }
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePaginatedResult();
        }
    }

    updatePaginatedResult() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        // Update paginated result with the records for the current page
        this.paginatedResult = this.data.slice(startIndex, endIndex);
        
        // Update start and end record numbers for pagination text
        this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get sortIcon() {
        return this.sortDirection === "asc" ? "utility:arrowup" : "utility:arrowdown";
    }

    sortByField(event) {
        const fieldName = event.currentTarget.dataset.field;
        this.sortedBy = fieldName;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); // Reset pagination when sorting
        this.loadCancelled(); // Fetch sorted data from the server
    }
    
    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = []; // Clear current data
        this.paginatedResult = []; // Clear paginated result
        this.loadedRecords = 0;
    }


    // Navigation back to the Dashboard
    navigateToDashboard() {
        console.log("Dashboard button is clicked");
        window.location.href = "/eApostille/dashboard";
    }

    handleViewAction(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.reinstateOrder = true; // Show the modal for reinstating the order
    }

    handleCancel() {
        this.reinstateOrder = false; // Hide the modal
    }

    handleYesOfReinstateRequest() {
        updateApplicationStatusToDraft({ recordId: this.selectedRecordId })
            .then(() => {
                this.reinstateOrder = false; // Close modal
            })
            .catch(error => {
                console.error('Error reinstating order:', error);
            });
        window.location.href = `/eApostille/eApostilleform?recordId=${this.selectedRecordId}`;
    }

}