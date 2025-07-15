import { LightningElement, track, wire } from 'lwc';
import getOfficesByRecordType from '@salesforce/apex/PublicOfficialPrintController.getOfficesByRecordType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import stateSealM from '@salesforce/resourceUrl/stateSealM';
import removeHeadingStateSeal from '@salesforce/resourceUrl/removeHeadingStateSeal';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PublicOfficialLabelsLists extends LightningElement {
    @track towns = [];
    @track cities = [];
    @track states = [];

    @track selectedTowns = [];
    @track selectedCities = [];
    @track selectedStates = [];
    @track selectedRegistrarOptions = [];
    @track selectedMayorOptions = [];
    @track selectedLegislatorTypes = [];
    @track selectedLegislatorAddress = '';
    
    @track selectedCategory = '';
    selectedLabelType = '5160'; // Default label type
    @track selectedTitle = ''; // Stores the currently selected title (only one can be selected at a time)
    @track selectedElectionMonth = ''; // Selected election month (e.g., May)

    @track registrarOptions = ['Democratic', 'Republican', 'Other'];
    @track mayorOptions = ['Authorized Political Official'];
    @track legislatorTypes = ['Representative', 'Senator', 'US Representative', 'US Senator'];
    @track legislatorAddressOptions = ['Preferred Address', 'Business Address', 'Home Address', 'LOB Address'];

    connectedCallback() {
        Promise.all([loadStyle(this, stateSealM), loadStyle(this, removeHeadingStateSeal)])
            .then(() => {
                // After styles are loaded, fetch district options and town offices
            })
            .catch(error => {
                console.error('Error loading styles or fetching data:', error);
            });
    }

    @wire(getOfficesByRecordType, { recordTypeName: 'Town' })
    wiredTowns({ error, data }) {
        if (data) {
            this.towns = data.map(office => ({ Id: office.Id, Name: office.Name__c }));
            console.log(this.towns);
        } else if (error) {
            console.error('Error fetching towns: ', error);
        }
    }

    @wire(getOfficesByRecordType, { recordTypeName: 'City' })
    wiredCities({ error, data }) {
        if (data) {
            this.cities = data.map(office => ({ Id: office.Id, Name: office.Name__c }));
            console.log(this.cities);
        } else if (error) {
            console.error('Error fetching cities: ', error);
        }
    }

    @wire(getOfficesByRecordType, { recordTypeName: 'State' })
    wiredStates({ error, data }) {
        if (data) {
            this.states = data.map(office => ({ Id: office.Id, Name: office.Name__c }));
            console.log(this.states);
        } else if (error) {
            console.error('Error fetching states: ', error);
        }
    }


    handleLabelTypeChange(event) {
        this.selectedLabelType = event.target.value;
    }

    handleTitleChange(event) {
        const selectedTitle = event.target.value;
    
        // Deselect all titles before selecting the new one
        this.clearAllTitles();
    
        // Set the selected title
        this.selectedTitle = selectedTitle;
        event.target.checked = true;
    
        // Based on the selected title, select the corresponding options
        if (selectedTitle === 'Registrars') {
            this.selectedRegistrarOptions = [...this.registrarOptions];
            this.selectAllOptions('registrarOption');
        } else if (selectedTitle === 'Mayor/1st Selectmen') {
            this.selectedMayorOptions = [...this.mayorOptions];
            this.selectAllOptions('mayorOption');
        } else if (selectedTitle === 'Legislator') {
            this.selectedLegislatorTypes = [...this.legislatorTypes];
            this.selectAllOptions('legislatorType');
            this.template.querySelector('input[name="legislatorType"][value="Representative"]').checked = true;
        } else if (selectedTitle === 'Election') {
            this.template.querySelector('input[name="electionMonth"][value="May"]').checked = true;
            this.selectedElectionMonth = 'May';
        }
    }
    
    // Deselect all titles and associated options
    clearAllTitles() {
        // Reset all title selections
        this.selectedRegistrarOptions = [];
        this.selectedMayorOptions = [];
        this.selectedLegislatorTypes = [];
        this.selectedTitle = '';
    
        // Clear all title checkboxes (Election, Town Clerks, Registrars, etc.)
        this.template.querySelectorAll('input[name="title"]').forEach(checkbox => {
            checkbox.checked = false;
        });
    
        // Clear sub-options (e.g., registrarOptions, legislatorTypes)
        this.template.querySelectorAll('input[type="checkbox"], input[type="radio"]').forEach(input => {
            if (input.name !== 'labelType' && input.name != 'town' && input.name != 'city') { // Exclude label type radio buttons
                input.checked = false;
            }
        });
    }
    

    selectAllOptions(optionClass) {
        // Check all the checkboxes for the given option class (e.g., registrarOption, mayorOption, legislatorType)
        this.template.querySelectorAll(`input[name="${optionClass}"]`).forEach(checkbox => {
            checkbox.checked = true;
        });
    }

    handleSelectAllTowns(event) {
        const isChecked = event.target.checked;
    
        // Store only the ID of all towns if "All" is selected, else clear the selection
        this.selectedTowns = isChecked ? [...this.towns.map(town => town.Id)] : [];
    
        // Update checkbox states for all town checkboxes
        this.template.querySelectorAll('input[name="town"]').forEach(checkbox => {
            checkbox.checked = isChecked;
        });
    
        console.log('Selected Town IDs:', this.selectedTowns);
    }
    
    handleTownChange(event) {
        const townId = event.target.dataset.id; // Use data-id to get the town's ID
        if (event.target.checked) {
            // Add selected town ID to the list
            this.selectedTowns.push(townId);
        } else {
            // Remove deselected town ID from the list
            this.selectedTowns = this.selectedTowns.filter(id => id !== townId);
    
            // Uncheck the "Select All" option if an individual town is unchecked
            this.template.querySelector('input[name="town"][value="All"]').checked = false;
        }
    
        console.log('Selected Town IDs:', this.selectedTowns);
    }
    
    handleSelectAllCities(event) {
        const isChecked = event.target.checked;
    
        // Store only the ID of all cities if "All" is selected, else clear the selection
        this.selectedCities = isChecked ? [...this.cities.map(city => city.Id)] : [];
    
        // Update checkbox states for all city checkboxes
        this.template.querySelectorAll('input[name="city"]').forEach(checkbox => {
            checkbox.checked = isChecked;
        });
    
        console.log('Selected City IDs:', this.selectedCities);
    }
    
    handleCityChange(event) {
        const cityId = event.target.dataset.id; // Use data-id to get the city's ID
        if (event.target.checked) {
            // Add selected city ID to the list
            this.selectedCities.push(cityId);
        } else {
            // Remove deselected city ID from the list
            this.selectedCities = this.selectedCities.filter(id => id !== cityId);
    
            // Uncheck the "Select All" option if an individual city is unchecked
            this.template.querySelector('input[name="city"][value="All"]').checked = false;
        }
    
        console.log('Selected City IDs:', this.selectedCities);
    }
    
    handleSelectAllStates(event) {
        const isChecked = event.target.checked;
    
        // Store only the ID of all states if "All" is selected, else clear the selection
        this.selectedStates = isChecked ? [...this.states.map(state => state.Id)] : [];
    
        // Update checkbox states for all state checkboxes
        this.template.querySelectorAll('input[name="state"]').forEach(checkbox => {
            checkbox.checked = isChecked;
        });
    
        console.log('Selected State IDs:', this.selectedStates);
    }
    
    handleStateChange(event) {
        const stateId = event.target.dataset.id; // Use data-id to get the state's ID
        if (event.target.checked) {
            // Add selected state ID to the list
            this.selectedStates.push(stateId);
        } else {
            // Remove deselected state ID from the list
            this.selectedStates = this.selectedStates.filter(id => id !== stateId);
    
            // Uncheck the "Select All" option if an individual state is unchecked
            this.template.querySelector('input[name="state"][value="All"]').checked = false;
        }
    
        console.log('Selected State IDs:', this.selectedStates);
    }
    

    handleRegistrarOptionChange(event) {
        const selectedOption = event.target.value;
        if (event.target.checked) {
            this.selectedRegistrarOptions.push(selectedOption);
        } else {
            this.selectedRegistrarOptions = this.selectedRegistrarOptions.filter(opt => opt !== selectedOption);
        }
    }

    handleMayorOptionChange(event) {
        const selectedOption = event.target.value;
        if (event.target.checked) {
            this.selectedMayorOptions.push(selectedOption);
        } else {
            this.selectedMayorOptions = this.selectedMayorOptions.filter(opt => opt !== selectedOption);
        }
    }

    handleLegislatorTypeChange(event) {
        const selectedType = event.target.value;
        if (event.target.checked) {
            this.selectedLegislatorTypes.push(selectedType);
        } else {
            this.selectedLegislatorTypes = this.selectedLegislatorTypes.filter(type => type !== selectedType);
        }
    }

    handleLegislatorAddressChange(event) {
        this.selectedLegislatorAddress = event.target.value;
    }

    handleClear() {
        this.selectedTowns = [];
        this.selectedCities = [];
        this.selectedStates = [];
        this.selectedRegistrarOptions = [];
        this.selectedMayorOptions = [];
        this.selectedLegislatorTypes = [];
        this.selectedLegislatorAddress = '';
        this.selectedTitle = '';
        this.selectedElectionMonth = '';
        this.selectedLabelType = '5160'; // Reset to default label type
    
        // Clear all checkboxes and radios only if the elements are found
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"], input[type="radio"]');
        if (checkboxes) {
            checkboxes.forEach(input => {
                input.checked = false;
            });
        }
    
        // Set the default label type (5160 Labels)
        const labelTypeInput = this.template.querySelector('input[name="labelType"][value="5160 Labels"]');
        if (labelTypeInput) {
            labelTypeInput.checked = true;
        } else {
            console.error('Label type input not found');
        }
    }
    

    // Collect selected towns, cities, and states
    collectSelections(inputName) {
        return Array.from(this.template.querySelectorAll(`input[name="${inputName}"]:checked`))
            .map(checkbox => checkbox.value);
    }

    handleGenerateLabel() {
        // Get the selected label type
        const selectedLabelType = this.selectedLabelType;
    
        // Initialize variables for selections
        let selectedTowns = [];
        let selectedCities = [];
        let selectedTitle = '';
        let titleValues = {};
    
        // Check for the selected title and its respective values
        if (this.template.querySelector('input[name="title"][value="Election"]').checked) {
            selectedTitle = 'Election';
            titleValues = {
                electionMonth: this.template.querySelector('input[name="electionMonth"]:checked')?.value || ''
            };
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="Town Clerk"]').checked) {
            selectedTitle = 'Town Clerk';
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="Registrars"]').checked) {
            selectedTitle = 'Registrars';
            titleValues = {
                registrarTypes: this.collectSelections('registrarOption')
            };
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="Mayor/1st Selectmen"]').checked) {
            selectedTitle = 'Mayor/1st Selectmen';
    
            // Check if the "Authorized Political Official" checkbox is selected
            const isAuthorized = this.template.querySelector('input[name="mayorOption"][value="Authorized Political Official"]')?.checked || false;
            console.log(isAuthorized);
            // Pass the boolean value of 'isAuthorized' to the titleValues
            titleValues = isAuthorized; // isAuthorized is true or false
            console.log(titleValues);
            
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="Legislator"]').checked) {
            selectedTitle = 'Legislator';
            titleValues = {
                legislatorTypes: this.selectedLegislatorTypes,
                legislatorAddress: this.selectedLegislatorAddress,
            };
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="ROV Offices"]').checked) {
            selectedTitle = 'ROV Offices';
            selectedTowns = this.selectedTowns;
            selectedCities = this.selectedCities;
        } else if (this.template.querySelector('input[name="title"][value="Out of State"]').checked) {
            selectedTitle = 'Out of State Election Offices';
    
            // Here we will only pass the label type and state selections, without towns and cities
            selectedTowns = []; // Do not pass towns
            selectedCities = []; // Do not pass cities
    
            /// Pass the selected states to the titleValues
            titleValues = { selectedStates: this.selectedStates };

            console.log('Selected States:', titleValues);
        }
    
        // Validate that at least one title is selected
        if (!selectedTitle) {
            // If no title is selected, show an error toast
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one title option (Election, Town Clerks, Registrars, etc.).',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return; // Stop execution if no title is selected
        }
    
        // Prepare the final data for label generation
        const labelSelections = {
            labelType: selectedLabelType,
            selectedTowns,
            selectedCities,
            selectedTitle,
            titleValues
        };
    
        // Log the data or pass it to the label generation logic
        console.log('Generating labels with the following selections:', labelSelections);
    
        // Get the label generator component and pass the data
        const labelGenerator = this.template.querySelector('c-public-official-print');
        if (labelGenerator) {
            labelGenerator.generateLabelForTitle(labelSelections);
            console.log('generatingPDF');
        } else {
            console.error('Label generator component not found');
        }
    }
    
    
    
    
    
}