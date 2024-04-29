import { LightningElement, track, wire } from 'lwc';
import {fireEvent,registerListener, unregisterAllListeners} from 'c/pubsub'; //to register the component//
import {CurrentPageReference} from 'lightning/navigation'; //to get the current page//

export default class SecondLWCComponent extends LightningElement {

@track BrandNewValue= [];

@wire(CurrentPageReference) //You can @wire a property or a function to receive the data.//
pageRef;

connectedCallback(){ //to register when page loads//
    registerListener("newPubSub", this.HandleNewInput,this);
}

disconnectedCallback(){
    unregisterAllListeners(this);
} 

@track 
GreetingNote = "Good Morning";

@track Friends = ['Dhiraj', 'Monish', 'Jignesh', 'Ramesh', 'Suresh'];

HandleInputChange(event){
    let newValue = event.target.value;
    /*console.log(newValue);
    console.log(event.target.label); */

    if(event.target.label === 'Note 1' ){
        this.GreetingNote = newValue;
    }
    if(event.target.label === 'Note 2' ){
        fireEvent(this.pageRef, 'pubsubhit', newValue);
    }

    }

    HandleNewInput(data){
            this.BrandNewValue = data;   
    }

}