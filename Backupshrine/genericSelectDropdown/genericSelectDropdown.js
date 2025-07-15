import { LightningElement, api  } from 'lwc';

export default class GenericSelectDropdown extends LightningElement {
    @api label;
    @api selectedOption;
    @api dropdownOptions;
    @api placeholder;
    @api required = false;
    @api disabled = false;

    onDropdownChange(event){
        this.selectedOption = event.detail.value;
        const selectedEvent = new CustomEvent("dropdownchange", {
            bubbles: true,
            composed: true,
            detail: {
                selectedOption: this.selectedOption,
            }
          });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
    }
    @api
    validateField(){
        let input = this.template.querySelector('lightning-combobox');
        input.reportValidity();
    }
}