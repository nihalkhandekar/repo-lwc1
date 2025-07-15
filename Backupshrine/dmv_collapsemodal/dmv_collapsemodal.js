import { LightningElement,wire,api } from 'lwc';

export default class Dmv_collapsemodal extends LightningElement {
    @api index;
    @api title;
    @api isSelected = false;
    @api showSection=false;

    handleSectionHeaderClick(event) {
      event.preventDefault();  
      //  let button = event.getSource();
        this.isSelected = !this.isSelected;
        //var sectionContainer = component.find('');
       var variable = this.template.querySelector('[data-id="collapsibleSectionContainer"]')
       // $A.util.toggleClass(sectionContainer, "slds-is-open");
        variable.classList.toggle('slds-is-open');
        //variable.classList.add('slds-is-open');
       // return false;

    }
    get divClass() {
      return this.showSection ? 'slds-section slds-is-open slds-m-around_small' : 'slds-hide';
   }

}