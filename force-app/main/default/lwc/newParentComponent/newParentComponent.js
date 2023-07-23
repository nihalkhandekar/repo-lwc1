import { LightningElement, wire } from 'lwc';
import {registerListener, unregisterAllListeners} from 'c/pubsub'; //to register the component//
import {CurrentPageReference} from 'lightning/navigation'; //to get the current page//

export default class NewParentComponent extends LightningElement {

    @wire(CurrentPageReference)
    pageRef;

    connectedCallback(){ //to register when page loads//
        registerListener('pubsubhit', this.updateInputBox,this); //this will register component when the page loads with three parameters passed --> subscribe event name, method/function that you want to work and last this denoted whole class passed //
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    isPassed = 24;
    inputValue;
    message = "Hello Child from Parent";

    newCount=0;
  
    StartCounter = 0;
    HandleCountInput(event){
        this.StartCounter = parseInt(event.target.value);
    }
    handleClick()
    {
    //to catch the method from child component//
    this.template.querySelector('c-new-child-component').maximizeCounter();
    }
    
    handleInputBoxChange(event){
        let inputBoxValue = event.target.value;
            //used to select an element, Here element can be div, span, input or any tag inside lwc component//
        const childComp = this.template.querySelector('c-new-child-component');
        childComp.updateCheckboxValue(inputBoxValue);

    }
    updateInputbox(event){
        this.inputValue = event.detail.value; //updateInputbox me jo value aegi vo inputValue naam k variable me store hogi jo ki value set krega to input box//
    }
    updateInputBox(newValue){
        this.inputValue=newValue;
    }

    handleNewCountValueAdd(){
        this.newCount++;
    }
    handleNewCountValueSub(){
        this.newCount--;
    }
    handleNewCountValueMul(event){
        const dfactor = event.detail;
        this.newCount = this.newCount * dfactor;
    }
}