import { LightningElement } from 'lwc';

export default class CustomDropdown extends LightningElement {
    // Dropdown open state
    isDropdownOpen = false;

    // Options for the dropdown (each with a value, label, and selected state)
    options = [
        { value: 'option1', label: 'Option 1', selected: false },
        { value: 'option2', label: 'Option 2', selected: false },
        { value: 'option3', label: 'Option 3', selected: false }
    ];

    // Computed property to return a comma-separated string of selected options
    get selectedOptionsString() {
        return this.options
            .filter(option => option.selected)
            .map(option => option.label)
            .join(', ');
    }

    // Toggle the dropdown visibility
    toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    // Handle checkbox state change
    handleCheckboxChange(event) {
        const value = event.target.value;
        const isChecked = event.target.checked;

        // Update the selected state of the corresponding option
        this.options = this.options.map(option => {
            if (option.value === value) {
                return { ...option, selected: isChecked };
            }
            return option;
        });
    }
}