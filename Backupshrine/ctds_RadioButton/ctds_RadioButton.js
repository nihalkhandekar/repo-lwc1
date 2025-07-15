import { LightningElement,api,wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
export default class MyComponentName extends LightningElement {
   @wire(CurrentPageReference) pageRef;
   @api options;

   @api required;
   @api label;
   @api messageWhenValueMissing;
   @api disabled;
   @api name;
   @api classname;
   @api labelClassName;
   @api clearValueOnCallback;
   connectedCallback() {
    if(this.clearValueOnCallback == true){
        // if flow re-renders due to Conditional Visibility,
        // we can decide to clear the value
        this.value = null;
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', null);
        this.dispatchEvent(attributeChangeEvent);        
    } 
    if(!this.pageRef)
    {
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";
    }          
    registerListener('flowvalidation', this.handleNotification, this);
  }   
  
    @api get value() {
        return this._value;
    }

    set value(value) {
        this._value = value;
    }

    get radioButtonElements() {
        return this.template.querySelectorAll('input');
    }  

  get radioOptions() {
   
    const { options, value } = this;
    debugger;
    if (Array.isArray(JSON.parse(options))) {
        return JSON.parse(options).map((option, index) => ({
            label: option.label,
            value: option.value,
            isChecked: value === option.value,
            indexId: `radio-${index}`
        }));
    }
    return [];

    }
 //This will send the event back to flow
  handleNotification(event) {
      
    if(event.detail.isValid == undefined || event.detail.isValid == true){
		return;
	}
    
    var validationFlag = true;
  
    var inputFields = this.template.querySelectorAll("input");//lightning-radio-group
    if (inputFields !== null && inputFields !== undefined) {
        inputFields.forEach(function(field) {
            /*if (field.nextSibling) {
                if (!field.checkValidity()) {
                    field.nextSibling.classList.add("slds-hidden")
                } else {
                    field.nextSibling.classList.remove("slds-hidden")
                }
            }*/
            field.reportValidity();
            
        });
    }
  }  
//Salesforce hook
    @api
    validate() {
        debugger;
        var validationFlag = false;
        var inputFields = this.template.querySelectorAll("input"); //
        if (inputFields !== null && inputFields !== undefined) {
            inputFields.forEach(function(field) {
                /*if (field.nextSibling) {
                    if (!field.checkValidity()) {
                        field.nextSibling.classList.add("slds-hidden")
                    } else {
                        field.nextSibling.classList.remove("slds-hidden")   
                    }
                }*/
                field.reportValidity();
            });
            for (var i = 0; i < inputFields.length; i++) {
                validationFlag = inputFields[i].checkValidity();
                if (!validationFlag) {
                    break;
                }
            }
            if(validationFlag) { 
                return { isValid: true }; 
            } 
            else { 
                fireEvent(this.pageRef, 'flowvalidation', {detail: { isValid: false }});
                return { 
                    isValid: false, 
                    errorMessage: '' 
                 }; 
             }
        }
    }

    handleChange(event) {
        debugger;
        const value = Array.from(this.radioButtonElements)
            .filter(radioButton => radioButton.checked)
            .map(radioButton => radioButton.value)
            .toString();

        this.value = value;
        const selectedinput = new CustomEvent("selectedinput", {
            detail: {
                value: this.value
              }
           });
           // Dispatches the event.
           this.dispatchEvent(selectedinput);
/*
        let radioValue = event.target.value;
        let data =  event.target.dataset;
      let  index = parseInt(data.id);
      let value1 = this.radioOptions[index].label;

        let shortValue = this.radioOptions[index].shortValue;
        let elabel = this.radioOptions[index].elabel;
        let evalue = this.radioOptions[index].evalue;
        let eshortValue = this.radioOptions[index].eshortValue;
        if (radioValue === "true" || radioValue === "false") {
          radioValue = JSON.parse(radioValue);
        }
        if (event.target.checked === true) {
          event.target.setAttribute("aria-checked", true);
        } else {
          event.target.setAttribute("aria-checked", false);
        }
        */



        /*const selectedOption = event.detail.value;
        this.value = event.target.value;

        const selectedEvent = new CustomEvent("radiovaluebuttonchange", {
            detail: selectedOption
            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);     */
               
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', this.value);
        this.dispatchEvent(attributeChangeEvent);  
     
    }

}