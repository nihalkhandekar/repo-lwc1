import { LightningElement, track, api } from 'lwc';

export default class BosAccountProgressBar extends LightningElement {

    @track _value;
    @api label;
    @api set progress(val){
        if(val >=0 && val <= 100){
            this._value = val;
        }
    }

    get progress(){
        return this._value;
    }

    get Width(){
        return this._value?"width:"+this._value+"%": "width:0%";
    }

    get Widthtext(){
        return this._value ? this.value+"%": "0%";
    }

    get classes(){
        if(this._value === 0){
            return 'slds-progress-bar__value';
        }
        else if(this._value > 0 && this._value < 100){
            return 'slds-progress-bar__value progress-bar__value_inprogess';
        }
        else if(this._value === 100){
            return 'slds-progress-bar__value progress-bar__value_complete';
        }
        return 'slds-progress-bar__value';
    }
}