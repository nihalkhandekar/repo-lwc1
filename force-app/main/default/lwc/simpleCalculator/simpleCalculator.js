import { LightningElement, track } from 'lwc';

export default class SimpleCalculator extends LightningElement {
    @track num1;
    @track num2;
    @track result;
    handleChange(event){
        let CurrentInputName = event.target.name;
        let CurrentInputValue = event.target.value;

        if(CurrentInputName === 'number1'){
            this.num1 = CurrentInputValue;
        }
        else{
            this.num2 = CurrentInputValue;
        }
    }

    addFunction(){
        this.result = parseInt(this.num1) + parseInt(this.num2);
    }
    subFunction(){
        this.result = parseInt(this.num1) - parseInt(this.num2);
    }
    mulFunction(){
        this.result = parseInt(this.num1) * parseInt(this.num2);
    }
    divFunction(){
        this.result = parseInt(this.num1) /  parseInt(this.num2);
    }
}