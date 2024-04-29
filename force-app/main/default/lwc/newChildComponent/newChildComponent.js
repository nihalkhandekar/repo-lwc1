import { LightningElement, api, wire } from 'lwc';
import {registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub'; //to register the component//
import {CurrentPageReference} from 'lightning/navigation'; //to get the current page//

export default class NewChildComponent extends LightningElement {
    
    @api 
    getMessage;
    
    counterValue=0;

    @api
    maximizeCounter(){
        this.counterValue=this.counterValue+1000;
    }

    currentCount =0;
    priorCount=0;

    @api 
    get counterValue(){
        return this.currentCount;
    }
    set counterValue(value){
        this.priorCount = this.currentCount;
        this.currentCount = value;
    }

    @api
    isPass;

    @wire(CurrentPageReference) //You can @wire a property or a function to receive the data.//
    pageRef;

    connectedCallback(){ //to register when page loads//
        registerListener('pubsubhit', this.updateCheckboxValue,this); //this will register component when the page loads with three parameters passed --> subscribe event name, method/function that you want to work and last this denoted whole class passed //
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }           
    get showRed(){
        return this.isPass > 25;
    }

    value = [];

    get options() {
        return [
            { label: 'nihal', value: 'nihal' },
            { label: 'kunal', value: 'kunal' },
            { label: 'snehal', value: 'snehal' },
            { label: 'nikhil', value: 'nikhil' },
            { label: 'Harshal', value: 'Harshal' },

        ];
    }
    @api
    updateCheckboxValue(param){  //nihal, kunal//
        this.value = param.split(','); //this becomes array of string ['nihal', 'kunal']//
    }
    handleChange(event){
        this.value = event.detail.value;
        console.log('Values--'+this.value)
        let parentInputValue = this.value.join(','); //array of string is converted into value//
        //to send value from here to parent create a custom event like onclick, onchange and pass the parameters in detail//
        const parentComp = new CustomEvent('updateinput', {detail:{value:parentInputValue}});
        this.dispatchEvent(parentComp);

        fireEvent( this.pageRef,"newPubSub",parentInputValue);

        }
    
    //For doing actions on Parent from Child//
    addFunction(){
        //To send actions from child to parent//
        this.dispatchEvent(new CustomEvent
        ('add'));
    }
    subFunction(){
        this.dispatchEvent(new CustomEvent
        ('sub'));
    }
    mulFunction(event){
        const dfactor = event.target.dataset.factor;
        //2 or 3//
        this.dispatchEvent(new CustomEvent
        ('mul',{detail:dfactor}))

    }
}